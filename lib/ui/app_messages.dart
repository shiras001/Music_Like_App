part of 'app_ui.dart';

final ValueNotifier<List<String>> _appMessageNotifier = ValueNotifier<List<String>>([]);

void _pushAppMessage(BuildContext context, String message) {
  final list = List<String>.from(_appMessageNotifier.value);
  list.add(message);
  _appMessageNotifier.value = list;
}
