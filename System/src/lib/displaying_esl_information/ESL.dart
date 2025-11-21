import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:esl_mobile_app/models/global_asset_identifier.dart';
import 'package:esl_mobile_app/models/global_location_number.dart';
import 'package:esl_mobile_app/models/mac.dart';
import 'package:esl_mobile_app/services/cache_management.dart';
import 'package:flutter/widgets.dart';

import '../dto/user_dto.dart';
import '../utils/constants.dart';
import 'global_location_number_extension.dart';
import 'package:http/http.dart' as http;


class ESL {
  int clientId;
  String storeCode;
  MAC mac;
  GlobalIndividualAssetIdentifier giai;
  String gtin;

  //size
  String installStatus;
  String commissionStatus;
  String updateStatus;
  String? productName;
  bool isAlive;
  Image? render;
  String? renderBase64;
  GlobalLocationNumberExtension? sgln;
  GlobalLocationNumberExtension? sglnSplitMethod;

  ESL({required this.clientId,
    required this.storeCode,
    required this.mac,
    required this.giai,
    required this.gtin,
    required this.installStatus,
    required this.commissionStatus,
    required this.updateStatus,
    required this.isAlive,
    this.productName,
    this.sgln,
    this.sglnSplitMethod,
    this.render,
    this.renderBase64});

  factory ESL.fromJSONfetchedFromDataBase(Map<String, dynamic> json) {
    return ESL(
      clientId: json['client_id'],
      storeCode: json['store_code'],
      mac: MAC(mac: json['mac']),
      giai: json['giai'] ??
          GlobalIndividualAssetIdentifier(macValue: MAC(mac: json['mac'])),
      gtin: json['gtin'] ?? '',
      installStatus: json['installStatus'] ?? '',
      commissionStatus: json['commissionStatus'] ?? '',
      updateStatus: json['updateStatus'] ?? '',
      isAlive: (json['isAlive'] ?? false) ? true : false,
    );
  }

  factory ESL.fromJsonFetchedFromAPI(Map<String, dynamic> json) {
    var a = json['render'] != null ? json['render']['img'] : '';
    String storeCode = json['store_code'] ?? '';
    return ESL(
      clientId: json['client_id'],
      storeCode: storeCode,
      mac: MAC(mac: json['mac']),
      giai: json['giai'] ??
          GlobalIndividualAssetIdentifier(macValue: MAC(mac: json['mac'])),
      gtin: json['product_gtin'] ?? '',
      //size
      installStatus: json['install_status'] ?? '',
      commissionStatus: json['commission_status'] ?? '',
      updateStatus: json['update_status'] ?? '',
      isAlive: (json['is_valid'] ?? false) ? true : false,
      sgln: GlobalLocationNumberExtension(
        storeCode: storeCode,
        clientId: json['client_id'],
        section: json['depth_0'] ?? '',
        runner: json['depth_1'] ?? '',
        module: json['depth_2'] ?? '',
      ),
      sglnSplitMethod: GlobalLocationNumberExtension.fromStringSplitMethod(json['sgln'] ?? ''),
      render: Image.memory(base64Decode(a)),
      renderBase64: a,
      productName: json['product_title'],
    );
  }

  /*
  {
  "clientId": "1",
  "action": "blink",
  "transactionId": "",
  "data": {
    "eslMacs": ["ac233fd0b952"],
    "color": "red",
    "n": 5,
    "employeeCode": "790928",
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJMREFQIjoiNzkwOTI4IiwiaWF0IjoxNzA2NjQ1NDE4LCJleHAiOjE3MDY2ODg2MTh9.SJgWIb0kYIRwDRXRvQbB9NDDGgk0cfyptGhlfUIxRiE"
  },
  "timestamp": "2024-01-30T17:10:14.551219"
}*/


  Future<bool> blink() async {
    var cmpSuccess = Completer<bool>();
    UserDto? user = await CacheManagement().getUser();
    var authToken = user?.authToken;
    String clientId = '${user?.clientId}';
    String employeeCode = user?.code ?? '';

    http.post(
      Uri.parse(CONNECTOR_URL),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        HttpHeaders.authorizationHeader: authToken ?? '',
      },
      body: jsonEncode({
          "clientId": clientId,
          "action": "blink",
          "transactionId": "",
          "data": {
            "eslMacs": [mac.getMac()],
            "color": "red",
            "n": 10,
            "employeeCode": employeeCode,
            "token": authToken
          },
          "timestamp": DateTime.now().toLocal().toIso8601String()
      }),
    ).then((value) {
      if(value.statusCode == 200){
        cmpSuccess.complete(true);
      }else if(value.statusCode >= 400){
        cmpSuccess.completeError('Houve algum problema. Mais informações: ${value.reasonPhrase}');
      }
      if(!cmpSuccess.isCompleted){
      cmpSuccess.complete(false);
      }
    });
    return cmpSuccess.future;
  }
}
