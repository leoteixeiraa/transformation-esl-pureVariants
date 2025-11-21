import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:esl_mobile_app/services/cache_management.dart';
import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:http/http.dart' as http;

import '../dto/user_dto.dart';
import '../models/ESL.dart';
import '../utils/constants.dart';

class EslDao {
  Future<List<ESL>> getAll() async {
    var cmp = Completer<List<ESL>>();
    List<ESL> eslList;
    var token = (await CacheManagement().getUser())?.authToken;

    final response = await http.get(
      Uri.parse('$API_URL/esls'),
      headers: {
        HttpHeaders.authorizationHeader: token ?? '',
      },
    ).then(
          (value) =>
      {
        eslList = (jsonDecode(value.body) as List)
            .map((e) => ESL.fromJsonFetchedFromAPI(e))
            .toList(),
        cmp.complete(eslList),
      },
    );
    return cmp.future;
  }

  Future<List<ESL>> getAllWithDetails() async {
    var cmp = Completer<List<ESL>>();
    List<ESL> eslList;
    var token = (await CacheManagement().getUser())?.authToken;
    UserDto? user = await CacheManagement().getUser();
    int clientId = user!.clientId;
    String storeCode = user!.storeCode;


    final response = await http.get(
      Uri.parse('$API_URL/esls/details?client_id=$clientId&store_code=$storeCode'),
      headers: {
        HttpHeaders.authorizationHeader: token ?? '',
      },
    ).then(
          (value) =>
      {
        if(value.statusCode == 200){
        eslList = (jsonDecode(value.body) as List)
            .map((e) => ESL.fromJsonFetchedFromAPI(e))
            .toList(),
        cmp.complete(eslList),
        }else if( value.statusCode >=400){
          cmp.completeError('Erro durante a busca de dispositivos. Mais informações: ${value.reasonPhrase}'),
        }
      },
    );
    return cmp.future;
  }

  Future<ESL> getEslByMac(String mac) async {
    var cmp = Completer<ESL>();
    ESL esl;
    List<dynamic> bodyResp;
    var token = (await CacheManagement().getUser())?.authToken;

    final response = await http.get(
      Uri.parse('$API_URL/esls/mac/${mac.toLowerCase()}'),
      headers: {
        HttpHeaders.authorizationHeader: token ?? '',
      },
    ).then(
          (value) =>
      {
        if(value.statusCode == 200){
          esl = ESL.fromJsonFetchedFromAPI(jsonDecode(value.body).first),
          cmp.complete(esl),
        }else if(value.statusCode == 404){
          cmp.completeError('Erro durante a consulta de dispositivo: dispositivo não encontrado!'),
        }
      },
    );


    return cmp.future;
  }
}
