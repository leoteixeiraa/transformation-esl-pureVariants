// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:esl_mobile_app/components/my_solid_button.dart';
import 'package:esl_mobile_app/dto/user_dto.dart';
import 'package:esl_mobile_app/models/actionArguments/commission_arguments.dart';
import 'package:esl_mobile_app/services/cache_management.dart';
import 'package:esl_mobile_app/views/Commissioning/step3_commission_checkout.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../components/my_text_form_field.dart';
import '../../styles/app_themes.dart';
import '../../services/barcode_scanner/scanner.dart';

class Step2CommissionEanInput extends StatefulWidget {
  const Step2CommissionEanInput({super.key});

  @override
  State<StatefulWidget> createState() => _Step2CommissionEanInputState();
}

class _Step2CommissionEanInputState extends State<Step2CommissionEanInput> {
  UserDto? user;

  // var cache = CacheManagement();
  String _mac = '';

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute
        .of(context)!
        .settings
        .arguments as CommissioningArguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Comissionar produto", style: TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: 20,
            ),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      'Digite o código do produto',
                      style: Theme
                          .of(context)
                          .textTheme
                          .headlineSmall,
                    ),
                  ],
                ),
                SizedBox(
                  height: 20,
                ),
                MyTextField(
                  onChange: (value) {
                    print(value);
                    args.ean = value;
                  },
                  label: 'Código do produto',
                  placeholder: 'Código de barras',
                ),
                SizedBox(height: 20),
              ],
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: SizedBox(
          height: 50,
          width: double.infinity,
          child: MySolidButton(
            buttonLabel: Text('Revisão'),
            onPressedCallBack: () {
              Navigator.of(context).pushNamed(
                '/commissioning/commission/checkout',
                arguments: args,
              );
            },
          ),
        ),
      ),
    );
  }
}