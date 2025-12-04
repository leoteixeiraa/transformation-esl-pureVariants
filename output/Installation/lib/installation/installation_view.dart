import 'dart:async';
import 'package:esl_mobile_app/components/lm_dropdown_button.dart';
import 'package:esl_mobile_app/dao/physical_location_dao.dart';

import 'package:esl_mobile_app/models/global_location_number_extension.dart';
import 'package:esl_mobile_app/utils/constants.dart';

import 'package:flutter/material.dart';
import 'package:esl_mobile_app/services/barcode_scanner/scanner.dart';
import 'package:esl_mobile_app/services/installation_process_manager.dart';
import 'dart:developer' as dev;

import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'installation_logs_view.dart';

class InstallationView extends StatefulWidget {
  const InstallationView({super.key});

  @override
  State<StatefulWidget> createState() => _InstallationViewState();
}

class _InstallationViewState extends State<InstallationView> {
  //formkey - the forms identifier
  final _formKey = GlobalKey<FormState>();

  String _mac = '';
  //DROPDOWN LISTS
  //These lists fills the dropdown items
  late final String _store;
  List<dynamic>? _sectionList = [];
  List<dynamic>? _shelfList = [];
  List<dynamic>? _levelList = [];
  List<dynamic>? _slotList = [];
  List<dynamic>? _faceList = [];

  //LOADING FLAG
  //Used when fetching data is not completed
  bool _loading = false;

  var dao = PhysicalLocationDAO();

  //SELECTED VALUES FROM THE DROPDOWNS
  //(await SharedPreferences.getInstance()).getString('store_business_unit_code')??
  Map<String, String> selectedValues = {
    'store': '',
    'section': '',
    'shelf': '',
    'level': '',
    'slot': '',
    'face': '',
  };

  //MAC ADDRESS SCANNER
  TextEditingController scan = TextEditingController();
  var macAddressScanner = Scanner();

  @override
  void initState() {
    _loading = true;
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _restart() {
/*     setState(() {
      _section = "";
      _shelf = "";
      _level = "";
      _slot = "";
      _face = "";
      _mac = '';
      _loading = false;
      scan = TextEditingController();
      macAddressScanner = Scanner();
      //_sectionList = null;
      _shelfList = null;
      _levelList = null;
      _slotList = null;
      _faceList = null;
    }); */
  }

  void cleanDropdownItemsList(String selectedDropdownLabel) {
    /* dev.log('I90: teste');
    if (selectedDropdownLabel.compareTo("section") == 0) {
      setState(() {
        _shelf = "";

        _levelList = null;
        _level = "";

        _slotList = null;
        _slot = "";

        _faceList = null;
        _face = "";
      });
      return;
    }

    if (selectedDropdownLabel.compareTo("shelf") == 0) {
      setState(() {
        _level = "";

        _slotList = null;
        _slot = "";

        _faceList = null;
        _face = "";
      });
      return;
    }
    if (selectedDropdownLabel.compareTo("level") == 0) {
      setState(() {
        _slot = "";

        _faceList = null;
        _face = "";
      });
      return;
    }

    return; */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instalação')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // _buildSglnCard(),
            const SizedBox(height: 16),
            _buildMacCard(),
            const SizedBox(height: 16),
            _buildButtonRow(),
          ],
        ),
      ),
    );
  }

  // Widget _buildSglnCard() => Card(
  //       child: Padding(
  //         padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
  //         child: Column(
  //             mainAxisSize: MainAxisSize.min,
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Row(
  //                 children: [
  //                   Text(
  //                     'Localização física',
  //                     style: Theme.of(context).textTheme.titleLarge,
  //                   )
  //                 ],
  //               ),
  //               const SizedBox(height: 16),
  //               Row(
  //                 children: [
  //                   Text(
  //                     'Código da loja: ',
  //                     style: Theme.of(context).textTheme.titleSmall,
  //                   ),
  //                   FutureBuilder(
  //                       future: SharedPreferences.getInstance(),
  //                       builder: (context, snapshot) {
  //                         if (snapshot.connectionState ==
  //                             ConnectionState.waiting) {
  //                           // While the future is loading
  //                           return const CircularProgressIndicator();
  //                         } else if (snapshot.hasError) {
  //                           // If an error occurred
  //                           return Text('Error: ${snapshot.error}');
  //                         } else {
  //                           // If the future completed successfully
  //                           String storeCode = snapshot.data
  //                                   ?.getString('store_business_unit_code') ??
  //                               '';
  //                           selectedValues['store'] = storeCode;
  //                           return Text(
  //                             storeCode,
  //                             style: Theme.of(context).textTheme.displaySmall,
  //                           );
  //                         }
  //                       })
  //                 ],
  //               ),
  //               const SizedBox(height: 24),
  //               //SECTION
  //               FutureBuilder<List<dynamic>>(
  //                 future: dao.getSections('0').then(
  //                   (value) {
  //                     _loading = false;
  //                     _sectionList = value;
  //                     return value;
  //                   },
  //                 ),
  //                 builder: (context, snapshot) {
  //                   return LmDropdownButton(
  //                     selectedValues: selectedValues,
  //                     label: 'Seção',
  //                     itemsList:
  //                         _sectionList!.map((e) => e.toString()).toList(),
  //                     value: (selectedValues['section']?.compareTo("") == 0)
  //                         ? ((_sectionList ?? []).isEmpty
  //                             ? ''
  //                             : _sectionList!.first)
  //                         : selectedValues['section'],
  //                     valueSetter: (newSection) =>
  //                         selectedValues['section'] = newSection,
  //                     nextDropdownQuery:
  //                         'SELECT DISTINCT shelf FROM "tbl_physical_store_organizations" WHERE section = \'param\' order by shelf ',
  //                     nextDropdownQueryTable: 'shelf',
  //                     nextDropdownList: _shelfList,
  //                     nextDropdownListSetter: (nextDropdownList) =>
  //                         super.setState(() {
  //                       _shelfList = nextDropdownList;
  //                       dev.log('I207:');
  //                     }),
  //                     onTapEvent: () => cleanDropdownItemsList('section'),
  //                   );
  //                 },
  //               ),
  //               const SizedBox(height: 24),
  //               //SHELF
  //               LmDropdownButton(
  //                 selectedValues: selectedValues,
  //                 label: 'Prateleira',
  //                 itemsList: _shelfList!.map((e) => e.toString()).toList(),
  //                 value: (selectedValues['shelf']?.compareTo("") == 0)
  //                     ? (_shelfList ?? []).isEmpty
  //                         ? ''
  //                         : _shelfList!.first
  //                     : selectedValues['shelf'],
  //                 valueSetter: (newShelf) => selectedValues['shelf'] = newShelf,
  //                 nextDropdownQuery:
  //                     'SELECT DISTINCT level FROM "tbl_physical_store_organizations" WHERE section = \'${selectedValues['section']?.trimRight()}\' AND shelf = \'param\' order by level',
  //                 nextDropdownQueryTable: 'level',
  //                 nextDropdownList: _levelList,
  //                 nextDropdownListSetter: (newNextDropdownList) =>
  //                     setState(() => _levelList = newNextDropdownList),
  //                 onTapEvent: () => cleanDropdownItemsList('shelf'),
  //               ),
  //
  //               const SizedBox(height: 24),
  //               //LEVLE
  //               LmDropdownButton(
  //                 selectedValues: selectedValues,
  //                 label: 'Nível',
  //                 itemsList: _levelList!.map((e) => e.toString()).toList(),
  //                 value: (selectedValues['level']?.compareTo("") ==
  //                         0) //if the dropdown have never been selected, then the value should be the first of _levelList
  //                     ? (_levelList ?? [])
  //                             .isEmpty //if nothing was returned from api/query
  //                         ? '' //the value is ''
  //                         : _levelList!
  //                             .first //otherwise, select the first item of the list
  //                     : selectedValues[
  //                         'level'], //if the dropdown has a value, then show it
  //                 valueSetter: (newLevel) => selectedValues['level'] = newLevel,
  //                 nextDropdownQuery:
  //                     'SELECT DISTINCT slot FROM "tbl_physical_store_organizations" WHERE section = \'${selectedValues['section']?.trimRight()}\' AND shelf = \'${selectedValues['shelf']?.trimRight()}\' AND level = \'param\' ORDER BY slot',
  //                 nextDropdownQueryTable: 'slot',
  //                 nextDropdownList: _slotList,
  //                 nextDropdownListSetter: (newNextDropdownList) =>
  //                     setState(() => _slotList = newNextDropdownList),
  //                 onTapEvent: () => cleanDropdownItemsList('level'),
  //               ),
  //
  //               const SizedBox(height: 16),
  //               //SLOT
  //               LmDropdownButton(
  //                 selectedValues: selectedValues,
  //                 label: 'Slot',
  //                 itemsList: _slotList!.map((e) => e.toString()).toList(),
  //                 value: (selectedValues['slot']?.compareTo("") == 0)
  //                     ? (_slotList ?? []).isEmpty
  //                         ? ''
  //                         : _slotList!.first
  //                     : selectedValues['slot'],
  //                 valueSetter: (newSlot) => selectedValues['slot'] = newSlot,
  //                 nextDropdownQuery: '',
  //                 //'SELECT DISTINCT face FROM "tbl_physical_store_organizations" WHERE section = \'${_section.trimRight()}\' AND shelf = \'${_shelf.trimRight()}\' AND level = \'${_level.trimRight()}\' AND slot = \'param\' ORDER BY face',
  //                 nextDropdownQueryTable: 'face',
  //                 nextDropdownList: _faceList,
  //                 nextDropdownListSetter: (newNextDropdownList) =>
  //                     setState(() => _faceList = newNextDropdownList),
  //                 onTapEvent: () => cleanDropdownItemsList('slot'),
  //               ),
  //               const SizedBox(height: 16),
  //               //FACE
  //               LmDropdownButton(
  //                 selectedValues: selectedValues,
  //                 label: 'Face',
  //                 itemsList: _faceList!.map((e) => e.toString()).toList(),
  //                 value: (selectedValues['face']?.compareTo("") == 0)
  //                     ? (_faceList ?? []).isEmpty
  //                         ? ''
  //                         : _faceList!.first
  //                     : selectedValues['face'],
  //                 valueSetter: (newFace) => selectedValues['face'] = newFace,
  //                 nextDropdownListSetter: (dropdownList) => {},
  //               ),
  //               const SizedBox(height: 16),
  //             ]),
  //       ),
  //     );
  Widget _buildMacCard() => Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Row(
              children: [
                Text(
                  'Número MAC',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  '(código de barras)',
                  style: Theme.of(context).textTheme.displaySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Flexible(
                  child: TextFormField(
                    controller: scan,
                    decoration: const InputDecoration(
                      labelText: 'Escaneie o endereço MAC',
                      border: OutlineInputBorder(),
                    ),
                    /* validator: (String? arg) {
                      if (arg != null && arg.length != 12) {
                        return 'MAC deve ter 12 digitos';
                      } else {
                        return null;
                      }
                    }, */
                    onSaved: (newValue) => _mac = (newValue ?? ''),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  style: const ButtonStyle(
                    iconSize: MaterialStatePropertyAll(28),
                    fixedSize: MaterialStatePropertyAll(Size(50, 50)),
                  ),
                  onPressed: () async {
                    String? macAddressString =
                        await macAddressScanner.scannerReader(
                      context,
                      BarcodeReaderType.mac,
                    );
                    macAddressScanner = Scanner();
                    scan.value = TextEditingValue(text: macAddressString);
                  },
                  child: const Icon(Icons.camera_alt_outlined),
                ),
              ],
            ),
          ]),
        ),
      );

  void _installAction() async {
    //FORMS
    if (_formKey.currentState!.validate()) {
      _formKey.currentState?.save();

      //TODO: REFATORAÇÃO DE CÓDIGO
      String storeBusinessUnitCode =
          (await SessionManager().get('store_business_unit_code')).toString();

      // InstallationProcessManager()
      //     .install(
      //   macParameter: _mac,
      //   sglnParameter: GlobalLocationNumberExtension(
      //     businessUnitCode: storeBusinessUnitCode,
      //     section: selectedValues['section'] ?? '',
      //     shelf: selectedValues['shelf'] ?? '',
      //     level: selectedValues['level'] ?? '',
      //     slot: selectedValues['slot'] ?? '',
      //     face: selectedValues['face'] ?? '',
      //   ),
      // )
      //     .timeout(
      //   const Duration(milliseconds: ZEROMQ_TIMEOUT_VALUE),
      //   onTimeout: () {
      //     _dialogBuilder(context,
      //         titulo: 'Tempo esgotado!',
      //         mensagem:
      //             'A operação demorou, tente novamente mais tarde ou entre em contato com algum administrador');
      //     throw Exception(
      //         'Tempo esgotado durante a instalação de dispositivos! Tente novamente mais tarde');
      //   },
      // ).then(
      //   (value) {
      //     //TODO VERIFICAR POR CODIGO DE RETORNO DA REQUISIÇÃO
      //     dev.log('Operação de instalação retornou ${value.body}');
      //     if (value.body.contains('NACK')) {
      //       //problema nos dados enviados
      //       _dialogBuilder(
      //         context,
      //         titulo: 'Dados inválidos!',
      //         mensagem: 'Verifique os dados e tente novamente',
      //       );
      //     } else if (value.body.contains('timed')) {
      //       //problema com o zeromq, não foi possível iniciar o container
      //       _dialogBuilder(
      //         context,
      //         titulo: 'Problema no servidor!',
      //         mensagem:
      //             'Informe os administradores do sistema sobre o problema.',
      //       );
      //     } else {
      //       //retornou ack, tudo certo
      //       _dialogBuilder(
      //         context,
      //         titulo: 'Instalação pendente no sistema!',
      //         mensagem:
      //             'Verifique se a instalação foi bem sucedida na tela da etiqueta ou na tela de "Checar tentivas de instalação".',
      //       );
      //     }
      //     _formKey.currentState?.reset();
      //     _restart();
      //   },
      // ).onError((error, stackTrace) {
      //   _dialogErrorBuilder(
      //     context,
      //     titulo: 'Erro!',
      //     mensagem: 'Informe aos administradores sobre o problema: $error',
      //   );
      // });
    }
  }

  Widget _buildButtonRow() => SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () async {
            _installAction();
          },
          child: const Text(
            'Instalar',
          ),
        ),
      );
}

Future<void> _dialogBuilder(BuildContext context,
    {String titulo = '', String mensagem = ''}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Nova instalação'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(
                  context, '/installation/install/combobox');
              //Navigator.of(context).pop();
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Checar instalações'),
            onPressed: () async {
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              // ignore: use_build_context_synchronously
              Navigator.pop(context);
              // ignore: use_build_context_synchronously
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InstallationLogsView()));
            },
          ),
        ],
      );
    },
  );
}

Future<void> _dialogErrorBuilder(BuildContext context,
    {String titulo = '', String mensagem = ''}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(titulo),
        content: Text(mensagem),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Sair'),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      );
    },
  );
}
