import 'package:flutter/material.dart';

Widget errorContainer({
  required String errorMessageCode,
  required VoidCallback onTapRetry,
}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 50),
    child: Column(
      children: [
        Text('No messages yet ' + errorMessageCode),
        ElevatedButton(
          onPressed: onTapRetry,
          child: const Text('Retry'),
        ),
      ],
    ),
  );
}
