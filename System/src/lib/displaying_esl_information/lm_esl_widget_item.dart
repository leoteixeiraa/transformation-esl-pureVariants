import 'dart:convert';

import 'package:esl_mobile_app/components/MyTextButton.dart';
import 'package:esl_mobile_app/components/my_card.dart';
import 'package:esl_mobile_app/styles/app_themes.dart';
import 'package:flutter/material.dart';
import '../models/ESL.dart';
import 'my_alert_dialog.dart';

class LmEslWidgetItem extends StatelessWidget {
  final esl;

  const LmEslWidgetItem({super.key, required this.esl});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          EslDescription(esl: esl),
        ],
      ),
    );
  }
}

class EslDescription extends StatelessWidget {
  final ESL esl;

  const EslDescription({super.key, required this.esl});

  String installationStatusDecoder(String code) {
    String value = '';
    switch (code) {
      case 'P':
        return 'Pendente';
      case 'H':
        return 'Pendurada';
      case 'K':
        return 'Instalada';
      case 'U':
        return 'Desinstalada';
      default:
        value = 'Não informado';
    }
    return value;
  }

  String commissioningStatusDecoder(String code) {
    String value = '';
    switch (code) {
      case 'P':
        return 'Pendente';
      case 'H':
        return 'Pendurada';
      case 'K':
        return 'Comissionada';
      case 'U':
        return 'Descomissisonada';
      default:
        value = 'Não informado';
    }
    return value;
  }

  String priceUpdateStatusDecoder(String code) {
    String value = '';
    switch (code) {
      case 'P':
        return 'Pendente';
      case 'H':
        return 'Pendurada';
      case 'K':
        return 'Atualizada';
      default:
        value = 'Não informado';
    }
    return value;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SelectableText(
              'MAC: ${esl.mac.toString().toUpperCase()}',
              style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  color: MyColorStyles.primary700),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    //Text("GIAI: ${esl.giai.getGIAI()}"),
                    //const SizedBox(height: 4),
                    Text(
                      "GTIN: ${esl.gtin}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Status da instalação: ${installationStatusDecoder(esl.installStatus)}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Status do comissionamento: ${commissioningStatusDecoder(esl.commissionStatus)}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Status da atualização de preço: ${priceUpdateStatusDecoder(esl.updateStatus)}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Operacional: ${(esl.isAlive ? 'Sim' : 'Não')}",
                      style: const TextStyle(fontSize: 13),
                    ),
                    const Text(
                      "Impressão da etiqueta:",
                      style: TextStyle(fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
              height: 8,
            ),
            Container(
              alignment: Alignment.center,
              //color: MyColorStyles.primary600,
              decoration: BoxDecoration(
                  border: Border.all(width: 5, color: MyColorStyles.primary300),
                  borderRadius: BorderRadius.circular(3)),
              child: esl.renderBase64 != null && esl.renderBase64 != ''
                  ? Image.memory(
                      base64Decode(esl.renderBase64 ?? ""),
                    )
                  : const Text('Não foi possível recuperar a impressão'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MyTextButton(
                  label: 'Encontre-me',
                  onPressed: () {
                    esl
                        .blink()
                        .then((value) => MyAlertDialog(success: value).build(
                              context,
                              titulo: value
                                  ? 'Solicitação para piscar LED enviada!'
                                  : 'Solicitação para piscar LED não foi enviada!',
                              mensagem: value
                                  ? 'Procure a etiqueta cujo LED esteja piscando em vermelho!'
                                  : 'Houve algum problema com a operação. Tente novamente mais tarde',
                              buttonLabel: 'Ok',
                            ))
                        .onError((error, stackTrace) =>
                            MyAlertDialog(success: false).build(
                              context,
                              titulo:
                                  'Solicitação para piscar LED não foi enviada!',
                              mensagem:
                                  'Houve algum problema com a operação. Mais informações: $error',
                              buttonLabel: 'Ok',
                            ));
                  },
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
