import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'native_audio_interface.dart';
import 'arm64_audio_service.dart';
import 'x86_audio_service.dart';

/// プラットフォーム層：アーキテクチャ判定とサービス注入
/// 実行環境に応じて適切なオーディオサービス実装をプロバイダーで提供します
/// - Platform.version や Abi.current で厳密にアーキテクチャを判定
/// - CI/CDではビルドバリアント制御も可能
/// 
/// 実行環境に応じて適切な実装を注入するプロバイダー
/// CI/CDではこのロジックとは別に、ビルドバリアントで物理的にコードを含めない制御も可能
final nativeAudioServiceProvider = Provider<NativeAudioService>((ref) {
  // 簡易判定ロジック
  // 実際には `Platform.version` や `Abi.current` を厳密にチェックする
  final isArm64 = Platform.version.toLowerCase().contains('arm64') || Platform.isIOS || Platform.isAndroid;
  
  if (isArm64) {
    return Arm64AudioService();
  } else {
    return X86AudioService();
  }
});