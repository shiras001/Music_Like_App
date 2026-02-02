/// プラットフォーム層のオーディオサービスインターフェース
/// ARM64 と x86/x64 で異なる実装を提供します
/// ハードウェアアクセラレーションとハイレゾオーディオの分離実装を想定
///
/// アーキテクチャ共通のオーディオ操作インターフェース
abstract class NativeAudioService {
  /// オーディオエンジンの初期化
  Future<void> initializeAudioEngine();

  /// [cite: 14, 16] ハイレゾ・空間オーディオのデコード処理
  /// ARM64ではハードウェアアクセラレーションを使用することを想定
  Future<void> decodeHighResAudio(String path);

  /// デバッグ用：現在のアーキテクチャ名を取得
  String getArchitectureName();
}