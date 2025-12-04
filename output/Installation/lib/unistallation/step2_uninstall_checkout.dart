import 'dart:developer';

import 'package:esl_mobile_app/components/my_card.dart';
import 'package:esl_mobile_app/components/tagInfo_checkout_card.dart';
import 'package:esl_mobile_app/views/Uninstallation/step1_uninstall_macReader.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../components/my_actions_alert_dialog.dart';
import '../../components/my_alert_dialog.dart';
import '../../components/my_solid_button.dart';

import '../../models/actionArguments/uninstallation_arguments.dart';
import '../../services/installation_process_manager.dart';
import '../../utils/constants.dart';

class Step2UninstallationCheckout extends StatelessWidget {
  Step2UninstallationCheckout({super.key,  this.args});

  UninstallationArguments? args;

  @override
  Widget build(BuildContext context) {

    args = ModalRoute.of(context)!.settings.arguments as UninstallationArguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Desinstalar etiqueta", style: TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text('Conferência', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TagInfoCheckoutCard(mac: args?.macAddress ?? ''),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildInstallButton(context, mac: args?.macAddress ?? '' ),
    );
  }

  Padding buildInstallButton(BuildContext context, {required String mac}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: MySolidButton(
            buttonLabel: Text('Desinstalar etiqueta'),
            onPressedCallBack: () =>
            {
              InstallationProcessManager()
                  .uninstall(
                macParameter: mac ?? '',

                ).timeout(
                const Duration(milliseconds: ZEROMQ_TIMEOUT_VALUE),
                onTimeout: () {
                  MyAlertDialog(success: false).build(
                    context,
                    titulo: 'Tempo esgotado!',
                    mensagem:
                    'A operação demorou, tente novamente mais tarde ou entre em contato com algum administrador',
                    buttonLabel: 'Ok',
                  );

                  throw Exception(
                      'Tempo esgotado durante a instalação de dispositivos! Tente novamente mais tarde');
                },
              ).then(
                    (value) {
                  //TODO VERIFICAR POR CODIGO DE RETORNO DA REQUISIÇÃO
                  log('Operação de instalação retornou ${value.body}');
                  if (value.body.contains('NACK')) {
                    //problema nos dados enviados
                    MyAlertDialog(success: false).build(
                      context,
                      titulo: 'Dados inválidos!',
                      mensagem: 'Verifique os dados e tente novamente',
                      buttonLabel: 'Ok',
                    );
                  } else if (value.body.contains('timed')) {
                    //problema com o zeromq, não foi possível iniciar o container
                    MyAlertDialog(success: false).build(
                      context,
                      titulo: 'Problema no servidor!',
                      mensagem:
                      'Informe os administradores do sistema sobre o problema.',
                      buttonLabel: 'Ok',
                    );
                  } else {
                    //retornou ack, tudo certo
                    MyActionsAlertDialog(success: true).build(
                        context,
                        titulo: 'Solicitação enviada!',
                        mensagem: 'A solicitação de desinstalação foi enviada. Você receberá uma notificação em caso de falha.',
                        newActionWidget: Step1UninstallMacReader(allowedBarcodeFormats: const [BarcodeFormat.code128]),
                        newActionRoute: '/installation/uninstall/macReader',
                        newActionLabel: 'Nova desinstalação'
                    );
                  }
                },
              ).onError((error, stackTrace) {
                MyAlertDialog(success: false).build(
                  context,
                  titulo: 'Erro!',
                  mensagem:
                  'Informe aos administradores sobre o problema: $error',
                  buttonLabel: 'Ok',
                );
              }),

            }
        ),
      ),
    );
  }
}
