import 'package:google_fonts/google_fonts.dart';

// 데이터 통신
export 'dart:async';

// 상수
export 'constants.dart';

// 다국어 처리
export 'package:easy_localization/easy_localization.dart';

// 전역 상태관리
export 'dart/extension/context_extension.dart';
export 'dart/extension/snackbar_context_extension.dart';

// 숫자 관련 함수
export '../core/dart/extension/num_extension.dart';


export '../shared/theme/color/abs_theme_colors.dart';
export '../shared/theme/shadows/abs_theme_shadows.dart';

// UI 관련
export '../shared/widgets/primitives/w_empty_expanded.dart';
export '../shared/widgets/primitives/w_height_and_width.dart';
export '../shared/widgets/primitives/w_line.dart';
export '../shared/widgets/primitives/w_tap.dart';

// 다이얼로그
export 'package:test_app/shared/widgets/dialogs/d_dialog.dart';
export 'package:test_app/shared/widgets/dialogs/d_bottom_sheet.dart';
export 'package:test_app/shared/widgets/dialogs/d_dialog_show.dart';
export 'package:test_app/shared/widgets/dialogs/d_color_bottom.dart';
export 'package:test_app/shared/widgets/dialogs/d_confirm.dart';
export 'package:test_app/shared/widgets/dialogs/d_message.dart';



const defaultFontStyle = GoogleFonts.ptSerif;

void voidFunction() {}
