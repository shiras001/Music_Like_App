/// Test script to verify the UTF-16 BOM fix for ID3 frames
/// This script replicates the fixed _decodeUtf16WithBom function to test locally

import 'dart:convert';

/// Fixed UTF-16 with BOM decoder
String decodeUtf16WithBom(List<int> bytes) {
  try {
    if (bytes.length >= 2) {
      // UTF-16 LE with BOM
      if (bytes[0] == 0xFF && bytes[1] == 0xFE) {
        final codeUnits = <int>[];
        for (int i = 2; i + 1 < bytes.length; i += 2) {
          codeUnits.add(bytes[i] | (bytes[i + 1] << 8));
        }
        final result = String.fromCharCodes(codeUnits);
        print('[UTF16LE] Decoded: "$result"');
        return result;
      }
      // UTF-16 BE with BOM
      if (bytes[0] == 0xFE && bytes[1] == 0xFF) {
        final codeUnits = <int>[];
        for (int i = 2; i + 1 < bytes.length; i += 2) {
          codeUnits.add((bytes[i] << 8) | bytes[i + 1]);
        }
        final result = String.fromCharCodes(codeUnits);
        print('[UTF16BE] Decoded: "$result"');
        return result;
      }
    }
    // No BOM found, assume UTF-16 LE (most common for ID3)
    if (bytes.isNotEmpty) {
      final codeUnits = <int>[];
      for (int i = 0; i + 1 < bytes.length; i += 2) {
        codeUnits.add(bytes[i] | (bytes[i + 1] << 8));
      }
      final result = String.fromCharCodes(codeUnits);
      print('[UTF16LE_NoBOM] Decoded: "$result"');
      return result;
    }
  } catch (e) {
    print('[UTF16] Error decoding: $e');
  }
  return '';
}

void main() {
  print('=' * 80);
  print('Testing UTF-16 BOM Decoder Fix');
  print('=' * 80);
  
  // Test 1: UTF-16 LE with BOM (蝶々結び 0xFF 0xFE 0x76 0x87 0x05 0x30 0x50 0x7d 0x73 0x30)
  final test1 = [0xFF, 0xFE, 0x76, 0x87, 0x05, 0x30, 0x50, 0x7d, 0x73, 0x30];
  print('\nTest 1: UTF-16 LE BOM (蝶々結び)');
  print('Input bytes: ${test1.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
  final result1 = decodeUtf16WithBom(test1);
  print('Expected: 蝶々結び');
  print('Got: $result1');
  print(result1 == '蝶々結び' ? '✓ PASS' : '✗ FAIL');
  
  // Test 2: UTF-16 LE with BOM (アルバム)
  final test2 = [0xFF, 0xFE, 0xA2, 0x30, 0xEB, 0x30, 0xD0, 0x30, 0xE0, 0x30];
  print('\nTest 2: UTF-16 LE BOM (アルバム)');
  print('Input bytes: ${test2.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
  final result2 = decodeUtf16WithBom(test2);
  print('Expected: アルバム');
  print('Got: $result2');
  print(result2 == 'アルバム' ? '✓ PASS' : '✗ FAIL');
  
  // Test 3: UTF-16 LE with BOM (三原色)
  final test3 = [0xFF, 0xFE, 0x09, 0x4E, 0x9F, 0x50, 0x66, 0x89];
  print('\nTest 3: UTF-16 LE BOM (三原色)');
  print('Input bytes: ${test3.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
  final result3 = decodeUtf16WithBom(test3);
  print('Expected: 三原色');
  print('Got: $result3');
  print(result3 == '三原色' ? '✓ PASS' : '✗ FAIL');
  
  // Test 4: UTF-16 LE with BOM (YOASOBI)
  final test4 = [
    0xFF, 0xFE, 0x59, 0x00, 0x4F, 0x00, 0x41, 0x00, 0x53, 0x00, 0x4F, 0x00, 0x42, 0x00, 0x49, 0x00
  ];
  print('\nTest 4: UTF-16 LE BOM (YOASOBI)');
  print('Input bytes: ${test4.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
  final result4 = decodeUtf16WithBom(test4);
  print('Expected: YOASOBI');
  print('Got: $result4');
  print(result4 == 'YOASOBI' ? '✓ PASS' : '✗ FAIL');
  
  print('\n' + '=' * 80);
  print('Testing UTF-8 decoder for M4A atoms');
  print('=' * 80);
  
  // Test 5: UTF-8 (三原色)
  final test5 = [0xe4, 0xb8, 0x89, 0xe5, 0x8e, 0x9f, 0xe8, 0x89, 0xb2];
  print('\nTest 5: UTF-8 (三原色)');
  print('Input bytes: ${test5.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
  final result5 = utf8.decode(test5);
  print('Expected: 三原色');
  print('Got: $result5');
  print(result5 == '三原色' ? '✓ PASS' : '✗ FAIL');
  
  // Test 6: UTF-8 (YOASOBI) 
  final test6 = [0x59, 0x4f, 0x41, 0x53, 0x4f, 0x42, 0x49];
  print('\nTest 6: UTF-8 (YOASOBI)');
  print('Input bytes: ${test6.map((b) => '0x${b.toRadixString(16).padLeft(2, '0')}').join(' ')}');
  final result6 = utf8.decode(test6);
  print('Expected: YOASOBI');
  print('Got: $result6');
  print(result6 == 'YOASOBI' ? '✓ PASS' : '✗ FAIL');
  
  print('\n' + '=' * 80);
  print('All tests completed!');
  print('=' * 80);
}
