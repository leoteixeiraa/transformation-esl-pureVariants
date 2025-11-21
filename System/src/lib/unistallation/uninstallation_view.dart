import 'package:esl_mobile_app/db/logs_shared_preferences.dart';
import 'package:esl_mobile_app/components/cmp_navigation_bar.dart';
import 'package:esl_mobile_app/views/Uninstallation/uninstallation_logs_view.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:esl_mobile_app/models/mac.dart';
import 'package:esl_mobile_app/dto/uninstallation_dto.dart';
import 'package:esl_mobile_app/services/installation_process_manager.dart';
import 'package:esl_mobile_app/styles/lm_text_style.dart';
import 'dart:convert';

import 'package:esl_mobile_app/db/database_connection.dart';
import '../../dto/installation_dto.dart';
import '../../models/global_location_number_extension.dart';
import '../../services/barcode_scanner/scanner.dart';

import 'dart:developer';

import '../../utils/constants.dart';
import '../Installation/installation_logs_view.dart';

class UninstallationView extends StatefulWidget {
  const UninstallationView({super.key});
  @override
  State<UninstallationView> createState() => _UninstallationViewState();
}

class _UninstallationViewState extends State<UninstallationView> {
  String? _mac;

  final formKey = GlobalKey<FormState>();
  TextEditingController scan = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  var macAddressScanner = Scanner();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Desinstalação')),
        body: Form(
          key: formKey,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: ListView(
              children: [
                //card e inputs do Mac
                _buildMacCard(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          height: 50,
          width: double.infinity,
          child: _buildSubmitUninstallationButton(),
        ),
      );

  void _submitUninstallationAction() async {
    if (formKey.currentState?.validate() == true) {
      formKey.currentState?.save();
      //debugPrint('MAC    : $_mac');
      var response = InstallationProcessManager().uninstall(
        macParameter: _mac ?? '',
      );

      //response callbacks
      response.timeout(
          const Duration(
            milliseconds: ZEROMQ_TIMEOUT_VALUE,
          ), onTimeout: () {
        _dialogBuilder(context,
            titulo: 'Tempo esgotado!',
            mensagem:
                'A operação demorou, tente novamente mais tarde ou entre em contato com algum administrador');
        throw Exception(
            'Tempo esgotado durante a desinstalação do dispositivo! Tente novamente mais tarde');
      }).then((value) {
        //TODO VERIFICAR POR CODIGO DE RETORNO DA REQUISIÇÃO
        log('Operação de desinstalação retornou ${value.body}');
        if (value.body.contains('NACK')) {
          //problema nos dados enviados
          _dialogBuilder(context,
              titulo: 'Dados inválidos!',
              mensagem: 'Verifique os dados e tente novamente');
        } else if (value.body.contains('timed')) {
          //problema com o zeromq, não foi possível iniciar o container
          _dialogBuilder(context,
              titulo: 'Problema no servidor!',
              mensagem:
                  'Informe os administradores do sistema sobre o problema');
        } else {
          //retornou ack, tudo certo
          _dialogBuilder(context,
              titulo: 'Desinstalação pendente no sistema!',
              mensagem:
                  'Verifique posteriormente se a desinstalação foi bem sucedida');
        }
        formKey.currentState?.reset();
      }).onError((error, stackTrace) {
        _dialogErrorBuilder(context,
            titulo: 'Erro!',
            mensagem: 'Informe aos administradores sobre o problema: $error');
      });
    }
  }

  Widget _buildSubmitUninstallationButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            _submitUninstallationAction();
          },
          child: const Text('Desinstalar'),
        ),
      ),
    );
  }

  Card _buildMacCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Row(
            children: [
              Text(
                'Número MAC',
                style: Theme.of(context).textTheme.titleLarge,
              )
            ],
          ),
          Row(
            children: [
              Text(
                '(código de barras da etiqueta eletrônica)',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
          const SizedBox(
            height: 8,
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Flexible(
                child: TextFormField(
                  controller: scan,
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
                  String macAddressString =
                      await macAddressScanner.scannerReader(
                    context,
                    BarcodeReaderType.mac,
                  );
                  macAddressScanner = Scanner();
                  scan.value = TextEditingValue(text: macAddressString);
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
            child: const Text('Nova desinstalação'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, '/uninstallation/uninstall');
              //Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Checar desinstalações'),
            onPressed: () async {
              //Navigator.popAndPushNamed(context, '/');
              //Navigator.pushReplacementNamed(context, '/');

              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UninstallationLogsView(
                            uninstallationsList: [],
                          )));
            },
          ),
        ],
      );
    },
  );
}

Future<void> _dialogErrorBuilder(BuildContext context,
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
            child: const Text('Sair'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      );
    },
  );
}
