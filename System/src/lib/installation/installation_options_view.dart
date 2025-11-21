import 'package:esl_mobile_app/views/Installation/installation_mode_selector.dart';
import 'package:esl_mobile_app/views/Installation/installation_logs_view.dart';
import 'package:flutter/material.dart';
import 'package:esl_mobile_app/dto/installation_dto.dart';
import 'package:esl_mobile_app/styles/app_themes.dart';

import '../../components/lm_menu_list_row.dart';
import '../../services/installation_process_manager.dart';

class InstallationOptionsView extends StatefulWidget {
  const InstallationOptionsView({super.key});

  @override
  State<InstallationOptionsView> createState() =>
      _InstallationOptionsViewState();
}

class _InstallationOptionsViewState extends State<InstallationOptionsView> {
  final formKey = GlobalKey<FormState>();
  TextEditingController scan = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instalação')),
      body: ListView(
        children: [
          Column(
            children: [
              LmMenuListRow.buildPageTitle('Selecione a operação desejada'),
              LmMenuListRow.createLineDividider(),
              LmMenuListRow(
                title: 'Instalar',
                rowIcon: Icons.file_download_outlined,
                description:
                    'Vincule uma etiqueta de preço à sua localização física dentro da loja',
                actionFunction: () => _newInstallationAction(),
              ),
              LmMenuListRow.createLineDividider(),
              LmMenuListRow(
                  title: 'Checar instalações',
                  rowIcon: Icons.check,
                  description:
                      'Verifique se a sua instalação foi bem-sucedida ou não',
                  actionFunction: () {
                    _checkInstallationsStatusAction();
                  }),
              LmMenuListRow.createLineDividider(),
            ],
          ),
        ],
      ),
      /* floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
        height: 50,
        width: double.infinity,
        child: _buildBackButton(),
      ), */
    );
  }

  Widget _buildBackButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: ElevatedButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Voltar'),
      ),
    );
  }

  void _checkInstallationsStatusAction() async {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const InstallationLogsView()));
  }

  void _newInstallationAction() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InstallationModeSelector(),
      ),
    );
  }
}
