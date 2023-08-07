import 'package:flutter/material.dart';

class ProgressDialog extends StatefulWidget {
  final double value;

  const ProgressDialog({Key? key, required this.value}) : super(key: key);

  @override
  ProgressDialogState createState() => ProgressDialogState();
}

class ProgressDialogState extends State<ProgressDialog> {
  double progress = 0.0;

  @override
  void initState() {
    super.initState();
    progress = widget.value;
  }

  void updateProgress(double value) {
    setState(() {
      progress = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Center(child: Text('Downloading')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LinearProgressIndicator(
            value: progress,
            minHeight: 7.0,
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}