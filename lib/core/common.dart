import 'package:google_fonts/google_fonts.dart';

// 데이터 통신
export 'dart:async';

// 상수
export 'constants.dart';
export 'package:test_app/core/constant/typography.dart';

// 다국어 처리
export 'package:easy_localization/easy_localization.dart';

// 전역 상태관리
export 'dart/extension/context_extension.dart';

// 숫자 관련 함수
export '../core/dart/extension/num_extension.dart';


// UI 관련


// 텍스트
export 'package:test_app/shared/widgets/text/w_base_text.dart';

// 버튼
export '../../../shared/widgets/buttons/w_card_button.dart';
export '../../../shared/widgets/buttons/w_base_button.dart';

// 다이얼로그
export 'package:test_app/shared/widgets/dialogs/d_base_dialog.dart';
export 'package:test_app/shared/widgets/dialogs/d_confirm_dialog.dart';
export 'package:test_app/shared/widgets/dialogs/d_info_dialog.dart';
export 'package:test_app/shared/widgets/dialogs/d_input_dialog.dart';



const defaultFontStyle = GoogleFonts.ptSerif;

void voidFunction() {}
