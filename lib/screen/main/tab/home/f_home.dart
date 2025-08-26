import 'package:test_app/common/common.dart';
import 'package:flutter/material.dart';


class HomeFragment extends StatelessWidget {
  const HomeFragment({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(color: context.appColors.seedColor.getMaterialColorValues[100],

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () => openDrawer(context),
                icon: const Icon(Icons.menu),
              )
            ],
          ),
          const EmptyExpanded(),

          const EmptyExpanded()
        ],
      ),
    );
  }


  void openDrawer(BuildContext context) {
    Scaffold.of(context).openDrawer();
  }
}
