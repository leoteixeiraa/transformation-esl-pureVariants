import 'dart:developer';

import 'package:esl_mobile_app/components/my_card.dart';
import 'package:esl_mobile_app/components/productInfo_checkout_card.dart';
import 'package:esl_mobile_app/services/commissioning_process_manager.dart';
import 'package:esl_mobile_app/views/Commissioning/step1_commission_macReader.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../components/my_actions_alert_dialog.dart';
import '../../components/my_alert_dialog.dart';
import '../../components/my_solid_button.dart';
import '../../components/physicalLocation_checkout_card.dart';
import '../../components/tagInfo_checkout_card.dart';
import '../../models/actionArguments/commission_arguments.dart';
import '../../utils/constants.dart';

class Step3CommissionCheckout extends StatelessWidget {
  Step3CommissionCheckout({super.key, this.args});

  CommissioningArguments? args;

  @override
  Widget build(BuildContext context) {
    args = ModalRoute
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text('Conferência', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TagInfoCheckoutCard(mac: args?.macAddress ?? ''),
            const SizedBox(height: 8),
            ProductInfoCheckoutCard(ean: args?.ean ?? ''),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildInstallButton(context),
    );
  }

  Padding buildInstallButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: MySolidButton(
            buttonLabel: Text('Comissionar etiqueta'),
            onPressedCallBack: () =>
            {
              CommissioningProcessManager()
                .commission(
              macParameter: args?.macAddress ?? '',
              sgtinParameter: args?.ean ?? '',
            )
                .timeout(
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
                    'Tempo esgotado durante o comissionamento de produto! Tente novamente mais tarde');
              },
            ).then(
                  (value) {
                //TODO VERIFICAR POR CODIGO DE RETORNO DA REQUISIÇÃO
                log('Operação de comissionamento retornou ${value.body}');
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
                      mensagem: 'A solicitação de comissionamento foi enviada. Você receberá uma notificação em caso de falha.',
                      newActionWidget: Step1CommissionMacReader(allowedBarcodeFormats: const [BarcodeFormat.code128]),
                      newActionRoute: '/commissioning/commission/macReader',
                      newActionLabel: 'Novo comissionamento'
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
