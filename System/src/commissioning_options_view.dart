import 'dart:convert';
import 'dart:developer';
//import 'package:dartzmq/dartzmq.dart';
import 'package:esl_mobile_app/components/lm_menu_list_row.dart';
import 'package:esl_mobile_app/dto/commissioning_dto.dart';
import 'package:esl_mobile_app/services/commissioning_process_manager.dart';
import 'package:esl_mobile_app/views/Commissioning/commissioning_view.dart';
import 'package:esl_mobile_app/views/Commissioning/commissioning_logs_view.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter/material.dart';
import 'package:esl_mobile_app/db/database_connection.dart';
import 'package:esl_mobile_app/db/logs_shared_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CommissioningOptionsView extends StatefulWidget {
  const CommissioningOptionsView({super.key});
  @override
  State<CommissioningOptionsView> createState() =>
      _CommissioningOptionsViewState();
}

class _CommissioningOptionsViewState extends State<CommissioningOptionsView> {
  final formKey = GlobalKey<FormState>();

  // Future<List<CommissioningDTO>> getCommissionings() async {
  //   final db = DatabaseConnection();
  //   await db.open();
  //   var queryResult =
  //       await db.query('SELECT * FROM "tbl_commissions" LIMIT 50');
  //   db.close();

  //   log('QUERY: ${queryResult}');

  //   List<String> unsucessfulCommissionings =
  //       await LogsSharedPreferences.getLogs('commissionings');

  //   List<CommissioningDTO> list = [];

  //   for (var commissioning in queryResult) {
  //     commissioning.forEach(
  //       (key, value) {
  //         if (value['is_valid'] == true) {
  //           list.add(
  //             CommissioningDTO.fromJson({
  //               'timestamp': value['timestamp'].toString(),
  //               'esl_mac': value['esl_mac'],
  //               'employee_leroy_code': value['employee_leroy_code'],
  //               'is_valid': value['is_valid'],
  //               'product_gtin': value['product_gtin'],
  //             }),
  //           );
  //         }
  //         unsucessfulCommissionings.removeWhere((e) =>
  //             (jsonDecode(e)['esl_mac'] == value['esl_mac']) &&
  //             jsonDecode(e)['product_gtin'] == value['product_gtin']);
  //       },
  //     );
  //   }

  //   Map<String, CommissioningDTO> filteredUnsucessfulCommissionings = {};

  //   List<CommissioningDTO> unsucessfulCommissioningsObjects = [];
  //   for (var commissioning in unsucessfulCommissionings) {
  //     var unsucessfulCommissioningsObject =
  //         CommissioningDTO.fromJson(jsonDecode(commissioning));
  //     unsucessfulCommissioningsObject.setStatus('FAILED');
  //     String key =
  //         '${unsucessfulCommissioningsObject.getMac()}-${unsucessfulCommissioningsObject.getSGTIN()}';
  //     if (!filteredUnsucessfulCommissionings.containsKey(key) ||
  //         DateTime.parse(
  //                 filteredUnsucessfulCommissionings[key]!.getTimestamp() ?? "")
  //             .isBefore(DateTime.parse(
  //                 unsucessfulCommissioningsObject.getTimestamp() ?? ""))) {
  //       filteredUnsucessfulCommissionings[key] =
  //           unsucessfulCommissioningsObject;
  //     }
  //   }

  //   unsucessfulCommissioningsObjects =
  //       filteredUnsucessfulCommissionings.values.toList();

  //   List<CommissioningDTO> commissioningList =
  //       list + unsucessfulCommissioningsObjects;

  //   commissioningList.sort((a, b) => DateTime.parse(b.getTimestamp() ?? "")
  //       .compareTo(DateTime.parse(a.getTimestamp() ?? "")));

  //   return commissioningList;
  // }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(title: const Text('Comissionamento')),
      body: ListView(
        children: [
          Column(
            children: [
              LmMenuListRow.buildPageTitle('Selecione a operação desejada'),
              LmMenuListRow.createLineDividider(),
              LmMenuListRow(
                title: 'Comissionar',
                description:
                    'Vincule uma etiqueta de preço a um produto da loja',
                actionFunction: () => _commisisoningAction(context),
                rowIcon: Icons.link,
              ),
              LmMenuListRow.createLineDividider(),
              LmMenuListRow(
                title: 'Checar comissionamentos',
                description:
                    'Verifique se o comissionamento foi bem-sucedido ou não',
                actionFunction: () => _commissioningStatusCheckAction(context),
                rowIcon: Icons.check,
              ),
              LmMenuListRow.createLineDividider(),
            ],
          ),
        ],
      ));

  Future<void> _commissioningStatusCheckAction(BuildContext context) async {
    List<CommissioningDto> commissionings = [];
    //TODO: PRAQQ ERA ISSO(await CommissioningProcessManager().getCommissionings());

    // ignore: use_build_context_synchronously
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => const CommissioningLogsView()));
  }

  void _commisisoningAction(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CommissioningView(),
      ),
    );
  }
}
