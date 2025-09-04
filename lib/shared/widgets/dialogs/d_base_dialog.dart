import 'package:flutter/material.dart';
import 'package:test_app/shared/widgets/text/w_base_text.dart';

enum DialogActionsAxis { auto, horizontal, vertical }

class BaseDialog extends StatelessWidget {
  final Widget? icon;

  // String vs 커스텀 위젯
  final String? title;
  final Widget? titleWidget;
  final bool titleIsKey;

  final String? message;
  final Widget? content;
  final bool messageIsKey;

  final List<Widget> actions;

  // 레이아웃 옵션
  final EdgeInsets insetPadding;
  final EdgeInsets contentPadding;
  final double radius;

  // ⬇️ 추가된 미관/배치 옵션
  final double maxWidth;            // 다이얼로그 최대 폭
  final double maxHeightFactor;     // 화면 높이 대비 최대 비율
  final DialogActionsAxis actionsAxis;
  final double actionsSpacing;      // 버튼 간격
  final bool showCloseButton;       // 오른쪽 상단 X 버튼

  const BaseDialog({
    super.key,
    this.icon,
    this.title,
    this.titleWidget,
    this.titleIsKey = true,
    this.message,
    this.content,
    this.messageIsKey = true,
    this.actions = const [],
    this.insetPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
    this.contentPadding = const EdgeInsets.fromLTRB(24, 16, 24, 12),
    this.radius = 20,

    // ⬇️ 기본값
    this.maxWidth = 560,
    this.maxHeightFactor = 0.86,
    this.actionsAxis = DialogActionsAxis.auto,
    this.actionsSpacing = 12,
    this.showCloseButton = false,
  });

  @override
  Widget build(BuildContext context) {
    // 본문: content가 있으면 그대로, 없으면 message(AppText) 사용
    final Widget body = content ??
        (message != null
            ? AppText.body(message!, isKey: messageIsKey)
            : const SizedBox.shrink());

    // 타이틀: titleWidget이 있으면 그대로, 없으면 title(AppText) 사용
    final Widget? titleNode = titleWidget ??
        (title != null
            ? AppText.title(title!, isKey: titleIsKey)
            : null);

    final size = MediaQuery.sizeOf(context);
    final isNarrow = size.width < 420;

    final bool stackVertical = switch (actionsAxis) {
      DialogActionsAxis.vertical => true,
      DialogActionsAxis.horizontal => false,
      DialogActionsAxis.auto => isNarrow || actions.length >= 3,
    };

    return Dialog(
      insetPadding: insetPadding,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: maxWidth,
          // 내부 스크롤을 위해 높이만 제한
          maxHeight: size.height * maxHeightFactor,
        ),
        child: Padding(
          padding: contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 상단 X 버튼(선택)
              if (showCloseButton)
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                ),

              if (icon != null) ...[icon!, const SizedBox(height: 12)],
              if (titleNode != null) ...[titleNode, const SizedBox(height: 8)],

              // 본문은 길어질 수 있으니 스크롤 가능하게
              Flexible(
                child: SingleChildScrollView(
                  child: body,
                ),
              ),

              const SizedBox(height: 16),

              // 액션 영역: 가로/세로 자동 배치
              if (actions.isNotEmpty)
                stackVertical
                    ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _intersperse(
                    actions
                        .map((w) => SizedBox(width: double.infinity, child: w))
                        .toList(),
                    SizedBox(height: actionsSpacing),
                  ),
                )
                    : Row(
                  children: _intersperse(
                    [
                      for (final w in actions) Expanded(child: w),
                    ],
                    SizedBox(width: actionsSpacing),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // 위젯 리스트 사이에 구분자를 끼워 넣는 헬퍼
  List<Widget> _intersperse(List<Widget> widgets, Widget separator) {
    if (widgets.isEmpty) return widgets;
    final out = <Widget>[];
    for (var i = 0; i < widgets.length; i++) {
      out.add(widgets[i]);
      if (i != widgets.length - 1) out.add(separator);
    }
    return out;
  }
}
