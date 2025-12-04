import 'package:esl_mobile_app/components/lm_menu_list_row.dart';
import 'package:esl_mobile_app/db/logs_shared_preferences.dart';
import 'package:esl_mobile_app/views/Uninstallation/uninstallation_view.dart';
import 'package:esl_mobile_app/views/Uninstallation/uninstallation_logs_view.dart';
import 'package:esl_mobile_app/views/Uninstallation/uninstallation_view.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:esl_mobile_app/db/database_connection.dart';
import 'package:esl_mobile_app/dto/uninstallation_dto.dart';
import 'dart:developer' as dev;
import 'dart:convert';

import '../../models/mac.dart';

class UninstallationOptionsView extends StatefulWidget {
  const UninstallationOptionsView({super.key});
  @override
  State<UninstallationOptionsView> createState() =>
      _UninstallationOptionsViewState();
}

class _UninstallationOptionsViewState extends State<UninstallationOptionsView> {
  String? _mac;

  final formKey = GlobalKey<FormState>();
  TextEditingController scan = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Desinstalação')),
      body: ListView(
        children: [
          Column(
            children: [
              LmMenuListRow.buildPageTitle('Selecione a operação desejada'),
              LmMenuListRow.createLineDividider(),
              LmMenuListRow(
                title: 'Desinstalar',
                description:
                    'Desvincule uma etiqueta de preço à sua localização física dentro da loja',
                actionFunction: () => _uninstallAction(context),
                rowIcon: Icons.file_download_off_outlined,
              ),
              LmMenuListRow.createLineDividider(),
              LmMenuListRow(
                title: 'Checar desinstalações',
                description:
                    'Verifique se a desinstalação foi bem-sucedida ou não',
                actionFunction: () => _uninstallationStatusCheckAction(context),
                rowIcon: Icons.check,
              ),
              LmMenuListRow.createLineDividider(),
            ],
          ),
        ],
      ));

  Future<void> _uninstallationStatusCheckAction(BuildContext context) async {
    /*var uninstallationsList =
        await LogsSharedPreferences.getLogs('uninstallations');
    List<UninstallationDto> list = [];
     for (var e in uninstallationsList) {
      dev.log(e);
      var auxDto = UninstallationDto.fromJson(
        jsonDecode(
          e.substring(1),
        ),
      );
      if (e.startsWith('f')) {
        auxDto.localStatus = false;
      } else if (e.startsWith('t')) {
        auxDto.localStatus = true;
      }
      list.add(auxDto);
    }
    list.sort(
      (a, b) {
        if (a.getTimestamp().compareTo(b.getTimestamp()) > 0) {
          return 0;
        }
        return 1;
      },
    ); */
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const UninstallationLogsView(uninstallationsList: []),
      ),
    );
  }

  void _uninstallAction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const UninstallationView(),
      ),
    );
  }
}
