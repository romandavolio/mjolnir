import 'package:flutter/material.dart';
import 'package:mjolnir/core/app_colors.dart';

class NoteEditorScreen extends StatefulWidget {
  final String title;
  final String? initialNote;

  const NoteEditorScreen({
    super.key,
    required this.title,
    this.initialNote,
  });

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late TextEditingController _controller;

  final List<String> _emojis = [
    '💪', '🔥', '⚡', '🎯', '✅', '⚠️', '😤', '🏋️',
    '📈', '💡', '🔁', '❗', '👀', '🧠', '😅', '🙌',
  ];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialNote ?? '');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.backgroundAppBar,
        foregroundColor: AppColors.primary,
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context, _controller.text.trim()),
            child: Text('Guardar',
                style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Campo de texto
            TextField(
              controller: _controller,
              style: const TextStyle(color: Colors.white),
              maxLines: 6,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Escribí tu nota acá...',
                hintStyle:
                    const TextStyle(color: AppColors.textSecondary),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors.primary.withValues(alpha: 0.4)),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Emojis predefinidos
            const Text('EMOJIS RÁPIDOS',
                style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _emojis.map((emoji) => GestureDetector(
                    onTap: () {
                      final pos = _controller.selection.base.offset;
                      final text = _controller.text;
                      final newText = pos >= 0
                          ? text.substring(0, pos) +
                              emoji +
                              text.substring(pos)
                          : text + emoji;
                      _controller.text = newText;
                      _controller.selection = TextSelection.fromPosition(
                        TextPosition(
                            offset: (pos >= 0 ? pos : text.length) +
                                emoji.length),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: AppColors.primary
                                .withValues(alpha: 0.2)),
                      ),
                      child: Text(emoji,
                          style: const TextStyle(fontSize: 20)),
                    ),
                  )).toList(),
            ),

            const Spacer(),

            // Botón limpiar nota
            if (_controller.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  setState(() => _controller.clear());
                },
                child: const Text('Limpiar nota',
                    style: TextStyle(color: Colors.redAccent)),
              ),
          ],
        ),
      ),
    );
  }
}