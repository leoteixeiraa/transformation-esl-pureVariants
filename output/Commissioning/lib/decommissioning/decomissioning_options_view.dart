import 'dart:convert';

import 'package:esl_mobile_app/components/lm_menu_list_row.dart';
import 'package:esl_mobile_app/dto/decommissioning_dto.dart';
import 'package:esl_mobile_app/views/Commissioning/decommissioning_view.dart';
import 'package:esl_mobile_app/views/Commissioning/decommissioning_logs_view.dart';
import 'package:flutter/material.dart';
import 'package:esl_mobile_app/db/logs_shared_preferences.dart';
import 'package:esl_mobile_app/views/Map/map_view.dart';

import '../../db/database_connection.dart';
import '../../services/commissioning_process_manager.dart';

class DecommissioningOptionsView extends StatefulWidget {
  const DecommissioningOptionsView({super.key});
  @override
  State<DecommissioningOptionsView> createState() =>
      _DecommissioningOptionsViewState();

//   String commissioningStatusDecoder(String code) {
//     String value = '';
//     switch (code) {
//       case 'P':
//         return 'Pendente';
//       case 'H':
//         return 'Pendurada';
//       case 'K':
//         return 'Comissionada';
//       case 'U':
//         return 'Descomissisonada';
//       default:
//         value = 'Não informado';
//     }
//     return value;
//   }

//   Future<List<DecommissioningDTO>> getDecommissiongs(String which) async {
//     //logs are the decommissioning submitions saved locally into the device
//     var logs = await LogsSharedPreferences.getLogs('decommissionings');
//     List<DecommissioningDTO> decommissionings = [];

//     final db = DatabaseConnection();

//     await db.open();

//     for (String decommissioning in logs) {
//       Map<String, dynamic> jsonDecommissioning = jsonDecode(decommissioning);

//       if (which == 'sucessful') {
//         if (jsonDecommissioning['status'] == 'SUCCESS') {
//           decommissionings
//               .add(DecommissioningDTO.fromJson(jsonDecommissioning));
//         }
//       } else if (which == 'failed') {
//         if (jsonDecommissioning['status'] == 'FAILED') {
//           decommissionings
//               .add(DecommissioningDTO.fromJson(jsonDecommissioning));
//         }
//       } else {
//         DecommissioningDTO decomissioning =
//             DecommissioningDTO.fromJson(jsonDecommissioning);
//         var eslComissioningStatus = await db.query(
//             'SELECT commission_status FROM "tbl_esls" WHERE mac = \'${decomissioning.getMac().getMac()}\'');

//         debugPrint(commissioningStatusDecoder(
//             eslComissioningStatus[0]['tbl_esls']?['commission_status']));
//         decomissioning.setStatus(commissioningStatusDecoder(
//             eslComissioningStatus[0]['tbl_esls']?['commission_status']));

//         decommissionings.add(decomissioning);
//       }
//     }
//     db.close();

//     decommissionings.sort((a, b) => DateTime.parse(b.getTimestamp() ?? "")
//         .compareTo(DateTime.parse(a.getTimestamp() ?? "")));
//     return decommissionings;
//   }
}

class _DecommissioningOptionsViewState
    extends State<DecommissioningOptionsView> {
  List<DecommissioningDto> sucessfulDecommisionings = [];
  List<DecommissioningDto> unsucessfulDecommisionings = [];
  final formKey = GlobalKey<FormState>();
  TextEditingController scan = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Descomissionamento')),
      body: ListView(
        children: [
          Column(
            children: [
              LmMenuListRow.buildPageTitle('Selecione a operação desejada'),
              LmMenuListRow.createLineDividider(),
              LmMenuListRow(
                title: 'Descomissionar',
                description:
                    'Desvincule uma etiqueta de preço a um produto da loja',
                actionFunction: () => _decommissioningAction(context),
                rowIcon: Icons.link_off,
              ),
              LmMenuListRow.createLineDividider(),
              LmMenuListRow(
                title: 'Checar descomissionamentos',
                description:
                    'Verifique se o descomissionamento foi bem-sucedido ou não',
                actionFunction: () =>
                    _checkDecommissioningStatusAction(context),
                rowIcon: Icons.check,
              ),
              LmMenuListRow.createLineDividider(),
            ],
          ),
        ],
      ));

  Future<void> _checkDecommissioningStatusAction(BuildContext context) async {
    var decommisionings = [];
    //TODO: VER PRA QQ SERVE ISSO await CommissioningProcessManager().getDecommissiongs('all');
    // ignore: use_build_context_synchronously
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const DecommissioningLogsView(decommissioningsList: []),
      ),
    );
  }

  void _decommissioningAction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DecommissioningView(),
      ),
    );
  }
}
