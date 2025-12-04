import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/ESL.dart';
import '../styles/app_themes.dart';
import 'MyTextButton.dart';
import 'my_alert_dialog.dart';

class CmpEslListTile extends StatefulWidget {
  ESL esl;

  CmpEslListTile({super.key, required this.esl});

  @override
  State<CmpEslListTile> createState() => _CmpEslListTileState();
}

class _CmpEslListTileState extends State<CmpEslListTile>
    with SingleTickerProviderStateMixin {
  Color iconButtonColor = Colors.black;
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000), value: 1);
    //_animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Flex(
        direction: Axis.horizontal,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(widget.esl.mac.getMac())
          // Text("teste")
        ],
      ),
      subtitle: Text(
        widget.esl.sglnSplitMethod == null
            ? 'teste'
            : 'Módulo ${widget.esl.sglnSplitMethod!.module} '
            'do corredor ${widget.esl.sglnSplitMethod!.runner} ',
        style: const TextStyle(color: Colors.black, fontSize: 13),
      ),
    );
  }

  String installationStatusDecoder(String code) {
    String value = '';
    switch (code) {
      case 'P':
        return 'Pendente';
      case 'H':
        return 'Pendurada';
      case 'K':
        return 'Instalada';
      case 'U':
        return 'Desinstalada';
      default:
        value = 'Não informado';
    }
    return value;
  }

  String commissioningStatusDecoder(String code) {
    String value = '';
    switch (code) {
      case 'P':
        return 'Pendente';
      case 'H':
        return 'Pendurada';
      case 'K':
        return 'Comissionada';
      case 'U':
        return 'Descomissisonada';
      default:
        value = 'Não informado';
    }
    return value;
  }

  String priceUpdateStatusDecoder(String code) {
    String value = '';
    switch (code) {
      case 'P':
        return 'Pendente';
      case 'H':
        return 'Pendurada';
      case 'K':
        return 'Atualizada';
      default:
        value = 'Não informado';
    }
    return value;
  }
}
