// lib/features/styleguide/base_text_showcase.dart
import 'package:flutter/material.dart';
import 'package:test_app/shared/widgets/typography/w_base_text.dart';


class BaseTextShowcase extends StatelessWidget {
  const BaseTextShowcase({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('BaseText Showcase')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 1) 기본 사용: 기본 kind = title (번역 키 tr() 자동)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: BaseText('title.home'), // == BaseText.title('title.home')
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 2) 서브타이틀 프리셋
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: BaseText(
                'title.home',
                kind: BaseTextKind.subtitle,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3) 본문 프리셋 + 왼쪽 정렬
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: BaseText(
                'title.home',
                kind: BaseTextKind.body,
                align: TextAlign.left,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 4) 작은 라벨 프리셋 + 오른쪽 정렬
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: BaseText(
                'title.home',
                kind: BaseTextKind.labelSm,
                align: TextAlign.right,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 5) 번역 없이 그대로 사용 (translate: false)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: BaseText(
                'title.home',
                translate: false,           // ← JSON 키가 아니라 이미 번역된 문자열
                kind: BaseTextKind.body,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 6) size/weight 커스텀: 타이틀 스타일이지만 크기만 40으로
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: BaseText(
                  'title.home',
                  size: 40,                 // 기본 title(32)보다 크게
                  // weight 미설정 → title 기본 w800 유지
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 7) weight만 얇게 (본문 스타일 + w300)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: BaseText(
                'title.home',
                kind: BaseTextKind.body,
                weight: FontWeight.w300,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 8) 색상 커스텀: primary 컬러로
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BaseText(
                'title.home',
                kind: BaseTextKind.subtitle,
                color: cs.primary,          // 라이트/다크 모드 자동 대응
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 9) maxLines + height(줄간격) 커스텀
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: BaseText(
                'title.home',     // 긴 문장이라고 가정
                kind: BaseTextKind.body,
                maxLines: 2,                // 2줄까지만 표시
                height: 1.6,                // 줄간격
                align: TextAlign.justify,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 10) 조합 예: subtitle + size/weight/color/align 모두 커스텀
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: BaseText(
                'title.home',
                kind: BaseTextKind.subtitle, // 베이스는 subtitle
                size: 22,                    // 살짝 크게
                weight: FontWeight.w600,     // 약간 굵게
                color: cs.secondary,         // 보조 색
                align: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 11) 가운데 큰 타이틀: 홈 중앙 표기 예시 그대로
          const Card(
            child: SizedBox(
              height: 160,
              child: Center(
                child: BaseText(
                  'title.home',
                  // kind: BaseTextKind.title (기본값)
                  size: 36,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
