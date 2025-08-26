import 'package:test_app/common/data/preference/item/nullable_preference_item.dart';
import 'package:test_app/common/theme/custom_theme.dart';

class Prefs {
  static final appTheme = NullablePreferenceItem<CustomTheme>('appTheme');
}
