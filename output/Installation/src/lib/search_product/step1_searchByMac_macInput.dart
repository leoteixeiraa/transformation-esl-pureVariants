// ignore_for_file: avoid_unnecessary_containers, prefer_const_constructors, prefer_const_literals_to_create_immutables
import 'package:esl_mobile_app/components/lm_dropdown_button.dart';
import 'package:esl_mobile_app/components/my_solid_button.dart';
import 'package:esl_mobile_app/components/my_text_form_field.dart';
import 'package:esl_mobile_app/dto/user_dto.dart';
import 'package:esl_mobile_app/models/actionArguments/SearchByMacArguments.dart';
import 'package:esl_mobile_app/models/actionArguments/installation_arguments.dart';
import 'package:esl_mobile_app/services/cache_management.dart';
import 'package:esl_mobile_app/views/Installation/step1_installation_macReader.dart';
import 'package:esl_mobile_app/views/Installation/step2_installation_glnInput.dart';

//import 'package:esl_mobile_app/views/place_label_gln_reader.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class Step1SearchByMacMacInput extends StatefulWidget {
  const Step1SearchByMacMacInput({super.key});

  @override
  State<StatefulWidget> createState() => _Step1SearchByMacMacInputState();
}

class _Step1SearchByMacMacInputState extends State<Step1SearchByMacMacInput> {
  UserDto? user;
  var cache = CacheManagement();
  String _mac = '';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var args = SearchByMacArguments();
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consulta de etiqueta", style: TextStyle(fontSize: 24)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                    key: _formKey,
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
            buttonLabel: Text('Consultar'),
            onPressedCallBack: () {
              if(_formKey.currentState!.validate()){
                Navigator.of(context).pushNamed(
                  '/search/byMac/esl',
                  arguments: args,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
