import 'dart:developer';

import 'package:esl_mobile_app/components/checkou_header.dart';
import 'package:esl_mobile_app/components/my_actions_alert_dialog.dart';
import 'package:esl_mobile_app/components/my_card.dart';
import 'package:esl_mobile_app/components/my_text_form_field.dart';
import 'package:esl_mobile_app/components/physicalLocation_checkout_card.dart';
import 'package:esl_mobile_app/components/tagInfo_checkout_card.dart';
import 'package:esl_mobile_app/dto/installation_dto.dart';
import 'package:esl_mobile_app/dto/user_dto.dart';
import 'package:esl_mobile_app/models/actionArguments/installation_arguments.dart';
import 'package:esl_mobile_app/models/global_location_number_extension.dart';
import 'package:esl_mobile_app/services/cache_management.dart';
import 'package:esl_mobile_app/styles/app_themes.dart';
import 'package:esl_mobile_app/views/Installation/step1_installation_macReader.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

import '../../components/my_alert_dialog.dart';
import '../../components/my_solid_button.dart';
import '../../services/installation_process_manager.dart';
import '../../utils/constants.dart';

class Step3InstallationCheckout extends StatelessWidget {
  Step3InstallationCheckout({super.key, this.args});

  InstallationArguments? args;

  @override
  Widget build(BuildContext context) {
    Color textColor = MyColorStyles.grey300;

    args = ModalRoute.of(context)!.settings.arguments as InstallationArguments;

    return Scaffold(
      appBar: AppBar(title: const Text('Instalação de etiqueta')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text('Conferência',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            TagInfoCheckoutCard(mac: args!.macAddress ?? ''),
            const SizedBox(height: 8),
            PhysicalLocationInfoCheckoutCard(
              module: args!.module ?? '',
              runner: args!.runner ?? '',
              section: args!.section ?? '',
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildInstallButton(context),
    );
  }

  Padding buildInstallButton(BuildContext context) {
    int clientId;
    String storeCode;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: MySolidButton(
          buttonLabel:Text( 'Instalar etiqueta'),
          onPressedCallBack: () => {
            CacheManagement().getUser().then((value) => {
                  clientId = value?.clientId ?? 0,
                  storeCode = value?.storeCode ?? '',
                  InstallationProcessManager()
                      .install(
                    macParameter: args?.macAddress ?? '',
                    sglnParameter: GlobalLocationNumberExtension(
                      clientId: clientId,
                      storeCode: storeCode,
                      section: args?.section ?? '',
                      runner: args?.runner ?? '',
                      module: args?.module ?? '',
                    ),
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
                          mensagem:
                              'A solicitação de instalação de etiqueta foi enviada! Você receberá uma notificação em caso de falha.',
                          newActionWidget: Step1InstallationMacReader(
                              allowedBarcodeFormats: const [
                                BarcodeFormat.code128
                              ]),
                          newActionRoute: '/installation/install/macReader',
                          newActionLabel: 'Nova instalação',
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
                }),
          },
        ),
      ),
    );
  }
}
// MyActionsAlertDialog(success: true).build(context,
// titulo: 'Solicitação enviada!',
// mensagem:
// 'A solicitação de instalação foi enviada. Você receberá uma notificação em caso de falha.',
// newActionWidget: Step1InstallationMacReader(
// allowedBarcodeFormats: const [BarcodeFormat.code128]),
// newActionRoute: '/installation/install/macReader',
// newActionLabel: 'Nova instalação'),
