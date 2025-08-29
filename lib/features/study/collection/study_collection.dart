import 'dart:math';

/// ---------------------------
/// 📌 카테고리 정의
/// ---------------------------
/// 커피, 음료, 디저트 3가지 카테고리를 구분하기 위한 enum
enum Category { coffee, beverage, dessert }

/// ---------------------------
/// 📌 메뉴 아이템
/// ---------------------------
/// 한 개의 메뉴 정보를 표현하는 클래스
/// - id : 고유 번호
/// - name : 메뉴 이름
/// - category : 메뉴 종류 (커피/음료/디저트)
/// - price : 가격
/// - tags : 'hot', 'ice', 'nuts' 같은 속성 태그
class MenuItem implements Identifiable {
  @override
  final int id;
  final String name;
  final Category category;
  final int price; // KRW
  final Set<String> tags;

  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    Set<String>? tags,
  }) : tags = tags ?? const <String>{};

  @override
  String toString() =>
      '$name(${price}원) ${tags.isEmpty ? "" : tags.join(",")}';
}

/// ---------------------------
/// 📌 Result<T>
/// ---------------------------
/// 연산 결과를 담는 제네릭 클래스
/// - 성공: Result.ok(data)
/// - 실패: Result.err(errorMessage)
/// UI에서 에러 처리/성공 여부 판단에 사용
class Result<T> {
  final T? data;
  final String? error;
  const Result._(this.data, this.error);

  factory Result.ok(T data) => Result._(data, null);
  factory Result.err(String message) => Result._(null, message);

  bool get isOk => error == null;
}

/// ---------------------------
/// 📌 Identifiable + Repository
/// ---------------------------
/// - Identifiable : id를 가진 객체 인터페이스
/// - Repository<T> : id 기반으로 객체를 메모리에 저장/조회하는 간단한 저장소
abstract class Identifiable {
  int get id;
}

class Repository<T extends Identifiable> {
  final _items = <int, T>{}; // Map: id -> entity

  Result<void> save(T item) {
    _items[item.id] = item;
    return Result.ok(null);
  }

  Result<T> find(int id) {
    final v = _items[id];
    return v == null ? Result.err('Not found: $id') : Result.ok(v);
  }

  List<T> all() => _items.values.toList(growable: false);
}

/// ---------------------------
/// 📌 CafeInventory
/// ---------------------------
/// 메뉴 / 재고 / 프로모션을 관리하는 엔진 클래스
class CafeInventory {
  final Repository<MenuItem> menuRepo = Repository<MenuItem>(); // 메뉴 저장
  final Map<int, int> stock = {}; // itemId -> 수량
  final Map<String, Promotion> promotions = {}; // 프로모션 코드 -> 룰

  /// 재고 입력/수정
  void upsertStock(int itemId, int qty) => stock[itemId] = qty;

  /// 재고 체크
  bool isInStock(int itemId, int qty) => (stock[itemId] ?? 0) >= qty;

  /// 알레르기 필터 (nuts, milk 등)
  List<MenuItem> filterByAllergenBlacklist(Set<String> allergens) {
    return menuRepo.all().where(
          (m) => m.tags.intersection(allergens).isEmpty,
    ).toList();
  }

  /// 특정 태그가 반드시 들어간 메뉴만 필터링 (예: ice)
  List<MenuItem> filterByTags(Set<String> mustIncludeTags) {
    return menuRepo.all().where(
          (m) => mustIncludeTags.every((t) => m.tags.contains(t)),
    ).toList();
  }

  /// 카테고리별로 메뉴 묶기
  Map<Category, List<MenuItem>> groupByCategory() {
    final map = <Category, List<MenuItem>>{};
    for (final m in menuRepo.all()) {
      map.putIfAbsent(m.category, () => []).add(m);
    }
    return map;
  }
}

/// ---------------------------
/// 📌 Order / OrderLine
/// ---------------------------
/// - OrderLine : 장바구니의 한 줄(메뉴, 수량, 옵션)
/// - Order : 주문 전체, 여러 OrderLine 포함 + 프로모션 코드
class OrderLine {
  final int itemId;
  final int qty;
  final Set<String> options;

  const OrderLine({
    required this.itemId,
    required this.qty,
    Set<String>? options,
  }) : options = options ?? const <String>{};
}

class Order implements Identifiable {
  @override
  final int id;
  final List<OrderLine> lines;
  final DateTime createdAt;
  final String? promoCode;

  Order({
    required this.id,
    required this.lines,
    this.promoCode,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

/// ---------------------------
/// 📌 Promotion / PromotionRule
/// ---------------------------
/// - PromotionRule : 할인 규칙 인터페이스
/// - FlatOff : 정액 할인
/// - PercentOff : 정률 할인
/// - CategoryPercentOff : 특정 카테고리만 할인
abstract class PromotionRule {
  int apply(int original, Order order, CafeInventory inv);
}

class FlatOff implements PromotionRule {
  final int amount;
  FlatOff(this.amount);

  @override
  int apply(int original, Order order, CafeInventory inv) =>
      max(0, original - amount);
}

class PercentOff implements PromotionRule {
  final double rate; // 예: 0.1 = 10% 할인
  PercentOff(this.rate);

  @override
  int apply(int original, Order order, CafeInventory inv) =>
      (original * (1 - rate)).round();
}

class CategoryPercentOff implements PromotionRule {
  final Category category;
  final double rate;
  CategoryPercentOff(this.category, this.rate);

  @override
  int apply(int original, Order order, CafeInventory inv) {
    final total = original;
    final catSum = _sumByCategory(order, inv, category);
    final discount = (catSum * rate).round();
    return max(0, total - discount);
  }

  int _sumByCategory(Order order, CafeInventory inv, Category target) {
    var sum = 0;
    for (final l in order.lines) {
      final itemRes = inv.menuRepo.find(l.itemId);
      if (!itemRes.isOk) continue;
      final item = itemRes.data!;
      if (item.category == target) {
        sum += item.price * l.qty;
      }
    }
    return sum;
  }
}

/// 프로모션 자체: 코드 + 이름 + 룰
class Promotion {
  final String code;
  final String name;
  final PromotionRule rule;
  Promotion({required this.code, required this.name, required this.rule});
}

/// ---------------------------
/// 📌 PriceCalculator
/// ---------------------------
/// 주문 금액 계산 담당
class PriceCalculator {
  final CafeInventory inv;
  PriceCalculator(this.inv);

  /// 주문 소계 계산
  Result<int> subtotal(Order order) {
    var sum = 0;
    for (final l in order.lines) {
      final r = inv.menuRepo.find(l.itemId);
      if (!r.isOk) return Result.err('메뉴를 찾을 수 없음: ${l.itemId}');
      final item = r.data!;

      if (!inv.isInStock(item.id, l.qty)) {
        return Result.err('재고 부족: ${item.name}');
      }

      final optionFee = _optionPrice(item, l.options);
      sum += (item.price + optionFee) * l.qty;
    }
    return Result.ok(sum);
  }

  /// 옵션 가격 계산
  int _optionPrice(MenuItem item, Set<String> options) {
    final fees = <String, int>{
      'extra_shot': 500,
      'almond_milk': 700,
    };
    var fee = 0;
    for (final opt in options) {
      fee += fees[opt] ?? 0;
    }
    return fee;
  }

  /// 프로모션까지 적용한 총액
  Result<int> totalWithPromotion(Order order) {
    final sub = subtotal(order);
    if (!sub.isOk) return sub;
    final raw = sub.data!;

    if (order.promoCode == null) return Result.ok(raw);

    final promo = inv.promotions[order.promoCode!];
    if (promo == null) return Result.err('유효하지 않은 프로모션 코드');

    final discounted = promo.rule.apply(raw, order, inv);
    return Result.ok(discounted);
  }

  /// 카테고리/태그별 합계 분석
  Map<String, int> analytics(Order order) {
    final res = <String, int>{};
    void add(String key, int v) =>
        res.update(key, (old) => old + v, ifAbsent: () => v);

    for (final l in order.lines) {
      final r = inv.menuRepo.find(l.itemId);
      if (!r.isOk) continue;
      final item = r.data!;
      final lineSum = item.price * l.qty;

      add('category:${item.category.name}', lineSum);
      for (final t in item.tags) {
        add('tag:$t', lineSum);
      }
    }
    return res;
  }
}

/// ---------------------------
/// 📌 seed() : 샘플 데이터
/// ---------------------------
/// 실제 실행해볼 때 미리 메뉴/재고/프로모션을 채워주는 함수
CafeInventory seed() {
  final inv = CafeInventory();
  final items = <MenuItem>[
    MenuItem(id: 1, name: '아메리카노', category: Category.coffee, price: 2500, tags: {'hot','ice'}),
    MenuItem(id: 2, name: '카페라떼', category: Category.coffee, price: 3800, tags: {'hot','ice','milk'}),
    MenuItem(id: 3, name: '콜드브루', category: Category.coffee, price: 4200, tags: {'ice'}),
    MenuItem(id: 4, name: '말차라떼', category: Category.beverage, price: 4500, tags: {'milk'}),
    MenuItem(id: 5, name: '티라미수', category: Category.dessert, price: 5500, tags: {'nuts'}),
  ];
  for (final i in items) {
    inv.menuRepo.save(i);
    inv.upsertStock(i.id, 50);
  }

  inv.promotions['WELCOME10'] = Promotion(
    code: 'WELCOME10',
    name: '첫 주문 10% 할인',
    rule: PercentOff(0.10),
  );
  inv.promotions['COFFEE20'] = Promotion(
    code: 'COFFEE20',
    name: '커피 카테고리 20% 할인',
    rule: CategoryPercentOff(Category.coffee, 0.20),
  );
  inv.promotions['MINUS1000'] = Promotion(
    code: 'MINUS1000',
    name: '1,000원 할인',
    rule: FlatOff(1000),
  );

  return inv;
}
