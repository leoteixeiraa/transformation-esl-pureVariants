// ignore_for_file: avoid_print, non_constant_identifier_names

import 'package:esl_mobile_app/models/mac.dart';

import 'dto.dart';

class DecommissioningDto extends Dto {
  final String action = 'uncommission';
  MAC mac;

  int clientId;

  DecommissioningDto({
    //dto parent class atributtes
    required timestamp,
    required employeeLeroyCode,
    required authToken,
    String? mongoUsrActionsObjectId,
    String? statusDecription,
    //InstallationDto attributes
    required this.clientId,
    required this.mac,
  }) : super(
          timestamp: timestamp,
          authToken: authToken,
          employeeLeroyCode: employeeLeroyCode,
          mongoUsrActionsObjectId: mongoUsrActionsObjectId,
          statusDecription: statusDecription,
        );

  factory DecommissioningDto.fromJson(
      Map<String, dynamic> json, String authorizationToken) {
    return DecommissioningDto(
      clientId: json['client_id'] ?? 1,
      timestamp: json['timestamp'],
      mac: MAC(mac: json['esl_mac']),
      employeeLeroyCode: json['employee_leroy_code'],
      authToken: authorizationToken,
      mongoUsrActionsObjectId: json['mongoUsrActionsObjectId'],
      statusDecription: json['status'] ?? '',
    );
  }

  @override
  Map toJson() => {
        'esl_mac': mac.getMac(),
        'employee_leroy_code': employeeLeroyCode,
        'timestamp': timestamp,
      };

  @override
  Map dataToJson() => {
        'eslMacs': [mac.getMac()],
        'employeeCode': employeeLeroyCode, //placeholder
        'mongoUsrActionsObjectId': mongoUsrActionsObjectId ?? '',
        'token': authToken
      };

  @override
  Map<String, dynamic> mappingConnectorBodyRequest() => {
        "clientId": "$clientId",
        "transactionId": mongoUsrActionsObjectId ?? '',
        "action": action,
        "data": dataToJson(),
        "timestamp": timestamp,
      };

  @override
  Map<String, dynamic> mappingMongoBodyRequest(String storeBusinessUnitCode) =>
      {
        "action": action,
        "data": dataToJson(),
        "timestamp": timestamp,
        "storeCode": storeBusinessUnitCode,
      };
}

/* class DecommissioningDTO {
  final String action = 'uncommission';
  //final PhysicalLocation gln;
  late MAC _mac;
  late String _GTIN;
  String? _employeeLeroyCode;
  String? _timestamp;
  bool? _isValid;
  String? _status;
  String token;

  //Lucas, nesse caso sgln é gerado e não deve ser passado como parametro
  //melhor iniciar vazia ou usar "?"" no tipo?

  DecommissioningDTO(
      {required mac,
      required GTIN,
      required this.token,
      String? timestamp,
      String? employeeLeroyCode,
      bool? isValid,
      String? status}) {
    _mac = mac;
    _GTIN = GTIN;
    _timestamp = timestamp;
    _employeeLeroyCode = employeeLeroyCode;
    _isValid = isValid;
    _status = status;
  }

  String? getTimestamp() {
    return _timestamp;
  }

  String? setTimestamp(String? newTimestamp) {
    _timestamp = newTimestamp;
  }

  String getGTIN() {
    return _GTIN;
  }

  void setGTIN(String GTIN) {
    _GTIN = GTIN;
  }

  MAC getMac() {
    return _mac;
  }

  String? getEmployeeLeroyCode() {
    return _employeeLeroyCode;
  }

  bool? getIsValid() {
    return _isValid;
  }

  void setIsValid(bool? isValid) {
    _isValid = isValid;
  }

  String? getStatus() {
    return _status;
  }

  void setStatus(String status) {
    _status = status;
  }

  factory DecommissioningDTO.fromJson(Map<String, dynamic> json) {
    return DecommissioningDTO(
      timestamp: json['timestamp'],
      mac: MAC(mac: json['esl_mac']),
      employeeLeroyCode: json['employee_leroy_code'],
      isValid: json['isValid'],
      GTIN: json['product_gtin'],
      token: '',
    );
  }

  Map buildMessage() => {
        'action': action,
        'data': dataToJson(),
        'timestamp': _timestamp,
      };

  Map toJson() => {
        'esl_mac': _mac.getMac(),
        'product_gtin': _GTIN,
        'timestamp': _timestamp,
        'employee_leroy_code': _employeeLeroyCode,
        'isValid': _isValid
      };

  Map dataToJson() {
    return {
      'eslMac': _mac.getMac(),
      'employeeCode': _employeeLeroyCode,
      'token': token
    };
  }
}
 */