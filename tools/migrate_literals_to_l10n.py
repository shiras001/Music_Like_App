#!/usr/bin/env python3
import re
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
L10N_DIR = ROOT / 'lib' / 'l10n'

# Patterns to find literal strings passed to Text(), SnackBar, AlertDialog title/content, Button labels
text_pattern = re.compile(r"Text\(\s*('(?:[^'\\]|\\.)*'|\"(?:[^\\\"]|\\.)*\")")
# also const Text('...')
# We'll collect unique strings
strings = {}

for root, dirs, files in os.walk(ROOT / 'lib'):
    for fname in files:
        if fname.endswith('.dart'):
            p = Path(root) / fname
            s = p.read_text(encoding='utf-8')
            for m in text_pattern.finditer(s):
                lit = m.group(1)
                # strip quotes
                if lit.startswith("'") or lit.startswith('"'):
                    val = lit[1:-1]
                else:
                    val = lit
                # skip if contains interpolation or already AppLocalizations
                if '{' in val or '}' in val or '\${' in val:
                    continue
                if 'AppLocalizations' in s[m.start()-40:m.start()+40]:
                    continue
                if '_t(' in s[m.start()-40:m.start()+40]:
                    continue
                # heuristic: skip single-char strings or strings that look like format or code
                if len(val.strip()) == 0:
                    continue
                if len(val.strip()) <= 2 and not val.strip().isalnum():
                    continue
                key = val.strip()
                strings.setdefault(key, []).append(str(p))

print(f'Found {len(strings)} unique literal UI strings to consider.')

if not strings:
    print('Nothing to migrate.')
    exit(0)

# load arb files
arb_files = list(L10N_DIR.glob('app_*.arb'))
arb_map = {f.stem: f for f in arb_files}

# function to make key
import re

def make_key(s):
    s = s.strip()
    s = re.sub(r"[^0-9a-zA-Z \u4e00-\u9fff\u3040-\u309f\u30a0-\u30ff]+", ' ', s)
    parts = s.split()
    if not parts:
        return 'key'
    # use english-like words if available else romanize? fallback to first word
    key = parts[0].lower() + ''.join(p.capitalize() for p in parts[1:])
    key = re.sub(r'[^0-9a-zA-Z]', '', key)
    if re.match(r'^[0-9]', key):
        key = 'k' + key
    return key

# collect existing keys
existing_keys = set()
for arb in arb_files:
    try:
        data = json.loads(arb.read_text(encoding='utf-8'))
        existing_keys.update(data.keys())
    except Exception:
        pass

new_entries = []
for val, locs in strings.items():
    # skip if value looks like code (contains backslash n etc) - keep simple
    if '\n' in val and len(val) > 80:
        continue
    key_base = make_key(val)
    key = key_base
    i = 1
    while key in existing_keys:
        i += 1
        key = f"{key_base}{i}"
    existing_keys.add(key)
    new_entries.append((key, val))

print('Prepared', len(new_entries), 'entries to add to ARB.')

# write to all ARB files
for arb in arb_files:
    lang = arb.stem.replace('app_', '')
    try:
        data = json.loads(arb.read_text(encoding='utf-8'))
    except Exception:
        data = {}
    updated = False
    for key, val in new_entries:
        if key in data:
            continue
        # choose which language file gets which text: if en -> use original string for en, else if ja and string contains japanese characters use it, otherwise fallback to en
        if lang.startswith('en'):
            data[key] = val
        elif lang.startswith('ja') and re.search(r'[\u3040-\u30ff\u4e00-\u9fff]', val):
            data[key] = val
        else:
            data[key] = val
        updated = True
    if updated:
        arb.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
        print('Updated', arb.name)

# Add abstract getters to app_localizations.dart
app_loc_file = L10N_DIR / 'app_localizations.dart'
app_loc_src = app_loc_file.read_text(encoding='utf-8')
pos = app_loc_src.rfind('\n}\n')
if pos == -1:
    pos = len(app_loc_src)
new_getters = ''
for key, val in new_entries:
    new_getters += f"\n  /// Auto-migrated literal: {val}\n  String get {key};\n"
app_loc_src = app_loc_src[:pos] + new_getters + app_loc_src[pos:]
app_loc_file.write_text(app_loc_src, encoding='utf-8')
print('Patched app_localizations.dart with new getters')

# Patch each generated language file to override getters
lang_files = list(L10N_DIR.glob('app_localizations_*.dart'))
for lang_file in lang_files:
    src = lang_file.read_text(encoding='utf-8')
    pos = src.rfind('\n}')
    if pos == -1:
        pos = len(src)
    additions = ''
    code = lang_file.name.replace('app_localizations_', '').replace('.dart', '')
    for key, val in new_entries:
        val_escaped = val.replace("'", "\\'")
        additions += f"\n  @override\n  String get {key} => '{val_escaped}';\n"
    src = src[:pos] + additions + src[pos:]
    lang_file.write_text(src, encoding='utf-8')
    print('Patched', lang_file.name)

# Replace occurrences in source
for root, dirs, files in os.walk(ROOT / 'lib'):
    for fname in files:
        if fname.endswith('.dart'):
            fpath = Path(root) / fname
            s = fpath.read_text(encoding='utf-8')
            changed = False
            for key, val in new_entries:
                # replace Text('val') and Text("val") occurrences
                s_new = s.replace(f"Text('{val}'", f"Text(AppLocalizations.of(context)!.{key}" )
                s_new = s_new.replace(f'Text("{val}"', f'Text(AppLocalizations.of(context)!.{key}' )
                if s_new != s:
                    s = s_new
                    changed = True
            if changed:
                fpath.write_text(s, encoding='utf-8')
                print('Updated', fpath)

print('Literal migration completed. Please run flutter gen-l10n and build to regenerate localization classes.')
