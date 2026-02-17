import 'dart:io';

import 'package:flutter/material.dart';
import 'package:music_like/l10n/app_localizations.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';

class BackgroundEditorPage extends StatefulWidget {
  const BackgroundEditorPage({super.key});

  @override
  State<BackgroundEditorPage> createState() => _BackgroundEditorPageState();
}

class _BackgroundEditorPageState extends State<BackgroundEditorPage> {
  File? _imageFile;
  final TransformationController _controller = TransformationController();
  double _scale = 1.0;
  double _dx = 0.0;
  double _dy = 0.0;

  Future<void> _pickImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        setState(() {
          _imageFile = File(path);
        });
      }
    }
  }

  void _resetTransform() {
    setState(() {
      _scale = 1.0;
      _dx = 0.0;
      _dy = 0.0;
      _controller.value = Matrix4.identity();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateController() {
    final m = Matrix4.identity();
    m.translate(_dx, _dy);
    m.scale(_scale);
    _controller.value = m;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.backgroundCustomize),
        actions: [
          IconButton(
            icon: const Icon(Icons.wallpaper),
            onPressed: () async {
                if (_imageFile == null) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.selectImageFirst)));
                return;
              }
              try {
                const channel = MethodChannel('appmaker/wallpaper');
                final res = await channel.invokeMethod('setWallpaper', {'path': _imageFile!.path});
                if (res == true) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.backgroundSet)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.backgroundSetFailed)));
                }
              } catch (err) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.e(err.toString()))));
              }
            },
            tooltip: '端末の壁紙に設定',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetTransform,
            tooltip: 'リセット',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.photo),
        tooltip: '画像を選択',
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: _imageFile == null
                ? Container(color: Colors.black12)
                : InteractiveViewer(
                    transformationController: _controller,
                    minScale: 0.5,
                    maxScale: 4.0,
                    boundaryMargin: const EdgeInsets.all(200),
                    child: Image.file(
                      _imageFile!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
          ),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'ここにUIを重ねます',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // Sliders for adjusting scale and position when an image is loaded
          if (_imageFile != null)
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Card(
                color: Colors.black54,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text('Scale', style: TextStyle(color: Colors.white)),
                          Expanded(
                            child: Slider(
                              value: _scale,
                              min: 0.5,
                              max: 4.0,
                              divisions: 35,
                              onChanged: (v) {
                                setState(() {
                                  _scale = v;
                                  _updateController();
                                });
                              },
                            ),
                          ),
                          Text(_scale.toStringAsFixed(2), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('X', style: TextStyle(color: Colors.white)),
                          Expanded(
                            child: Slider(
                              value: _dx,
                              min: -300,
                              max: 300,
                              divisions: 120,
                              onChanged: (v) {
                                setState(() {
                                  _dx = v;
                                  _updateController();
                                });
                              },
                            ),
                          ),
                          Text(_dx.toStringAsFixed(0), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      Row(
                        children: [
                          const Text('Y', style: TextStyle(color: Colors.white)),
                          Expanded(
                            child: Slider(
                              value: _dy,
                              min: -300,
                              max: 300,
                              divisions: 120,
                              onChanged: (v) {
                                setState(() {
                                  _dy = v;
                                  _updateController();
                                });
                              },
                            ),
                          ),
                          Text(_dy.toStringAsFixed(0), style: const TextStyle(color: Colors.white)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: _resetTransform,
                            child: const Text('Reset', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
