import 'package:esl_mobile_app/models/mac.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';

import 'dto.dart';

class UninstallationDto extends Dto {
  //class variables
  final String _action = 'uninstall';
  MAC mac;int clientId;

  //class unnammed contructor
  UninstallationDto({
    //dto parent class atributtes
    required String timestamp,
    required String employeeLeroyCode,
    required String authToken,
    String? mongoUsrActionsObjectId,
    String? statusDecription,
    //UninstallationDto attributes
    required this.clientId,
    required this.mac,
  }) : super(
          timestamp: timestamp,
          authToken: authToken,
          employeeLeroyCode: employeeLeroyCode,
          mongoUsrActionsObjectId: mongoUsrActionsObjectId,
          statusDecription: statusDecription,
        ) {
    //debugPrint('Udto(25): ${this.timestamp}');
  }

  //class nammed contructor
  factory UninstallationDto.fromJson(
      Map<String, dynamic> json, String authorizationToken) {
    return UninstallationDto(
      clientId: json['client_id'],
      timestamp: json['timestamp'].toString(),
      mac: MAC(mac: json['data']['eslMac'] ?? ''),
      employeeLeroyCode: json['employeeCode'] ?? '',
      authToken: authorizationToken,
      mongoUsrActionsObjectId: json['mongoUsrActionsObjectId'],
      statusDecription: json['status'] ?? '',
    );
  }

  //methods implementation
  @override
  Map toJson() => {
        'timestamp': timestamp,
        'esl_mac': mac.getMac(),
        'employee_leroy_code': employeeLeroyCode,
      };

  @override
  Map dataToJson() => {
        'eslMacs': [mac.getMac()],
        'employeeCode': employeeLeroyCode, //placeholder
        'mongoUsrActionsObjectId': mongoUsrActionsObjectId ?? '',
        'token': authToken,
      };

  @override
  Map<String, dynamic> mappingConnectorBodyRequest() => {
        "clientId": "$clientId",
        "transactionId": mongoUsrActionsObjectId ?? '',
        "action": _action,
        "data": dataToJson(),
        "timestamp": timestamp,
      };

  @override
  Map<String, dynamic> mappingMongoBodyRequest(String storeBusinessUnitCode) =>
      {
        "action": "uninstall",
        "data": dataToJson(),
        "timestamp": timestamp,
        "storeCode": storeBusinessUnitCode,
      };

  @override
  Map<String, dynamic> dataFromJson() {
    // TODO: implement dataFromJson
    throw UnimplementedError();
  }
}
