import 'package:flutter/material.dart';
import 'package:test_app/core/common.dart';

class NewScreenFragments extends StatelessWidget {
  const NewScreenFragments({super.key});

  @override
  Widget build(BuildContext context) {
    // 필요 시 ViewModel/Controller 주입/리스닝은 여기서!
    return ListView(
      padding: const EdgeInsets.all(8),
      children: [
        // 예시 카드 1
        Card(
          child: ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text('title.new_screen'.tr()),
            subtitle: Text('desc.new_screen'.tr()),
          ),
        ),
        const Height(12),

        // 예시: 액션 버튼
        FilledButton.icon(
          onPressed: () {
            // TODO: 액션
          },
          icon: const Icon(Icons.play_arrow),
          label: Text('버튼 예제'),
        ),

        // … 필요한 위젯들 추가
      ],
    );
  }
}
