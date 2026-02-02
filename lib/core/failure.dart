/// アプリケーション全体で使用するエラーハンドリングクラスです
/// ドメイン層でのエラーを表現します
/// 
class Failure {
  final String message;
  final dynamic originalError;

  Failure(this.message, [this.originalError]);

  @override
  String toString() => 'Failure: $message ${originalError != null ? "($originalError)" : ""}';
}