import 'dart:convert';
import 'dart:developer';

import 'package:esl_mobile_app/dto/commissioning_dto.dart';
import 'package:esl_mobile_app/models/Product.dart';
import 'package:flutter/material.dart';
import 'package:esl_mobile_app/services/barcode_scanner/scanner.dart';
import 'package:esl_mobile_app/styles/lm_text_style.dart';
import 'package:esl_mobile_app/services/commissioning_process_manager.dart';
import 'package:esl_mobile_app/models/mac.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

import '../../../../../utils/constants.dart';
import '../../../commissioning_logs_view.dart';

class CommissioningView extends StatefulWidget {
  const CommissioningView({super.key});

  @override
  State<StatefulWidget> createState() => _CommissioningViewState();
}

class _CommissioningViewState extends State<CommissioningView> {
  String viewGTIN = '';
  String viewMAC = '';
  String viewEAN = '';

  final formKey = GlobalKey<FormState>();
  TextEditingController macTextController = TextEditingController();
  TextEditingController eanTextController = TextEditingController();

  var macScanner = Scanner();
  var eanScanner = Scanner();

  bool _isNumeric(String? value) {
    if (value == null || value.isEmpty) {
      return false;
    }
    final number = num.tryParse(value);

    if (number == null) {
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Comissionamento')),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildEanCard(),
            const SizedBox(height: 16),
            buildMacCard(),
            const SizedBox(height: 16),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildSubmitCommissioningButton());

  Widget _buildSubmitCommissioningButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
            onPressed: () async {
              _submitCommissioning();
            },
            child: const Text('Comissionar')),
      ),
    );
  }

  void _submitCommissioning() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState?.save();

      var response = CommissioningProcessManager().commission(
        macParameter: viewMAC,
        sgtinParameter: viewEAN,
      );

      response.timeout(const Duration(milliseconds: ZEROMQ_TIMEOUT_VALUE),
          onTimeout: () {
        _dialogBuilder(context,
            titulo: 'Tempo esgotado!',
            mensagem:
                'A operação demorou, tente novamente mais tarde ou entre em contato com algum administrador');
        throw Exception(
            'Tempo esgotado durante o comissionamento dos dispositivos! Tente novamente mais tarde');
      }).then((value) {
        //TODO VERIFICAR POR CODIGO
        log('Operação de Comissionamento retornou ${value.body}');

        if (value.statusCode == 400) {
          _dialogBuilder(context,
              titulo: 'ESL não instalada!',
              mensagem: 'Instale a ESL e tente novamente');
        } else if (value.statusCode == 404) {
          _dialogBuilder(context,
              titulo: 'ESL não cadastrada!',
              mensagem:
                  'Verifique as ESLs cadastradas no sistema e tente novamente');
        } else if (value.body.contains('NACK')) {
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
          //Commissioning Sent!
          //Check Later if the commissioning was sucessful
          _dialogBuilder(context,
              titulo: 'Comissionamento pendente no sistema!',
              mensagem:
                  'Verifique se o comissionamento foi bem sucedido na tela da etiqueta ou na tela de "Checar tentativas de comissionamento"');
        }
        formKey.currentState?.reset();
      }).onError((error, stackTrace) {
        _dialogErrorBuilder(context,
            titulo: 'Erro!',
            mensagem: 'Informe aos administradores sobre o problema: $error');
      });
    }
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
          const SizedBox(height: 16),
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
                    if (arg != null && arg.length != 12) {
                      return 'MAC deve ter 12 digitos';
                    } else {
                      return null;
                    }
                  }, */
                  onSaved: (newValue) => viewMAC = (newValue ?? ''),
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
                  String? macString = await macScanner.scannerReader(
                    context,
                    BarcodeReaderType.mac,
                  );
                  macScanner = Scanner();
                  macTextController.value = TextEditingValue(text: macString);
                },
                child: const Icon(Icons.camera_alt_outlined),
              ),
            ],
          ),
        ]),
      ),
    );
  }

  Card _buildEanCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  'EAN',
                  style: Theme.of(context).textTheme.titleLarge,
                )
              ],
            ),
            Row(
              children: [
                Text(
                  '(código de barras do produto)',
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
                    /* validator: (value) {
                      if (value != null &&
                          value.length != 13 &&
                          !_isNumeric(value)) {
                        return "EAN deve ter 13 digitos e ser um número";
                      } else if (value != null && value.length != 13) {
                        return "EAN deve ter 13 digitos";
                      } else if (value != null && !_isNumeric(value)) {
                        return "EAN deve ser um número";
                      }
                      return null;
                    }, */
                    controller: eanTextController,
                    decoration: const InputDecoration(
                      labelText: 'EAN',
                      border: OutlineInputBorder(),
                    ),
                    onSaved: (newValue) => viewEAN = (newValue ?? ''),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: const ButtonStyle(
                    iconSize: MaterialStatePropertyAll(28),
                    fixedSize: MaterialStatePropertyAll(Size(50, 50)),
                  ),
                  onPressed: () async {
                    String? eanString = await eanScanner.scannerReader(
                      context,
                      BarcodeReaderType.product,
                    );
                    eanScanner = Scanner();
                    eanTextController.value = TextEditingValue(text: eanString);
                  },
                  child: const Icon(Icons.camera_alt_outlined),
                ),
              ],
            ),
          ],
        ),
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
              child: const Text('Novo comissionamento'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacementNamed(context, '/commissioning');
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Checar comssionamentos'),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const CommissioningLogsView()));
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
