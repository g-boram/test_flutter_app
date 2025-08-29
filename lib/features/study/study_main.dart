// study_main.dart
import 'package:flutter/material.dart';
import 'package:test_app/features/study/collection/ui_study_collection.dart'; // CafeKioskPage 경로 맞게

class StudyMain extends StatelessWidget {
  const StudyMain({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ 버튼으로 만들 항목들
    final DartEntries = <Map<String, String>>[
      {'title': '커피주문 예제로 공부하는 List, Set, Map, Generic 예제', 'desc': '직접 실행하며 메뉴 추가 → 재고/프로모션 → 주문 → 금액 계산 → 분석 흐름을 따라가 보기'},

    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Simple Navigation')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: DartEntries.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) {
            final e = DartEntries[i];
            return SizedBox(
              height: 56, // 한 줄 버튼 높이
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      // ✅ title/desc 함께 전달
                      builder: (_) => CafeKioskPage(
                        title: e['title'],
                        desc: e['desc'],
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.arrow_forward),
                label: Align(
                  alignment: Alignment.centerLeft, // 텍스트를 왼쪽 정렬로
                  child: Text(e['title']!),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
