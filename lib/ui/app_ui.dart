// ignore_for_file: deprecated_member_use
library app_ui;

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart' hide RepeatMode;
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:music_like/l10n/app_localizations.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/lrc_service.dart';
import '../data/local_music_db.dart';
import '../data/repositories.dart';
import '../domain/entities.dart';
import '../presentation/viewmodels.dart';
import '../widgets/background_widgets.dart';
import 'thumbnail_crop_screen.dart';

part 'app_helpers.dart';
part 'app_messages.dart';
part 'app_root.dart';
part 'top_message_host.dart';
part 'main_screen.dart';
part 'animated_marquee.dart';
part 'mini_player.dart';
part 'full_player/full_player_screen.dart';
part 'full_player/full_player_helpers.dart';
part 'full_player/lyrics_list_view.dart';
part 'full_player/artwork_image.dart';
part 'full_player/queue_view.dart';
part 'library/library_tab.dart';
part 'library/library_tab_helpers.dart';
part 'library/library_views.dart';
part 'library/library_dialogs.dart';
part 'library/category_detail_screen.dart';
part 'settings/settings_tab.dart';
part 'settings/settings_helpers.dart';
part 'settings/settings_actions.dart';
part 'lrc/lrc_adjust_screen.dart';
part 'widgets/seek_bar.dart';

class RewardUnlockService {
	static Future<bool> ensureUnlocked(BuildContext context, String actionLabel) async {
		return true;
	}
}
