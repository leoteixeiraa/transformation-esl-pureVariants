import 'package:flutter/material.dart';

import '../styles/app_themes.dart';
import 'my_card.dart';
import 'my_text_form_field.dart';

class ProductInfoCheckoutCard extends StatelessWidget{
  String ean;
  ProductInfoCheckoutCard({Key? key, required this.ean}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: [
        Expanded(
          child: MyCard(
            childrenWidget: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Informações do produto',
                  style: TextStyle(
                    color: MyColorStyles.grey900,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                MyTextField(
                  label: 'Código da etiqueta',
                  value: ean,
                  enabled: false,
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ],
    );
  }

}