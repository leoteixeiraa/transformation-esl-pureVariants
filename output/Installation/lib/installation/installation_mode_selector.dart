import 'package:esl_mobile_app/components/lm_menu_list_row.dart';
import 'package:esl_mobile_app/views/Installation/installation_view.dart';
import 'package:esl_mobile_app/views/Installation/installation_mode_qrcode_reader.dart';
import 'package:flutter/material.dart';

class InstallationModeSelector extends StatefulWidget {
  const InstallationModeSelector({super.key});

  @override
  State<InstallationModeSelector> createState() =>
      _InstallationModeSelectorState();
}

class _InstallationModeSelectorState extends State<InstallationModeSelector> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instalação')),
      body: ListView(
        children: [
          LmMenuListRow.buildPageTitle('Selecione o modo de instalação'),
          LmMenuListRow.createLineDividider(),
          LmMenuListRow(
            title: 'Informe a localização manualmente',
            description:
                'Use caixas de seleção para indicar a localização física',
            actionFunction: () => _installationWithCombobox(),
            rowIcon: Icons.input,
          ),
          LmMenuListRow.createLineDividider(),
          LmMenuListRow(
            title: 'Informe a localização com leitor',
            description:
                'Utilize a câmera para ler o QRCode da localização física',
            actionFunction: _installationWithBarcodeReader,
            rowIcon: Icons.qr_code_scanner,
          ),
          LmMenuListRow.createLineDividider(),
        ],
      ),
    );
  }

  void _installationWithCombobox() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InstallationView(),
      ),
    );
  }

  void _installationWithBarcodeReader() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const InstallationModeQrcodeReaderView(),
      ),
    );
  }
}
