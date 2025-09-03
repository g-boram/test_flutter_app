import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:test_app/shared/widgets/dialogs/d_baseDialog.dart';
import 'package:test_app/shared/widgets/dialogs/d_confirmDialog.dart';
import 'package:test_app/shared/widgets/dialogs/d_infoDialog.dart';

// 기능 이동 (출석)
import '../../attendance/screen/s_checkin.dart';

// 공통 버튼/다이얼로그
import '../../../shared/widgets/buttons/w_cardButton.dart';        // lib/shared/widgets/buttons/w_cardButton.dart
import '../../../shared/widgets/buttons/w_baseButton.dart';        // lib/shared/widgets/buttons/w_baseButton.dart


class HomeFragment extends StatefulWidget {
  const HomeFragment({super.key});

  @override
  State<HomeFragment> createState() => _HomeFragmentState();
}

class _HomeFragmentState extends State<HomeFragment> {
  bool _loading = false;

  // 개발용: 파일 경로 캡션 표시 여부
  static const bool showFileHints = true;

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // 1) 기능 카드 (CardButton) + 파일 경로
        const _SectionTitle(title: '기능 카드 (CardButton)'),
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ExampleTile(
              title: '출석 체크',
              filePath: 'lib/shared/widgets/buttons/w_cardButton.dart',
              child: CardButton(
                icon: Icons.qr_code_scanner,
                label: 'home.attendance'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckinScreen()),
                ),
              ),
              showFileHints: showFileHints,
            ),
            ExampleTile(
              title: '공지(Info Dialog)',
              filePath: 'lib/shared/widgets/dialogs/w_infoDialog.dart',
              child: CardButton(
                icon: Icons.campaign,
                label: 'home.notice'.tr(),
                onTap: () => showInfoDialog(
                  context,
                  title: '공지',
                  message: '공지 기능은 다음 단계에서 연결할 예정입니다.',
                ),
              ),
              showFileHints: showFileHints,
            ),
            ExampleTile(
              title: '도움말(Confirm Dialog)',
              filePath: 'lib/shared/widgets/dialogs/w_confirmDialog.dart',
              child: CardButton(
                icon: Icons.help_outline,
                label: 'home.help'.tr(),
                onTap: () async {
                  final ok = await showConfirmDialog(
                    context,
                    title: '도움말',
                    message: '출석은 QR 스캔 또는 학번 입력으로 진행합니다.\n이 안내를 더 이상 보지 않을까요?',
                    confirmText: '예',
                    cancelText: '아니오',
                  );
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(ok == true ? '다음부터 도움말 숨김' : '유지합니다')),
                  );
                },
              ),
              showFileHints: showFileHints,
            ),
          ],
        ),

        const SizedBox(height: 24),
        const Divider(height: 1),

        // 2) BaseButton 플레이그라운드 + 파일 경로
        const _SectionTitle(title: 'BaseButton Playground'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ExampleInline(
              filePath: 'lib/shared/widgets/buttons/w_baseButton.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'Filled',
                  variant: BaseBtnVariant.filled,
                  size: BaseBtnSize.md,
                  leadingIcon: Icons.check_circle,
                  onPressed: () => _toast(context, 'Filled tapped'),
                ),
              ),
            ),
            ExampleInline(
              filePath: 'lib/shared/widgets/buttons/w_baseButton.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'Tonal',
                  variant: BaseBtnVariant.tonal,
                  size: BaseBtnSize.md,
                  trailingIcon: Icons.arrow_forward,
                  onPressed: () => _toast(context, 'Tonal tapped'),
                ),
              ),
            ),
            ExampleInline(
              filePath: 'lib/shared/widgets/buttons/w_baseButton.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'Outlined',
                  variant: BaseBtnVariant.outlined,
                  size: BaseBtnSize.md,
                  onPressed: () => _toast(context, 'Outlined tapped'),
                ),
              ),
            ),
            ExampleInline(
              filePath: 'lib/shared/widgets/buttons/w_baseButton.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'Text',
                  variant: BaseBtnVariant.text,
                  size: BaseBtnSize.md,
                  onPressed: () => _toast(context, 'Text tapped'),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),
        Row(
          children: [
            Switch(
              value: _loading,
              onChanged: (v) => setState(() => _loading = v),
            ),
            const SizedBox(width: 8),
            const Text('Loading 토글'),
          ],
        ),
        ExampleInline(
          filePath: 'lib/shared/widgets/buttons/w_baseButton.dart',
          showFileHints: showFileHints,
          child: SizedBox(
            width: 340,
            child: BaseButton(
              label: _loading ? '처리 중…' : '로딩 버튼 테스트',
              variant: BaseBtnVariant.filled,
              size: BaseBtnSize.lg,
              loading: _loading,
              onPressed: () async {
                setState(() => _loading = true);
                await Future.delayed(const Duration(seconds: 1));
                if (!mounted) return;
                setState(() => _loading = false);
                _toast(context, '완료!');
              },
            ),
          ),
        ),

        const SizedBox(height: 24),
        const Divider(height: 1),

        // 3) 다이얼로그 플레이그라운드 + 파일 경로
        const _SectionTitle(title: 'Dialog Playground'),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ExampleInline(
              filePath: 'lib/shared/widgets/dialogs/w_infoDialog.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'showInfoDialog',
                  variant: BaseBtnVariant.filled,
                  onPressed: () => showInfoDialog(
                    context,
                    title: '안내',
                    message: '이것은 공통 Info 다이얼로그입니다.',
                  ),
                ),
              ),
            ),
            ExampleInline(
              filePath: 'lib/shared/widgets/dialogs/w_confirmDialog.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'showConfirmDialog',
                  variant: BaseBtnVariant.tonal,
                  onPressed: () async {
                    final ok = await showConfirmDialog(
                      context,
                      title: '확인',
                      message: '이 작업을 진행할까요?',
                    );
                    if (!mounted) return;
                    _toast(context, ok == true ? '진행' : '취소');
                  },
                ),
              ),
            ),
            ExampleInline(
              filePath: 'lib/shared/widgets/dialogs/w_baseDialog.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'Custom BaseDialog',
                  variant: BaseBtnVariant.outlined,
                  onPressed: () => showDialog<void>(
                    context: context,
                    builder: (_) {
                      final controller = TextEditingController();
                      return BaseDialog(
                        title: '커스텀 입력',
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('메모를 입력하세요'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: controller,
                              maxLines: 3,
                              decoration: const InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: '예) 교실 비품 점검 완료',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          BaseButton(
                            label: '닫기',
                            variant: BaseBtnVariant.outlined,
                            size: BaseBtnSize.sm,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          BaseButton(
                            label: '저장',
                            variant: BaseBtnVariant.filled,
                            size: BaseBtnSize.sm,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _toast(context, '저장됨: ${controller.text}');
                            },
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

/// 섹션 헤더
class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}

/// 예제 타일(그리드용): 카드 + 파일 경로 캡션
class ExampleTile extends StatelessWidget {
  final String title;
  final String filePath;
  final bool showFileHints;
  final Widget child;

  const ExampleTile({
    super.key,
    required this.title,
    required this.filePath,
    required this.child,
    this.showFileHints = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 카드 자체 비율 유지
        AspectRatio(aspectRatio: 1.1, child: child),
        if (showFileHints) const SizedBox(height: 5),
        if (showFileHints)
          FileHint(path: filePath),
      ],
    );
  }
}

/// 인라인 예제(버튼/트리거 + 파일 경로 캡션)
class ExampleInline extends StatelessWidget {
  final Widget child;
  final String filePath;
  final bool showFileHints;

  const ExampleInline({
    super.key,
    required this.child,
    required this.filePath,
    this.showFileHints = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        child,
        if (showFileHints) const SizedBox(height: 5),
        if (showFileHints) FileHint(path: filePath),
      ],
    );
  }
}

/// 파일 경로 캡션(모노스페이스, 작은 글씨)
class FileHint extends StatelessWidget {
  final String path;
  const FileHint({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
      fontFamily: 'monospace',
      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
    );
    return Text(path, style: style, overflow: TextOverflow.ellipsis);
  }
}
