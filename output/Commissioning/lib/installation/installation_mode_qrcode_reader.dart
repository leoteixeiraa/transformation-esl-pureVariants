import 'dart:async';

import 'package:esl_mobile_app/models/global_location_number_extension.dart';
import 'package:esl_mobile_app/models/mac.dart';
import 'package:esl_mobile_app/services/validation/mac_validation_service.dart';

import 'package:flutter/material.dart';
import 'package:esl_mobile_app/services/barcode_scanner/scanner.dart';

import 'package:esl_mobile_app/dto/installation_dto.dart';
import 'package:flutter/services.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'dart:developer' as dev;

import '../../services/installation_process_manager.dart';
import '../../utils/constants.dart';

class InstallationModeQrcodeReaderView extends StatefulWidget {
  const InstallationModeQrcodeReaderView({super.key});

  @override
  State<StatefulWidget> createState() =>
      _InstallationModeQrcodeReaderViewState();
}

class _InstallationModeQrcodeReaderViewState
    extends State<InstallationModeQrcodeReaderView> {
  //formkey - the forms identifier
  final _formKey = GlobalKey<FormState>();

  String _mac = '';
  String _sgln = '';

  //MAC ADDRESS SCANNE
  TextEditingController macController = TextEditingController();
  var macAddressScanner = Scanner();

  TextEditingController sglnController = TextEditingController();
  var sglnScanner = Scanner();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var args = ModalRoute.of(context)!.settings.arguments;
    String? sgln;
    if (args != null) {
      sgln = args as String;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Instalação')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            buildSglnCard(sgln),
            const SizedBox(height: 16),
            buildMacCard(),
            const SizedBox(height: 16),
            buildSubmitButton(context),
          ],
        ),
      ),
    );
  }

  SizedBox buildSubmitButton(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child:
          //botao de instalação
          ElevatedButton(
              onPressed: () async {
                //FORMS
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState?.save();

                  var response = InstallationProcessManager().install(
                    macParameter: _mac,
                    sglnParameter: GlobalLocationNumberExtension.fromString(
                      _sgln,
                    ),
                  );

                  //response callbacks
                  response.timeout(
                      const Duration(milliseconds: ZEROMQ_TIMEOUT_VALUE),
                      onTimeout: () {
                    _dialogBuilder(context,
                        titulo: 'Tempo esgotado!',
                        mensagem:
                            'A operação demorou, tente novamente mais tarde ou entre em contato com algum administrador');
                    throw Exception(
                        'Tempo esgotado durante a instalação de dispositivos! Tente novamente mais tarde');
                  }).then((value) {
                    dev.log('Operação de instalação retornou ${value.body}');
                    if (value.body.contains('NACK')) {
                      //problema nos dados enviados
                      _dialogBuilder(context,
                          titulo: 'Dados inválidos!',
                          mensagem: 'Verifique os dados e tente novamente');
                    } else if (value.body.contains('timed')) {
                      //problema com o zeromq, não foi possível iniciar o container
                      _dialogBuilder(context,
                          titulo: 'Requisição demorou demais!',
                          mensagem:
                              'Informe os administradores do sistema sobre o problema');
                    } else {
                      //retornou ack, tudo certo
                      _dialogBuilder(context,
                          titulo: 'Instalação pendente no sistema!',
                          mensagem:
                              'Verifique se a instalação foi bem sucedida na tela da etiqueta ou na tela "Checar tentativas de instalação"');
                    }
                    _formKey.currentState?.reset();
                  });
                }
              },
              child: const Text('Instalar')),
    );
  }

  Card buildMacCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            children: [
              Text(
                'Número MAC',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          Row(
            children: [
              Text(
                '(código de barras)',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
          const SizedBox(
            height: 8,
            width: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  controller: macController,
                  decoration: const InputDecoration(
                    labelText: 'Escaneie o endereço MAC',
                    border: OutlineInputBorder(),
                  ),
                  /* validator: (String? arg) {
                    if (arg != null && arg.length != 12) {
                      return 'MAC deve ter 12 digitos';
                    } else {
                      return null;
                    }
                  }, */
                  onSaved: (newValue) => _mac = (newValue ?? ''),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              ElevatedButton(
                style: const ButtonStyle(
                  iconSize: MaterialStatePropertyAll(28),
                  fixedSize: MaterialStatePropertyAll(Size(50, 50)),
                ),
                onPressed: () async {
                  /* 
                  String? macAddressString = await macAddressScanner
                      .scannerReader(context, BarcodeReaderType.mac);
                  macScan.value = TextEditingValue(text: macAddressString); */
                  String? macString = await macAddressScanner.scannerReader(
                    context,
                    BarcodeReaderType.mac,
                  );
                  macAddressScanner = Scanner();
                  macController.value = TextEditingValue(text: macString);
                },
                child: const Icon(Icons.camera_alt_outlined),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Card buildSglnCard(String? sgln) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Localização física',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Flexible(
                    child: TextFormField(
                      initialValue: sgln,
                      controller: sglnController,
                      decoration: const InputDecoration(
                        labelText: 'Escaneie a localização física',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? arg) {
                        return MacValidationService().validator(arg);
                      },
                      onSaved: (newValue) => _sgln = (newValue ?? ''),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: const ButtonStyle(
                      iconSize: MaterialStatePropertyAll(28),
                      fixedSize: MaterialStatePropertyAll(Size(50, 50)),
                    ),
                    onPressed: () async {
                      String? sglnString = await sglnScanner.scannerReader(
                        context,
                        BarcodeReaderType.sgln,
                      );
                      sglnScanner = Scanner();
                      sglnController.value = TextEditingValue(text: sglnString);
                    },
                    child: const Icon(Icons.camera_alt_outlined),
                  ),
                ],
              ),
            ]),
      ),
    );
  }
}

Future<void> _dialogBuilder(BuildContext context,
    {String titulo = '', String mensagem = ''}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Nova instalação'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, '/installation/install/qrcode');
              //Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Sair'),
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/',
                (Route<dynamic> route) {
                  return false;
                },
              );
            },
          ),
        ],
      );
    },
  );
}
