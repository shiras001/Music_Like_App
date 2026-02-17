#!/usr/bin/env python3
import re
import json
import os
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
T_OCC = ROOT / 'lib' / '_t_occurrences.txt'
L10N_DIR = ROOT / 'lib' / 'l10n'

# Read occurrences
text = T_OCC.read_text(encoding='utf-8')
# regex to find _t(context, ja: '...', en: '...', zh: '...')
pattern = re.compile(r"_t\(context,\s*ja:\s*'(?P<ja>.*?)',\s*en:\s*'(?P<en>.*?)',\s*zh:\s*'(?P<zh>.*?)'\)")
matches = pattern.findall(text)
print(f'Found {len(matches)} matches in occurrences file')

# unique by english+ja+zh
unique = {}
for ja,en,zh in matches:
    key = (ja,en,zh)
    unique[key] = {'ja':ja, 'en':en, 'zh':zh}

print(f'Unique entries: {len(unique)}')

# helper to make camelCase key from English
def make_key(english):
    s = english.strip()
    s = re.sub(r"[\"]", '', s)
    s = re.sub(r"[^0-9a-zA-Z ]+", '', s)
    parts = s.split()
    if not parts:
        parts = ['key']
    key = parts[0].lower() + ''.join(p.capitalize() for p in parts[1:])
    # ensure valid identifier
    if re.match(r'^[0-9]', key):
        key = 'k' + key
    return key

# load arb files
arb_files = list(L10N_DIR.glob('app_*.arb'))
arb_map = {f.stem: f for f in arb_files}
print('ARB files:', list(arb_map.keys()))

# track generated keys to avoid duplicates
existing_keys = set()
# read app_localizations.dart to find existing declarations
app_loc_file = L10N_DIR / 'app_localizations.dart'
app_loc_src = app_loc_file.read_text(encoding='utf-8')
# find existing getter names - crude: find "String get <name>;"
for m in re.finditer(r"String get (\w+);", app_loc_src):
    existing_keys.add(m.group(1))
# also methods like String foo(String arg)
for m in re.finditer(r"String (\w+)\(", app_loc_src):
    existing_keys.add(m.group(1))

print('Existing localization symbols count:', len(existing_keys))

new_entries = []
for (ja,en,zh), vals in unique.items():
    if '${' in ja or '${' in en or '${' in zh:
        # skip parameterized for manual handling
        print('Skipping parameterized:', en)
        continue
    key = make_key(en)
    base = key
    idx = 1
    while key in existing_keys:
        idx += 1
        key = f"{base}{idx}"
    existing_keys.add(key)
    new_entries.append((key, vals))

print('New entries to add:', len(new_entries))

# Update ARB JSON files
for key, vals in new_entries:
    for arb in arb_files:
        lang = arb.stem.replace('app_', '')
        try:
            data = json.loads(arb.read_text(encoding='utf-8'))
        except Exception:
            data = {}
        if key in data:
            continue
        if lang.startswith('en'):
            data[key] = vals['en']
        elif lang.startswith('ja'):
            data[key] = vals['ja']
        elif lang.startswith('zh'):
            data[key] = vals['zh']
        else:
            # fallback to english
            data[key] = vals['en']
        # write back
        arb.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
        print(f'Added {key} to {arb.name}')

# Add abstract getters to app_localizations.dart
insert_point = None
for m in re.finditer(r"class AppLocalizations \{", app_loc_src):
    insert_point = m.end()
# safer: append before the last closing brace of class - find the location of "static const List<LocalizationsDelegate" etc
# We'll insert near the top after the constructor comments by finding line '  /// No description provided for @appTitle.' and insert after a bit
# Simpler: append getters before the final '}' in file
pos = app_loc_src.rfind('\n}\n')
if pos == -1:
    pos = len(app_loc_src)

new_getters = ''
for key, vals in new_entries:
    # simple getter
    new_getters += f"\n  /// Auto-migrated key for: {vals['en']}\n  String get {key};\n"

app_loc_src = app_loc_src[:pos] + new_getters + app_loc_src[pos:]
app_loc_file.write_text(app_loc_src, encoding='utf-8')
print('Updated app_localizations.dart with new getters')

# Update each generated language dart file by adding override getters returning the value
lang_files = list(L10N_DIR.glob('app_localizations_*.dart'))
for lang_file in lang_files:
    src = lang_file.read_text(encoding='utf-8')
    # find class body start: 'class AppLocalizationsEn extends AppLocalizations {'
    m = re.search(r"class (AppLocalizations\w+) extends AppLocalizations \{", src)
    if not m:
        print('Could not find class in', lang_file.name)
        continue
    class_name = m.group(1)
    # find insertion point: before the final '}' of the file
    pos = src.rfind('\n}')
    if pos == -1:
        pos = len(src)
    additions = ''
    # determine lang code from filename
    # app_localizations_en.dart -> en
    lf = lang_file.name
    code = lf.replace('app_localizations_', '').replace('.dart','')
    for key, vals in new_entries:
        val = vals.get('en', '')
        if code.startswith('ja'):
            val = vals['ja']
        elif code.startswith('zh'):
            val = vals['zh']
        # escape single quotes
        val_escaped = val.replace("'", "\\'")
        additions += f"\n  @override\n  String get {key} => '{val_escaped}';\n"
    src = src[:pos] + additions + src[pos:]
    lang_file.write_text(src, encoding='utf-8')
    print('Patched', lang_file.name)

# Now replace occurrences in source files
# regex to match the full _t(... ) with either single or double quotes simplified earlier
code_pattern = re.compile(r"_t\(context,\s*ja:\s*'(?P<ja>.*?)',\s*en:\s*'(?P<en>.*?)',\s*zh:\s*'(?P<zh>.*?)'\)")

for root, dirs, files in os.walk(ROOT / 'lib'):
    for fname in files:
        if fname.endswith('.dart'):
            fpath = Path(root) / fname
            s = fpath.read_text(encoding='utf-8')
            changed = False
            def repl(m):
                ja = m.group('ja')
                en = m.group('en')
                zh = m.group('zh')
                if '${' in ja or '${' in en or '${' in zh:
                    return m.group(0)  # skip
                # find key
                for k, vals in new_entries:
                    if vals['en'] == en and vals['ja'] == ja and vals['zh'] == zh:
                        return f"AppLocalizations.of(context)!.{k}"
                return m.group(0)
            news = code_pattern.sub(repl, s)
            if news != s:
                fpath.write_text(news, encoding='utf-8')
                print('Updated', fpath)

print('Migration script completed.')
