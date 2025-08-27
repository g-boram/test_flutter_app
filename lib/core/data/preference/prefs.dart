import 'package:test_app/core/data/preference/item/nullable_preference_item.dart';
import 'package:test_app/shared/theme/custom_theme.dart';

class Prefs {
  static final appTheme = NullablePreferenceItem<CustomTheme>('appTheme');
}
