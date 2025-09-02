import 'package:flutter/material.dart';

import 'package:test_app/core/common.dart';
import 'package:test_app/shared/widgets/buttons/round_button_theme.dart';
import 'package:test_app/shared/widgets/buttons/w_round_button.dart';

/// ✅ Scaffold/AppBar 없이 '본문'만 그리는 프래그먼트
class SampleDialogsFragment extends StatelessWidget {
  const SampleDialogsFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.appColors.seedColor,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1) Info (중앙)
          ElevatedButton(
            onPressed: () async {
              await showInfoDialog(
                context,
                title: '정보',
                message: '저장되었습니다.',
              );
              _snack(context, 'Info 닫힘');
            },
            child: const Text('Show Info (Center)'),
          ),
          const SizedBox(height: 12),

          // 2) Confirm (파괴적 OK, 상단)
          ElevatedButton(
            onPressed: () async {
              final ok = await showConfirmDialog(
                context,
                title: '삭제',
                message: '정말 삭제하시겠어요?',
                okText: '삭제',
                cancelText: '취소',
                destructive: true,
                position: DialogPosition.top,
              );
              _snack(context, 'Confirm 결과: $ok');
            },
            child: const Text('Show Confirm (Destructive, Top)'),
          ),
          const SizedBox(height: 12),

          // 3) Input (중앙)
          ElevatedButton(
            onPressed: () async {
              final text = await showInputDialog(
                context,
                title: '이름 변경',
                message: '새 이름을 입력하세요.',
                okText: '저장',
                cancelText: '취소',
              );
              _snack(context, 'Input 결과: ${text ?? "(취소)"}');
            },
            child: const Text('Show Input (Center)'),
          ),
          const SizedBox(height: 12),

          // 4) Custom (폰트/사이즈/버튼 커스텀)
          ElevatedButton(
            onPressed: () async {
              final result = await showAppDialog<bool>(
                context,
                params: AppDialogParams(
                  title: '맞춤 다이얼로그',
                  message:
                  '폰트 두께/사이즈, 최대 너비, 라운드, 커스텀 액션 버튼까지 모두 지정한 예시입니다.',
                  titleStyle: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                  messageStyle: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 15),
                  maxWidth: 560,
                  borderRadius: 20,
                  position: DialogPosition.center,
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).maybePop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton.icon(
                      onPressed: () => Navigator.of(context).maybePop(true),
                      icon: const Icon(Icons.check),
                      label: const Text('OK'),
                    ),
                  ],
                ),
              );
              _snack(context, 'Custom 결과: $result');
            },
            child: const Text('Show Custom (Fonts/Size/Actions)'),
          ),
          const SizedBox(height: 12),

          // 5) BottomSheet
          ElevatedButton(
            onPressed: () async {
              final res = await showAppBottomSheet<String>(
                context,
                builder: (ctx) {
                  final cs = Theme.of(ctx).colorScheme;
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 6),
                      Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: cs.outlineVariant,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListTile(
                        leading: const Icon(Icons.photo),
                        title: const Text('갤러리에서 선택'),
                        onTap: () => Navigator.pop(ctx, 'gallery'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('카메라로 촬영'),
                        onTap: () => Navigator.pop(ctx, 'camera'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.close),
                        title: const Text('닫기'),
                        onTap: () => Navigator.pop(ctx, 'close'),
                      ),
                      const SizedBox(height: 8),
                    ],
                  );
                },
              );
              _snack(context, 'BottomSheet 결과: $res');
            },
            child: const Text('Show BottomSheet'),
          ),

          // ──────────────────────────────
          // 아래는 네가 기존에 쓰던 RoundButton 기반 테스트
          // (ListView 안의 Column에서는 Spacer를 쓰면 에러가 나서 SizedBox로 변경)
          // ──────────────────────────────
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                const SizedBox(height: 12),
                RoundButton(
                  text: 'Snackbar 보이기',
                  onTap: () => _showSnackbar(context),
                  theme: RoundButtonTheme.blue,
                ),
                const SizedBox(height: 20),
                RoundButton(
                  text: 'Confirm 다이얼로그(커스텀)',
                  onTap: () => _showCustomConfirmDialog(context), // ← 이름 충돌 방지
                  theme: RoundButtonTheme.whiteWithBlueBorder,
                ),
                const SizedBox(height: 20),
                RoundButton(
                  text: 'Message 다이얼로그(커스텀)',
                  onTap: _showCustomMessageDialog,               // ← 이름 충돌 방지
                  theme: RoundButtonTheme.whiteWithBlueBorder,
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 스낵바(공용 확장 사용)
  void _showSnackbar(BuildContext context) {
    context.showSnackbar(
      'snackbar 입니다.',
      extraButton: TextButton(
        onPressed: () => context.showErrorSnackbar('error'),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
        ),
        child: const Text('에러 보여주기 버튼', style: TextStyle(fontSize: 13)),
      ),
    );
  }

  // ⬇️ 기존 네가 쓰던 커스텀 Confirm/Message 다이얼로그와 이름이 겹치지 않게 변경
  Future<void> _showCustomConfirmDialog(BuildContext context) async {
    // 아래 ConfirmDialog/ColorBottomSheet/MessageDialog는
    // 네 프로젝트에 이미 있는 커스텀 컴포넌트라고 가정
    final confirmDialogResult = await ConfirmDialog(
      '오늘 기분이 좋나요?',
      buttonText: "네",
      cancelButtonText: "아니오",
    ).show();

    debugPrint(confirmDialogResult?.isSuccess.toString());

    confirmDialogResult?.runIfSuccess((data) {
      ColorBottomSheet(
        '❤️',
        context: context,
        backgroundColor: Colors.yellow.shade200,
      ).show();
    });

    confirmDialogResult?.runIfFailure((data) {
      ColorBottomSheet(
        '❤️힘내여',
        backgroundColor: Colors.yellow.shade300,
        textColor: Colors.redAccent,
      ).show();
    });
  }

  Future<void> _showCustomMessageDialog() async {
    final result = await MessageDialog("안녕하세요").show();
    debugPrint(result.toString());
  }

  void _snack(BuildContext context, String msg) {
    final cs = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: cs.inverseSurface,
          content: Text(msg, style: TextStyle(color: cs.onInverseSurface)),
        ),
      );
  }
}
