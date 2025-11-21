import 'dart:convert';

import 'package:esl_mobile_app/dto/commissioning_dto.dart';
import 'package:esl_mobile_app/models/Product.dart';
import 'package:esl_mobile_app/services/process_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import '../../../../dto/decommissioning_dto.dart';
import '../../../../dto/user_dto.dart';
import '../../../../models/mac.dart';
import '../../../cache_management.dart';

int requisicaoRecebida = 0;

class CommissioningProcessManager extends ProcessManager {
  Future<http.Response> commission({
    required String sgtinParameter,
    required String macParameter,
  }) async {
    //getting session informations
    UserDto? user = await CacheManagement().getUser();
    String token = user!.authToken;
    String employeeCode = user!.code;
    String storeBusinessUnitCode = user!.storeCode;

    //building dto
    var dto = CommissioningDto(
      clientId: user!.clientId,
      authToken: token,
      employeeLeroyCode: employeeCode,
      mac: MAC(mac: macParameter),
      product: Product(SGTIN: sgtinParameter),
      timestamp: DateTime.now().toLocal().toIso8601String(),
    );

    String? mongoUsrActionsObjectId;
    String mongoBodyReq = dto.buildMongoBodyRequest(storeBusinessUnitCode);
    debugPrint('CPM(41): (commission) connectorBody: $mongoBodyReq');
    //send to mongo
    await sendToMongo(
      authToken: token,
      body: mongoBodyReq,
    ).then(
      (value) {
        mongoUsrActionsObjectId = jsonDecode(value.body)['insertedId'];
      },
    );
    dto.mongoUsrActionsObjectId = mongoUsrActionsObjectId ?? '';

    String connectorBodyReq = dto.buildConnectorBodyRequest();
    debugPrint('CPM(54): (commission) connectorBody: $connectorBodyReq');
    //send to connector and return future value
    return sendToConnector(
      authToken: token,
      body: connectorBodyReq,
    );
  }

  Future<http.Response> decommission({
    required String macParameter,
  }) async {
    //getting session informations
    UserDto? user = await CacheManagement().getUser();
    String token = user!.authToken;
    String employeeCode = user!.code;
    String storeBusinessUnitCode = user!.storeCode;

    //building dto
    var dto = DecommissioningDto(
      clientId: user!.clientId,
      authToken: token,
      employeeLeroyCode: employeeCode,
      mac: MAC(mac: macParameter),
      timestamp: DateTime.now().toLocal().toIso8601String(),
    );

    String? mongoUsrActionsObjectId;

    //send to mongo

    await sendToMongo(
      authToken: token,
      body: dto.buildMongoBodyRequest(storeBusinessUnitCode),
    ).then((value) {
      print('CPM(38): ${value.body}');
      mongoUsrActionsObjectId = jsonDecode(value.body)['insertedId'];
    });
    dto.mongoUsrActionsObjectId = mongoUsrActionsObjectId ?? '';

    //send to connector and return future value
    return sendToConnector(
      authToken: token,
      body: dto.buildConnectorBodyRequest(),
    );
  }
}
