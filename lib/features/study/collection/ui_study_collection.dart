import 'package:flutter/material.dart';
import 'study_collection.dart';

class CafeKioskPage extends StatefulWidget {
  const CafeKioskPage({super.key, this.title, this.desc});

  final String? title;
  final String? desc;

  @override
  State<CafeKioskPage> createState() => _CafeKioskPageState();
}

class _CafeKioskPageState extends State<CafeKioskPage> {
  late final CafeInventory inv;
  late final PriceCalculator calc;

  // 화면 상태
  final Set<String> allergenBlacklist = {'nuts'};
  final Set<String> requireTags = {}; // {'ice'} 등
  final List<OrderLine> cart = []; // List
  String? promo;

  @override
  void initState() {
    super.initState();
    inv = seed();
    calc = PriceCalculator(inv);
  }

  List<MenuItem> get visibleMenu {
    // 알레르기 필터 → 태그 필터
    final safe = inv.filterByAllergenBlacklist(allergenBlacklist);
    if (requireTags.isEmpty) return safe;
    return safe.where((m) => requireTags.every((t) => m.tags.contains(t))).toList();
  }

  void _addToCart(MenuItem m) {
    // 같은 아이템이면 qty 증가 (간단화)
    final idx = cart.indexWhere((l) => l.itemId == m.id && l.options.isEmpty);
    setState(() {
      if (idx == -1) {
        cart.add(OrderLine(itemId: m.id, qty: 1, options: {}));
      } else {
        final line = cart[idx];
        cart[idx] = OrderLine(
          itemId: line.itemId,
          qty: line.qty + 1,
          options: line.options,
        );
      }
    });
  }

  int _calcSubtotal() {
    final o = Order(id: 1, lines: cart, promoCode: promo);
    final r = calc.subtotal(o);
    return r.isOk ? r.data! : 0;
  }

  int _calcTotal() {
    final o = Order(id: 1, lines: cart, promoCode: promo);
    final r = calc.totalWithPromotion(o);
    return r.isOk ? r.data! : 0;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Cafe Kiosk (List/Map/Set/Generic)'),
      ),
      body: Column(
        children: [
          if ((widget.desc ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.desc!,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ),
            ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(
              children: [
                // 왼쪽: 필터 & 메뉴
                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      _Filters(
                        allergenBlacklist: allergenBlacklist,
                        requireTags: requireTags,
                        onChanged: () => setState(() {}),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: MediaQuery.of(context).size.width > 1000 ? 3 : 2,
                          padding: const EdgeInsets.all(16),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          children: [
                            for (final m in visibleMenu)
                              InkWell(
                                onTap: () => _addToCart(m),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        m.name,
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text('${m.price}원'),
                                      const Spacer(),
                                      Wrap(
                                        spacing: 6,
                                        children: m.tags
                                            .map((t) => Chip(
                                          label: Text(t),
                                          visualDensity: VisualDensity.compact,
                                        ))
                                            .toList(),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // 오른쪽: 카트
                Container(width: 1, color: cs.outlineVariant),
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      ListTile(
                        title: const Text('장바구니'),
                        trailing: TextButton(
                          onPressed: () => setState(() => cart.clear()),
                          child: const Text('비우기'),
                        ),
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.separated(
                          itemCount: cart.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, i) {
                            final l = cart[i];
                            final item = inv.menuRepo.find(l.itemId).data!;
                            final lineSum = (item.price) * l.qty;
                            return ListTile(
                              title: Text('${item.name} x ${l.qty}'),
                              subtitle: l.options.isEmpty
                                  ? null
                                  : Text('옵션: ${l.options.join(", ")}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove),
                                    onPressed: () => setState(() {
                                      if (l.qty <= 1) {
                                        cart.removeAt(i);
                                      } else {
                                        cart[i] = OrderLine(
                                          itemId: l.itemId,
                                          qty: l.qty - 1,
                                          options: l.options,
                                        );
                                      }
                                    }),
                                  ),
                                  Text('$lineSum원'),
                                  IconButton(
                                    icon: const Icon(Icons.add),
                                    onPressed: () => setState(() {
                                      cart[i] = OrderLine(
                                        itemId: l.itemId,
                                        qty: l.qty + 1,
                                        options: l.options,
                                      );
                                    }),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Divider(height: 1),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _row('소계', _calcSubtotal()),
                            _row('프로모션', promo == null ? 0 : _calcSubtotal() - _calcTotal()),
                            const SizedBox(height: 8),
                            _row('총액', _calcTotal(), isBold: true),
                            const SizedBox(height: 12),
                            FilledButton.icon(
                              onPressed: cart.isEmpty
                                  ? null
                                  : () {
                                final o = Order(
                                  id: DateTime.now().millisecondsSinceEpoch,
                                  lines: cart.toList(),
                                  promoCode: promo,
                                );
                                final r = calc.totalWithPromotion(o);
                                if (r.isOk) {
                                  final analytics = calc.analytics(o); // Map 리포트
                                  showDialog(
                                    context: context,
                                    builder: (_) {
                                      return AlertDialog(
                                        title: const Text('결제 완료'),
                                        content: Text(
                                          '결제금액: ${r.data}원\\n\\n분석: $analytics',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.pop(context),
                                            child: const Text('확인'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  setState(() {
                                    cart.clear();
                                    promo = null;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(r.error!)),
                                  );
                                }
                              },
                              icon: const Icon(Icons.payment),
                              label: const Text('결제하기'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String label, int value, {bool isBold = false}) {
    final s = TextStyle(
      fontSize: isBold ? 20 : 16,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
    );
    return Row(
      children: [
        Expanded(child: Text(label, style: s)),
        Text('${value}원', style: s),
      ],
    );
  }
}
class _Filters extends StatelessWidget {
  final Set<String> allergenBlacklist;
  final Set<String> requireTags;
  final VoidCallback onChanged;

  const _Filters({
    required this.allergenBlacklist,
    required this.requireTags,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final allergenChips = ['nuts', 'milk'];
    final tagChips = ['hot', 'ice', 'signature'];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 🔑 자동 반응 기준: 좁은 폭이거나, 세로 방향이면 세로 배치
          final orientation = MediaQuery.of(context).orientation;
          final isNarrow = constraints.maxWidth < 560 ||
              orientation == Orientation.portrait;

          final allergenRow = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergenChips.map((a) {
              final on = allergenBlacklist.contains(a);
              return FilterChip(
                label: Text(a),
                selected: on,
                onSelected: (v) {
                  if (v) allergenBlacklist.add(a);
                  else allergenBlacklist.remove(a);
                  onChanged();
                },
              );
            }).toList(),
          );

          final tagRow = Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tagChips.map((t) {
              final on = requireTags.contains(t);
              return FilterChip(
                label: Text(t),
                selected: on,
                onSelected: (v) {
                  if (v) requireTags.add(t);
                  else requireTags.remove(t);
                  onChanged();
                },
              );
            }).toList(),
          );

          if (isNarrow) {
            // 📱 세로/좁은 화면: 두 줄(세로) 배치
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('알레르기 제외:',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: allergenRow),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 10),
                      child: Text('필수 태그:',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: tagRow),
                  ],
                ),
              ],
            );
          } else {
            // 💻 가로/넓은 화면: 한 줄(가로) 배치
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('알레르기 제외:',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Expanded(child: allergenRow),
                const SizedBox(width: 24),
                const Text('필수 태그:',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Expanded(child: tagRow),
              ],
            );
          }
        },
      ),
    );
  }
}
