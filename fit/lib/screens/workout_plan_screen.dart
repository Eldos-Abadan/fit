import 'dart:io';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';

class WorkoutPlanScreen extends StatefulWidget {
  const WorkoutPlanScreen({Key? key}) : super(key: key);

  @override
  _WorkoutPlanScreenState createState() => _WorkoutPlanScreenState();
}

class _WorkoutPlanScreenState extends State<WorkoutPlanScreen> {
  VideoPlayerController? _videoController;
  File? _videoFile;
  final TextEditingController _titleCtrl = TextEditingController();
  final TextEditingController _detailsCtrl = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _videoController?.dispose();
    _titleCtrl.dispose();
    _detailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result?.files.single.path == null) return;
    final file = File(result!.files.single.path!);
    _videoController?.dispose();
    final ctrl = VideoPlayerController.file(file);
    await ctrl.initialize();
    setState(() {
      _videoFile = file;
      _videoController = ctrl;
    });
    ctrl.play();
  }

  Future<void> _addPlan() async {
    if (_titleCtrl.text.isEmpty) return;
    setState(() => _loading = true);
    // TODO: call ApiService.addWorkoutPlan, send videoFile or details
    bool ok;
    if (_videoFile != null) {
      // enable file upload logic in API
      ok = await ApiService().uploadWorkoutVideoPlan(
        title: _titleCtrl.text,
        video: _videoFile!,
      );
    } else {
      ok = await ApiService().addWorkoutPlan(
        _titleCtrl.text,
        _detailsCtrl.text,
      );
    }
    setState(() => _loading = false);
    final msg = ok ? 'Plan added' : 'Failed to save plan';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Workout Plans'),
        backgroundColor: Colors.purple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 12),
          if (_videoController != null)
            AspectRatio(
              aspectRatio: _videoController!.value.aspectRatio,
              child: VideoPlayer(_videoController!),
            )
          else
            TextField(
              controller: _detailsCtrl,
              maxLines: 4,
              decoration: const InputDecoration(labelText: 'Details'),
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _pickVideo,
                icon: const Icon(Icons.video_library),
                label: const Text('Pick Video'),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : _addPlan,
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Add Plan'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Note: You need to add dependencies in pubspec.yaml:
//   video_player: ^2.5.1
//   file_picker: ^5.0.0

// And implement ApiService.uploadWorkoutVideoPlan to handle multipart file upload.
