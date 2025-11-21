/* import 'package:esl_mobile_app/components/cmp_navigation_bar.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
import 'package:esl_mobile_app/models/dto/uninstallation_dto.dart';
import 'package:esl_mobile_app/services/uninstallation_manager.dart';
import 'package:esl_mobile_app/styles/lm_text_style.dart'; */
import 'package:esl_mobile_app/components/lm_uninstallation_log_item.dart';
import 'package:esl_mobile_app/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:esl_mobile_app/dto/uninstallation_dto.dart';
import 'package:esl_mobile_app/models/mac.dart';
import 'package:esl_mobile_app/db/database_connection.dart';
import 'dart:developer' as dev;

import '../../dao/uninstallation_dao.dart';

//TODO: add a FutureBuilder

class UninstallationLogsView extends StatefulWidget {
  final List<UninstallationDto> uninstallationsList;
  const UninstallationLogsView({
    super.key,
    required this.uninstallationsList,
  });
  @override
  State<UninstallationLogsView> createState() => _UninstallationLogsViewState();
}

class _UninstallationLogsViewState extends State<UninstallationLogsView> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Desinstalação')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verificar desinstalações',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Flexible(
                child: FutureBuilder<List<UninstallationDto>>(
                  future: UninstallationDao()
                      .getAllByEmployeeCode(), // The future to wait for
                  builder: (BuildContext context,
                      AsyncSnapshot<List<UninstallationDto>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While the future is loading
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // If an error occurred
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // If the future completed successfully
                      if (snapshot.data!.isEmpty) {
                        return const Text(
                          'Faça uma desinstalação para que ela visualizada aqui.',
                        );
                      }
                      return ListView(
                        children: snapshot.data!.map((e) {
                          return LmUninstallationLogItem(dto: e);
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
