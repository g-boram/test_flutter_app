import 'package:flutter/material.dart';

Future<T?> showAppBottomSheet<T>(
    BuildContext context, {
      required WidgetBuilder builder,
      bool isScrollControlled = true,
      double? maxWidth = 640,
    }) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Theme.of(context).colorScheme.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final content = builder(ctx);
      return SafeArea(
        child: LayoutBuilder(
          builder: (_, constraints) {
            final useNarrow = (maxWidth ?? 640) >= constraints.maxWidth;
            final body = Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
                left: 16, right: 16, top: 12,
              ),
              child: content,
            );
            return useNarrow
                ? body
                : Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth ?? 640),
                child: body,
              ),
            );
          },
        ),
      );
    },
  );
}
