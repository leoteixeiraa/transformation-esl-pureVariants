import 'dart:convert';
import 'dart:typed_data';

import 'package:esl_mobile_app/dao/esl_dao.dart';
import 'package:esl_mobile_app/models/actionArguments/SearchByMacArguments.dart';
import 'package:esl_mobile_app/models/actionArguments/installation_arguments.dart';
import 'package:esl_mobile_app/styles/app_themes.dart';
import 'package:flutter/material.dart';

import '../../../components/lm_esl_widget_item.dart';
import '../../../models/ESL.dart';

class Step2SearchByMac extends StatefulWidget {
  Step2SearchByMac({super.key});

  String? image;

  @override
  State<Step2SearchByMac> createState() => _Step2SearchByMacState();
}

class _Step2SearchByMacState extends State<Step2SearchByMac> {
  late SearchByMacArguments? args;

  @override
  Widget build(BuildContext context) {
    Color textColor = MyColorStyles.grey300;
    args = ModalRoute.of(context)!.settings.arguments as SearchByMacArguments;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Consulta de etiqueta", style: TextStyle(fontSize: 24)),
      ),
      body: _buildEslList(args?.macAddress),
    );
  }

  Widget _buildEslList(String? mac) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Dados da etiqueta',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          Flexible(
            fit: FlexFit.loose,
            flex: 10,
            child: FutureBuilder<ESL>(
              future: EslDao().getEslByMac(mac ?? ''),
              // The future to wait for
              builder: (BuildContext context, AsyncSnapshot<ESL> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  // While the future is loading
                  return const CircularProgressIndicator();
                } else if (snapshot.hasError) {
                  // If an error occurred
                  return Text('Error: ${snapshot.error}');
                } else {
                  // If the future completed successfully
                  if (snapshot.data == null) {
                    return const Text('Nenhuma ESL encontrada!');
                  }
                  widget.image = snapshot.data!.renderBase64;
                  return Column(
                    children: [
                      LmEslWidgetItem(esl: snapshot.data),
                    ],
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
