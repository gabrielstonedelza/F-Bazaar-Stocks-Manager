import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LoadingUi extends StatelessWidget {
  const LoadingUi({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: Image.asset("assets/images/animation_lnex6hyp_small.gif"),
          ),
        ),
      ],
    );
  }
}
