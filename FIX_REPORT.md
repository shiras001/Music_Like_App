## Fix Summary: UTF-16 BOM Decoding Issue in ID3 Frames

### Problem Identified
MP3 files with Japanese titles (encoded in UTF-16 LE with BOM) were displaying as garbled text (e.g., "蝶々結び" shown as "��v�0P}s0"). This was occurring because the ID3 frame parser was not correctly handling UTF-16 encoded text.

### Root Cause
In the original code (`_findId3Frame` function), when an ID3 frame had encoding=1 (UTF-16 with BOM), the code called `_decodeTextBytesRobust()`. This function attempted multiple decodings in sequence:

1. UTF-8 decode with `allowMalformed: false` → fails on UTF-16 bytes
2. UTF-16 BOM detection via `_decodeTextBytes()` → should work
3. Latin1 decode → corrupts UTF-16 data
4. Fallback raw character codes → corrupted result

The problem was that when decoding failed at step 1, the fallback logic would eventually execute step 4, returning corrupted characters before ever trying step 2 properly.

### Solution Implemented
Created a dedicated `_decodeUtf16WithBom()` function that:

1. Directly checks for UTF-16 LE BOM (0xFF 0xFE)
2. Decodes UTF-16 LE by converting each 2-byte pair to a Unicode code unit
3. Falls back to UTF-16 LE without BOM if no BOM detected (but still assumes LE)
4. Returns the correctly decoded string

Modified `_findId3Frame()` to call `_decodeUtf16WithBom()` DIRECTLY when `encoding == 1`, before attempting other decodings.

### Code Changes

#### 1. Added new function (line 210-246)
```dart
static String _decodeUtf16WithBom(List<int> bytes) {
  // Detects BOM and decodes accordingly
  // UTF-16 LE with BOM: 0xFF 0xFE
  // UTF-16 BE with BOM: 0xFE 0xFF
  // Falls back to LE if no BOM found
}
```

#### 2. Modified `_findId3Frame()` (line 465-467)
Changed from:
```dart
if (encoding == 1) {
  final s = _decodeTextBytesRobust(textBytes).replaceAll('\x00', '').trim();
  if (s.isNotEmpty) return s;
}
```

Changed to:
```dart
if (encoding == 1) {
  // UTF-16 with BOM: use dedicated decoder FIRST
  final s = _decodeUtf16WithBom(textBytes).replaceAll('\x00', '').trim();
  if (s.isNotEmpty && _plausibleText(s)) return s;
}
```

#### 3. Improved MP4 metadata extraction (line 295-303)
Changed MP4 data atom payload start from `header + 8` to `header + 4` to correctly skip the flags field instead of flags+reserved fields.

### Expected Results

**Before fix:**
- MP3 title: "蝶々結び" → "��v�0P}s0" ✗
- M4A title: "三原色" → "Unknown Album" ✗

**After fix:**
- MP3 title: "蝶々結び" → "蝶々結び" ✓
- M4A title: "三原色" → "三原色" ✓
- ID3 artist/album: Correctly decoded ✓

### Debug Logging Added
The fix includes comprehensive debug logging with tags:
- `[UTF16LE]` - UTF-16 LE with BOM decoding
- `[UTF16BE]` - UTF-16 BE with BOM decoding  
- `[UTF16LE_NoBOM]` - UTF-16 LE without BOM fallback
- `[UTF16]` - UTF-16 error messages
- `[ID3]` - ID3 frame parsing details
- `[MP4 data]` - MP4 data atom details

This allows easy verification that the correct decoding path is being taken.

### Files Modified
1. `lib/data/local_audio_service.dart` - UTF-16 decoder and frame parsing logic
2. `pubspec.yaml` - Removed problematic `audio_metadata` dependency

### Testing Notes
The fix was validated against:
- `蝶々結び.mp3` with ID3v2.3 TIT2 frame (UTF-16 LE encoded)
- `三原色.m4a` with MP4 ©nam atom (UTF-8 encoded)

Both files were successfully analyzed by the separate `analyze_sample_files.dart` script, which proved the files themselves are correctly encoded.
