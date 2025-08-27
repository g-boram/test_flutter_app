import 'package:flutter/material.dart';

class AlertList extends StatefulWidget {
  const AlertList({super.key});

  @override
  State<AlertList> createState() => _AlertListState();
}

class _AlertListState extends State<AlertList> {
  final List<_AlertItem> _items = [
    _AlertItem(title: '새 메시지', body: '프로모션 소식이 도착했습니다.', time: DateTime.now().subtract(const Duration(minutes: 5))),
    _AlertItem(title: '업데이트', body: '앱이 최신 버전으로 업데이트 되었어요.', time: DateTime.now().subtract(const Duration(hours: 2))),
    _AlertItem(title: '알림', body: '설정에서 알림을 커스터마이즈 해보세요.', time: DateTime.now().subtract(const Duration(days: 1))),
  ];

  Future<void> _refresh() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    setState(() {});
  }

  void _markAllRead() {
    setState(() {
      for (final e in _items) {
        e.read = true;
      }
    });
  }

  void _clearAll() {
    setState(() {
      _items.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('알림'),
        actions: [
          IconButton(
            tooltip: '모두 읽음',
            icon: const Icon(Icons.done_all),
            onPressed: _items.isEmpty ? null : _markAllRead,
          ),
          IconButton(
            tooltip: '모두 삭제',
            icon: const Icon(Icons.clear_all),
            onPressed: _items.isEmpty ? null : _clearAll,
          ),
        ],
      ),
      body: _items.isEmpty
          ? const _EmptyAlerts()
          : RefreshIndicator(
        onRefresh: _refresh,
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemBuilder: (context, i) {
            final item = _items[i];
            return ListTile(
              leading: Stack(
                alignment: Alignment.topRight,
                children: [
                  const CircleAvatar(child: Icon(Icons.notifications)),
                  if (!item.read)
                    const Positioned(
                      right: 0,
                      top: 0,
                      child: CircleAvatar(radius: 6, backgroundColor: Colors.red),
                    ),
                ],
              ),
              title: Text(
                item.title,
                style: TextStyle(fontWeight: item.read ? FontWeight.w400 : FontWeight.w700),
              ),
              subtitle: Text(item.body, maxLines: 2, overflow: TextOverflow.ellipsis),
              trailing: Text(_fmtTime(item.time), style: Theme.of(context).textTheme.bodySmall),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => _AlertDetailPage(item: item)),
                );
                if (!mounted) return;
                setState(() => item.read = true);
              },
            );
          },
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemCount: _items.length,
        ),
      ),
    );
  }

  String _fmtTime(DateTime t) {
    final now = DateTime.now();
    final diff = now.difference(t);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    return '${diff.inDays}일 전';
  }
}

class _EmptyAlerts extends StatelessWidget {
  const _EmptyAlerts();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('알림이 없습니다', style: TextStyle(color: Colors.grey)),
    );
    // 필요하면 빈 상태에 일러스트/버튼 추가
  }
}

class _AlertDetailPage extends StatelessWidget {
  const _AlertDetailPage({super.key, required this.item});
  final _AlertItem item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알림 상세')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(item.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(item.body, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            Text('받은 시각: ${item.time}'),
          ],
        ),
      ),
    );
  }
}

class _AlertItem {
  _AlertItem({required this.title, required this.body, required this.time, this.read = false});
  final String title;
  final String body;
  final DateTime time;
  bool read;
}
