/* import 'package:esl_mobile_app/components/cmp_navigation_bar.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart'
import 'package:esl_mobile_app/models/dto/uninstallation_dto.dart';
import 'package:esl_mobile_app/services/uninstallation_manager.dart';
import 'package:esl_mobile_app/styles/lm_text_style.dart'; */

import 'package:esl_mobile_app/components/lm_installation_log_item.dart';
import 'package:flutter/material.dart';
import 'package:esl_mobile_app/dto/installation_dto.dart';
import 'dart:developer' as dev;

import '../../dao/installation_dao.dart';

class InstallationLogsView extends StatefulWidget {
  const InstallationLogsView({
    super.key,
  });
  @override
  State<InstallationLogsView> createState() => _InstallationLogsViewState();
}

class _InstallationLogsViewState extends State<InstallationLogsView> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Instalação')),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verificar instalações',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Flexible(
                child: FutureBuilder<List<InstallationDto>>(
                  future: InstallationDao()
                      .getAllByEmployeeCode(), // The future to wait for
                  builder: (BuildContext context,
                      AsyncSnapshot<List<InstallationDto>> snapshot) {
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
                            'Faça uma instalação para que ela visualizada aqui.');
                      }
                      return ListView(
                        children: snapshot.data!.map((e) {
                          return LmInstallationLogItem(dto: e);
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

  /* ListView _buildLV() {
    return ListView(
      children: widget.installationsList.map((e) {
        return LmInstallationLogItem(dto: e);
      }).toList(),
    );
  } */
}
