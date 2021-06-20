import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'textTheme.dart';

class StatsValue extends StatelessWidget {
  final Color? color;
  final dynamic value;
  final String? header;

  const StatsValue({Key? key, this.value, this.header, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flexible(
      fit: FlexFit.tight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            flex: 2,
            child: FittedBox(
              child: AutoSizeText(
                value.toString(),
                style: TextStyleFontTheme.luckiestGuy
                    .copyWith(fontSize: 32, color: color ?? Colors.brown[800]),
                maxLines: 1,
              ),
            ),
          ),
          Flexible(
            child: FractionallySizedBox(
              widthFactor: 0.7,
              child: AutoSizeText(
                header!,
                style: TextStyleFontTheme.poppins
                    .copyWith(fontSize: 24, color: color ?? Colors.brown[400]),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
