import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

import '../dto/decommissioning_dto.dart';
import 'dao.dart';

// ignore_for_file: unused_local_variable
class DecommissioningDao extends Dao {
  Future<List<DecommissioningDto>> getAllByEmployeeCode() async {
    List<DecommissioningDto> list;
    var cmpDecommissioningList = Completer<List<DecommissioningDto>>();

    dynamic decommissioningListJson;

    var employeeCode = await SessionManager().get('leroy_code');
    var token = await SessionManager().get('token');

    var storeBusinessUnitCode =
        await SessionManager().get('store_business_unit_code');

    super.buildRequest('/actions/commissions/$employeeCode').then((value) {
      if (value.statusCode == 200) {
        decommissioningListJson = jsonDecode(value.body);
        debugPrint('DecommissioningDao (27): $decommissioningListJson');
        list = (decommissioningListJson as List)
            .map((data) => DecommissioningDto.fromJson(data, token))
            .toList();
        list.sort(
          (a, b) => a.timestamp.compareTo(b.timestamp),
        );
        cmpDecommissioningList.complete(list);
      } else {
        cmpDecommissioningList.completeError(
            'Não foi possível buscar a lista de descomissionamentos pela API. Mais informações: [${value.statusCode}] ${value.reasonPhrase}');
        debugPrint(
            'Não foi possível buscar a lista de descomissionamentos pela API. Mais informações: [${value.statusCode}] ${value.reasonPhrase}');
      }
    });
    return cmpDecommissioningList.future;
  }
}
