import 'dart:convert';
import 'dart:developer';

import 'package:esl_mobile_app/dto/decommissioning_dto.dart';
import 'package:esl_mobile_app/views/Commissioning/decommissioning_logs_view.dart';
import 'package:flutter/material.dart';
import 'package:esl_mobile_app/services/barcode_scanner/scanner.dart';
import 'package:esl_mobile_app/services/commissioning_process_manager.dart';
import 'package:esl_mobile_app/db/database_connection.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/src/response.dart';
import 'package:intl/intl.dart';
import '../../db/logs_shared_preferences.dart';
import '../../dto/commissioning_dto.dart';
import '../../models/mac.dart';
import '../../styles/lm_text_style.dart';
import '../../utils/constants.dart';
import 'commissioning_logs_view.dart';

class DecommissioningView extends StatefulWidget {
  const DecommissioningView({super.key});
  @override
  State<DecommissioningView> createState() => _DecommissioningViewState();
}

class _DecommissioningViewState extends State<DecommissioningView> {
  String? _mac;
  final formKey = GlobalKey<FormState>();
  TextEditingController macTextController = TextEditingController();
  var macScanner = Scanner();
  late List<String> logs;
  late DecommissioningDto LocalDecommissioningDTO;
  DateFormat formatter = DateFormat("yyyy-MM-dd HH:mm:ss.SSSSSS");

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Descomissionamento')),
        body: Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildMacCard(),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: SizedBox(
          height: 50,
          width: double.infinity,
          child: _buildSubmitDecommissioningButton(),
        ),
      );

  Widget _buildSubmitDecommissioningButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {
            _submitDecommissioning();
          },
          child: const Text('Descomissionar'),
        ),
      ),
    );
  }

  void _submitDecommissioning() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState?.save();

      var response = CommissioningProcessManager().decommission(
        macParameter: _mac ?? "",
      );

      response.timeout(const Duration(milliseconds: ZEROMQ_TIMEOUT_VALUE),
          onTimeout: () async {
        logs = await LogsSharedPreferences.getLogs('decommissionings');

        // ignore: use_build_context_synchronously
        _dialogBuilder(context,
            titulo: 'Tempo esgotado!',
            mensagem:
                'A operação demorou, tente novamente mais tarde ou entre em contato com algum administrador');
        throw Exception(
            'Tempo esgotado durante a instalação de dispositivos! Tente novamente mais tarde');
      }).then((value) async {
        log('Operação de instalação retornou ${value.body}');
        if (value.body.contains('NACK')) {
          //problema nos dados enviados

          _dialogBuilder(context,
              titulo: 'Dados inválidos!',
              mensagem: 'Verifique os dados e tente novamente');
        } else {
          //retornou ack, tudo certo
          //Commissioning Sent!
          //Check Later if the commissioning was sucessful
          _dialogBuilder(context,
              titulo: 'Descomissionamento pendente no sistema!',
              mensagem:
                  'Verifique se o descomissionamento foi bem sucedido na tela da etiqueta ou na tela de "Checar tentativas de comissionamento"');
        }
        formKey.currentState?.reset();
      }).onError((error, stackTrace) {
        _dialogErrorBuilder(context,
            titulo: 'Erro!',
            mensagem: 'Informe aos administradores sobre o problema: $error');
      });
    }
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
                  controller: macTextController,
                  decoration: const InputDecoration(
                    labelText: 'Escaneie o endereço MAC',
                    border: OutlineInputBorder(),
                  ),
                  /* validator: (String? arg) {
                    if (arg != null || arg!.length != 12) {
                      return 'MAC deve ter 12 digitos';
                    } else {
                      return null;
                    }
                  }, */
                  onSaved: (newValue) => _mac = (newValue ?? ''),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                style: const ButtonStyle(
                  iconSize: MaterialStatePropertyAll(28),
                  fixedSize: MaterialStatePropertyAll(Size(50, 50)),
                ),
                onPressed: () async {
                  String? macValue = await macScanner.scannerReader(
                    context,
                    BarcodeReaderType.mac,
                  );
                  macScanner = Scanner();
                  macTextController.value = TextEditingValue(text: macValue);
                },
                child: const Icon(Icons.camera_alt_outlined),
              ),
            ],
          )
        ]),
      ),
    );
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
              child: const Text('Novo descomissionamento'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Checar descomissionamentos'),
              onPressed: () async {
                List<DecommissioningDto> decommsionings = [];
                //TODO: VER PRA QQ SERVE ISSO await CommissioningProcessManager().getDecommissiongs('all');
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DecommissioningLogsView(
                            decommissioningsList: [])));
              },
            ),
          ],
        );
      },
    );
  }
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
