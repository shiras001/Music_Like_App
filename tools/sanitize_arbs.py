#!/usr/bin/env python3
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
L10N = ROOT / 'lib' / 'l10n'
LIB = ROOT / 'lib'

arb_files = list(L10N.glob('app_*.arb'))
if not arb_files:
    print('No ARB files found')
    exit(1)

# collect all keys from en arb as canonical set
base_arb = L10N / 'app_en.arb'
base = json.loads(base_arb.read_text(encoding='utf-8'))
keys = [k for k in base.keys() if not k.startswith('@')]

# gen-l10n requires camelCase-like identifiers starting with a lowercase letter
valid_re = re.compile(r'^[a-z][A-Za-z0-9]*$')
invalid_keys = [k for k in keys if not valid_re.match(k)]

if not invalid_keys:
    print('No invalid keys found')
    exit(0)

print('Invalid keys found:', invalid_keys)

# create mapping old->new
mapping = {}
counter = 1
for old in invalid_keys:
    new = None
    # try to make somewhat readable key from value in en
    val = base.get(old, '')
    # extract ascii letters words
    words = re.findall(r'[A-Za-z]+', val)
    if words:
        candidate = words[0].lower() + ''.join(w.capitalize() for w in words[1:])
        candidate = re.sub(r'[^A-Za-z0-9]', '', candidate)
        if not candidate:
            candidate = None
        elif not candidate[0].isalpha():
            candidate = 'm' + candidate
        if candidate and candidate not in mapping.values():
            new = candidate
    if not new:
        new = f'm{counter}'
        counter += 1
    # ensure not collision with existing keys
    while new in base.keys() or new in mapping.values():
        new = f'{new}{counter}'
        counter += 1
    mapping[old] = new

print('Mapping:', mapping)

# apply mapping to each arb file
for arb in arb_files:
    data = json.loads(arb.read_text(encoding='utf-8'))
    updated = False
    for old, new in mapping.items():
        if old in data:
            data[new] = data.pop(old)
            # also move metadata
            meta_old = '@' + old
            meta_new = '@' + new
            if meta_old in data:
                data[meta_new] = data.pop(meta_old)
            updated = True
    if updated:
        arb.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding='utf-8')
        print('Updated', arb.name)

# update app_localizations.dart and generated lang files
app_loc = L10N / 'app_localizations.dart'
src = app_loc.read_text(encoding='utf-8')
for old, new in mapping.items():
    # replace getter declarations
    src = re.sub(rf"String get {re.escape(old)};", f"String get {new};", src)
app_loc.write_text(src, encoding='utf-8')
print('Patched app_localizations.dart')

lang_files = list(L10N.glob('app_localizations_*.dart'))
for lf in lang_files:
    s = lf.read_text(encoding='utf-8')
    changed = False
    for old, new in mapping.items():
        # override getters
        s_old = rf"String get {old} => '"
        if s_old in s:
            s = s.replace(f"String get {old} => '", f"String get {new} => '")
            changed = True
        # also any @override String get old => '...'
        s = re.sub(rf"@override\s+String get {re.escape(old)}\s+=>", f"@override String get {new} =>", s)
    if changed:
        lf.write_text(s, encoding='utf-8')
        print('Patched', lf.name)

# update code references
for p in LIB.rglob('*.dart'):
    s = p.read_text(encoding='utf-8')
    changed = False
    for old, new in mapping.items():
        pattern = f"AppLocalizations.of(context)!.{old}"
        if pattern in s:
            s = s.replace(pattern, f"AppLocalizations.of(context)!.{new}")
            changed = True
    if changed:
        p.write_text(s, encoding='utf-8')
        print('Updated code references in', p)

print('Sanitization complete. Please run flutter gen-l10n and rebuild.')
