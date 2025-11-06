// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:esl_mobile_app/components/my_solid_button.dart';
import 'package:esl_mobile_app/dto/user_dto.dart';
import 'package:esl_mobile_app/models/actionArguments/decommission_arguments.dart';
import 'package:esl_mobile_app/services/cache_management.dart';
import 'package:esl_mobile_app/views/decommission/step2_decommission_checkout.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../components/my_text_form_field.dart';
import '../../styles/app_themes.dart';
import '../../services/barcode_scanner/scanner.dart';

class Step1DecommissionMacInput extends StatefulWidget {
  Step1DecommissionMacInput({super.key});

  @override
  State<StatefulWidget> createState() => _Step1DecommissionMacInputState();
}

class _Step1DecommissionMacInputState extends State<Step1DecommissionMacInput> {
  UserDto? user;

  //var cache = CacheManagement();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var args = DecommissioningArguments();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Descomissionar produto",
            style: TextStyle(fontSize: 24)),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
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
                        'Digite o código da etiqueta',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  MyTextField(
                    shouldValidateInputAsMac: true,
                    onChange: (value) {
                      print(value);
                      args.macAddress = value;
                    },
                    label: 'Código da etiqueta',
                    placeholder: 'Endereço MAC',
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ],
          ),
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
                if (_formKey.currentState!.validate()) {
                  print(' step1DMI: ${args.macAddress}');
                  Navigator.of(context).pushNamed(
                    '/commissioning/decommission/checkout',
                    arguments: args,
                  );
                }
              }),
        ),
      ),
    );
  }
}
