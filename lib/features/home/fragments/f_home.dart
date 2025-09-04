import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:test_app/shared/widgets/dialogs/d_base_dialog.dart';
import 'package:test_app/shared/widgets/dialogs/d_info_dialog.dart';
import 'package:test_app/shared/widgets/text/w_base_text.dart';

import 'package:test_app/core/common.dart';

import '../../attendance/screen/s_checkin.dart';



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
        GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 24,
          mainAxisSpacing: 24,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            ExampleTile(
              title: '출석 체크',
              filePath: 'lib/shared/widgets/buttons/w_card_button.dart',
              showFileHints: showFileHints,
              child: CardButton(
                icon: Icons.qr_code_scanner,
                label: 'home.attendance'.tr(),
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CheckinScreen()),
                ),
              ),
            ),
            ExampleTile(
              title: '공지(Info Dialog)',
              filePath: 'lib/shared/widgets/dialogs/w_infoDialog.dart',
              showFileHints: showFileHints,
              child: CardButton(
                icon: Icons.campaign,
                label: 'home.notice'.tr(),
                  onTap: (){}
              ),
            ),
            ExampleTile(
              title: '도움말(Confirm Dialog)',
              filePath: 'lib/shared/widgets/dialogs/w_confirmDialog.dart',
              showFileHints: showFileHints,
              child: CardButton(
                icon: Icons.help_outline,
                label: 'home.help'.tr(),
                  onTap: (){}
              ),
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

            // 기본(브랜드 색)
            BaseButton(label: 'common.save', onPressed: (){}),

            // Tonal
            BaseButton(label: 'common.done', variant: BaseBtnVariant.tonal, onPressed: (){}),

            // Outlined
            BaseButton(label: 'common.cancel', variant: BaseBtnVariant.outlined, onPressed: (){}),

            // Text
            BaseButton(label: 'common.ok', variant: BaseBtnVariant.text, onPressed: (){}),

            // 파괴적(삭제 등) — 색 자동 전환
            BaseButton(
              label: 'common.delete',
              variant: BaseBtnVariant.filled, // 또는 tonal/outlined/text
              destructive: true,
              onPressed: (){}
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
            const SizedBox(width: 50),
            ExampleInline(
              filePath: 'lib/shared/widgets/buttons/w_base_button.dart',
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
          ],
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
              filePath: 'lib/shared/widgets/dialogs/d_infoDialog.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'd_infoDialog',
                  variant: BaseBtnVariant.filled,
                  onPressed: () => InfoDialog.show(
                    context,
                    title: 'test',
                    message: 'test',
                  ),
                ),
              ),
            ),

            ExampleInline(
              filePath: 'lib/shared/widgets/dialogs/d_confirmDialog.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'd_confirmDialog',
                  variant: BaseBtnVariant.filled,
                  onPressed: () async {
                    final ok = await ConfirmDialog.confirm(
                      context,
                      title: 'test',
                      message: 'test',
                    );
                    if (!mounted) return;
                    _toast(context, ok == true ? '진행' : '취소');
                  },
                ),
              ),
            ),

            ExampleInline(
              filePath: 'lib/shared/widgets/dialogs/d_confirmDialog.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'd_confirmDialog-error',
                  variant: BaseBtnVariant.tonal,
                  onPressed: () async {
                    final ok = await ConfirmDialog.delete(
                      context,
                      title: 'test',
                      message: 'test',
                    );
                    if (!mounted) return;
                    _toast(context, ok == true ? '진행' : '취소');
                  },
                ),
              ),
            ),

            ExampleInline(
              filePath: 'lib/shared/widgets/dialogs/d_text_field_dialog.dart',
              showFileHints: showFileHints,
              child: SizedBox(
                width: 220,
                child: BaseButton(
                  label: 'd_text_field_dialog',
                  variant: BaseBtnVariant.outlined,
                  onPressed: () async {

                    // 2) 한 줄 입력 (Enter=완료)
                    // final name = await InputDialog.prompt(
                    //   context,
                    //   title: 'dialog.name.title',
                    //   message: 'dialog.name.desc',
                    //   hintText: 'dialog.name.hint',
                    //   required: true,
                    // );

                    // 3) 여러 줄 입력 (Enter=줄바꿈)
                    final memo = await InputDialog.prompt(
                      context,
                      title: 'dialog.memo.title',
                      message: 'dialog.memo.desc',
                      hintText: 'dialog.memo.hint',
                      maxLines: 4,
                      confirmText: 'common.save',
                      cancelText: 'common.close',
                    );
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
                                hintText: '예) 점검 완료',
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          BaseButton(
                            label: 'common.close',
                            variant: BaseBtnVariant.outlined,
                            size: BaseBtnSize.sm,
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          BaseButton(
                            label: 'common.save',
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
        const Divider(height: 1),

        // 4) 공통 텍스트 사용 예시
        const _SectionTitle(title: 'Text Playground'),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 기본: 키로 번역됨 (isKey 생략 = true)
            AppText.title('app.title'),
            AppText.subtitle('home.title', muted: true),

            // 평문 그대로 표시하고 싶을 때만 isKey: false
            AppText.title('교실 키오스크', isKey: false),
            AppText.body('버전 1.0.0', isKey: false),
          ],
        )

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
