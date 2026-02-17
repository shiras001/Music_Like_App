#!/usr/bin/env python3
import re
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
L10N_DIR = ROOT / 'lib' / 'l10n'

# find parameterized _t occurrences in code
code_pattern = re.compile(r"_t\(context,\s*ja:\s*'(?P<ja>.*?)',\s*en:\s*'(?P<en>.*?)',\s*zh:\s*'(?P<zh>.*?)'\)", re.S)
param_pattern = re.compile(r"\$\{([^}]+)\}")

occurrences = []
for root, dirs, files in os.walk(ROOT / 'lib'):
    for fname in files:
        if fname.endswith('.dart'):
            fpath = Path(root) / fname
            s = fpath.read_text(encoding='utf-8')
            for m in code_pattern.finditer(s):
                ja = m.group('ja')
                en = m.group('en')
                zh = m.group('zh')
                params = param_pattern.findall(en)
                if params:
                    occurrences.append({'file':str(fpath), 'start':m.start(), 'end':m.end(), 'ja':ja, 'en':en, 'zh':zh, 'params':params, 'match_text':m.group(0)})

print('Found parameterized occurrences:', len(occurrences))

if not occurrences:
    print('No parameterized _t(...) found. Exiting.')
    exit(0)

# helper to make key
def make_key(english):
    s = english.strip()
    s = re.sub(r"[\"]", '', s)
    s = re.sub(r"[^0-9a-zA-Z ]+", ' ', s)
    parts = s.split()
    if not parts:
        parts = ['param']
    key = parts[0].lower() + ''.join(p.capitalize() for p in parts[1:])
    if re.match(r'^[0-9]', key):
        key = 'k' + key
    return key

# load existing keys
arb_files = list(L10N_DIR.glob('app_*.arb'))
existing = set()
for arb in arb_files:
    try:
        data = json.loads(arb.read_text(encoding='utf-8'))
        existing.update([k for k in data.keys()])
    except Exception:
        pass

new_entries = []

for occ in occurrences:
    en = occ['en']
    ja = occ['ja']
    zh = occ['zh']
    params = occ['params']
    # create placeholder names p1, p2...
    ph_names = []
    for i,p in enumerate(params, start=1):
        # try to derive a name from the expression
        m = re.search(r"([A-Za-z_][A-Za-z0-9_]*)\s*(?:\(|$)", p)
        if m:
            name = m.group(1)
            name = re.sub(r"^_+", '', name)
            if not name:
                name = f'p{i}'
        else:
            name = f'p{i}'
        # avoid duplicates
        base = name
        j=1
        while name in ph_names:
            name = f"{base}{j}"
            j+=1
        ph_names.append(name)
    # build arb value replacing ${...} with {ph}
    arb_en = en
    for i,p in enumerate(params):
        arb_en = arb_en.replace('${' + p + '}', '{' + ph_names[i] + '}')
    arb_ja = ja
    for i,p in enumerate(params):
        arb_ja = arb_ja.replace('${' + p + '}', '{' + ph_names[i] + '}')
    arb_zh = zh
    for i,p in enumerate(params):
        arb_zh = arb_zh.replace('${' + p + '}', '{' + ph_names[i] + '}')
    # make key
    key_base = make_key(re.sub(r"\{[^}]+\}", '', arb_en))
    key = key_base
    idx = 1
    while key in existing:
        idx += 1
        key = f"{key_base}{idx}"
    existing.add(key)
    new_entries.append({'key':key, 'en':arb_en, 'ja':arb_ja, 'zh':arb_zh, 'placeholders':ph_names, 'occ':occ})

print('Prepared new entries:', len(new_entries))

# Update ARB files with placeholders metadata
for arb in arb_files:
    lang = arb.stem.replace('app_', '')
    try:
        data = json.loads(arb.read_text(encoding='utf-8'))
    except Exception:
        data = {}
    updated = False
    for ent in new_entries:
        k = ent['key']
        if k in data:
            continue
        if lang.startswith('en'):
            data[k] = ent['en']
        elif lang.startswith('ja'):
            data[k] = ent['ja']
        elif lang.startswith('zh'):
            data[k] = ent['zh']
        else:
            data[k] = ent['en']
        # add metadata for placeholders
        meta_key = '@' + k
        placeholders_obj = {}
        for ph in ent['placeholders']:
            placeholders_obj[ph] = {}
        data[meta_key] = {'placeholders': placeholders_obj}
        updated = True
        print(f'Added param key {k} to {arb.name}')
    if updated:
        arb.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')

print('ARB updates done.')

# Now replace occurrences in source files with AppLocalizations method calls
for ent in new_entries:
    occ = ent['occ']
    params = occ['params']
    ph_names = ent['placeholders']
    fpath = Path(occ['file'])
    s = fpath.read_text(encoding='utf-8')
    # find the exact match and replace; craft replacement using original expressions
    repl_exprs = ', '.join(params)
    replacement = f"AppLocalizations.of(context)!.{ent['key']}({repl_exprs})"
    s_new = s.replace(occ['match_text'], replacement)
    if s_new != s:
        fpath.write_text(s_new, encoding='utf-8')
        print('Replaced in', fpath)

print('Source replacements for parameterized messages done.')

print('Migration of parameterized _t completed. Now run `flutter gen-l10n`.')
