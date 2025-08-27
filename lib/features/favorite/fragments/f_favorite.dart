import 'package:test_app/core/common.dart';
import 'package:flutter/material.dart';

import '../../../shared/widget/round_button_theme.dart';
import '../../../shared/widget/w_round_button.dart';

class FavoriteFragment extends StatelessWidget {
  final bool isShowBackButton;

  const FavoriteFragment({
    Key? key,
    this.isShowBackButton = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isShowBackButton) const BackButton(),
            Expanded(
              child: Container(
                color: context.appColors.seedColor.getMaterialColorValues[100],
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Row(),
                      RoundButton(
                        text: '즐겨찾기 화면 이동',
                        onTap: () => Nav.push(const FavoriteFragment(isShowBackButton: true),
                            context: context),
                        theme: RoundButtonTheme.blue,
                      ),
                    ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
