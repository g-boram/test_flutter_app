import 'package:flutter/material.dart';

enum DialogPosition { center, top }

class AppDialogParams {
  final String? title;
  final String? message;

  final TextStyle? titleStyle;
  final TextStyle? messageStyle;

  final Widget? leading;              // 아이콘/로고 등
  final List<Widget>? actions;        // 커스텀 액션(없으면 기본 OK/Cancel)

  final bool barrierDismissible;
  final DialogPosition position;
  final double topOffset;             // position == top 일 때 상단 여백
  final double? maxWidth;             // 웹/태블릿에서 유용
  final EdgeInsetsGeometry? margin;   // 화면 가장자리 여백
  final EdgeInsetsGeometry? padding;  // 카드 내부 패딩
  final double borderRadius;

  // 기본 버튼 텍스트 (actions가 null일 때 사용)
  final String okText;
  final String cancelText;
  final bool showCancel;
  final bool destructive;             // OK 버튼을 error 색으로

  const AppDialogParams({
    this.title,
    this.message,
    this.titleStyle,
    this.messageStyle,
    this.leading,
    this.actions,
    this.barrierDismissible = true,
    this.position = DialogPosition.center,
    this.topOffset = 56,
    this.maxWidth = 480,
    this.margin,
    this.padding,
    this.borderRadius = 16,
    this.okText = 'OK',
    this.cancelText = 'Cancel',
    this.showCancel = true,
    this.destructive = false,
  });
}

/// 내용 위젯을 감싸는 공통 카드
class AppDialogCard extends StatelessWidget {
  final AppDialogParams params;

  const AppDialogCard({super.key, required this.params});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final margin = params.margin ??
        const EdgeInsets.symmetric(horizontal: 24, vertical: 24);
    final padding = params.padding ??
        const EdgeInsets.fromLTRB(20, 20, 20, 12);

    final titleStyle = params.titleStyle ??
        Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w700,
          color: cs.onSurface,
        );
    final messageStyle = params.messageStyle ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: cs.onSurfaceVariant,
        );

    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: params.maxWidth ?? 480),
      child: Material(
        color: cs.surface,   // 라이트/다크 자동
        elevation: 3,
        borderRadius: BorderRadius.circular(params.borderRadius),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: padding,
          child: IntrinsicWidth(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 헤더
                if (params.title != null || params.leading != null)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (params.leading != null) ...[
                        params.leading!,
                        const SizedBox(width: 12),
                      ],
                      Expanded(
                        child: Text(
                          params.title ?? '',
                          style: titleStyle,
                        ),
                      ),
                    ],
                  ),
                if ((params.title != null || params.leading != null) &&
                    params.message != null)
                  const SizedBox(height: 8),

                // 본문
                if (params.message != null)
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Text(
                        params.message!,
                        style: messageStyle,
                      ),
                    ),
                  ),

                const SizedBox(height: 12),

                // 액션
                Align(
                  alignment: Alignment.centerRight,
                  child: ButtonBar(
                    alignment: MainAxisAlignment.end,
                    children: params.actions ?? _defaultActions(context, cs),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).padding(margin);
  }

  List<Widget> _defaultActions(BuildContext context, ColorScheme cs) {
    final okStyle = params.destructive
        ? ElevatedButton.styleFrom(
      backgroundColor: cs.error,
      foregroundColor: cs.onError,
    )
        : ElevatedButton.styleFrom();

    return [
      if (params.showCancel)
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(false),
          child: Text(params.cancelText),
        ),
      ElevatedButton(
        style: okStyle,
        onPressed: () => Navigator.of(context).maybePop(true),
        child: Text(params.okText),
      ),
    ];
  }
}

/// EdgeInsets padding 헬퍼 (의존성 없이 편의용)
extension on Widget {
  Widget padding(EdgeInsetsGeometry value) =>
      Padding(padding: value, child: this);
}
