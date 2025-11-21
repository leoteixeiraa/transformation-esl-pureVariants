import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'package:esl_mobile_app/utils/constants.dart';
import 'package:esl_mobile_app/views/Map/map_view.dart';
import 'package:flutter/material.dart';

import '../../components/lm_esl_widget_item.dart';
import '../../models/ESL.dart';
import '../../dao/esl_dao.dart';
import '../../services/barcode_scanner/scanner.dart';

class EslSearchView extends StatefulWidget {
  const EslSearchView({super.key});
  @override
  State<EslSearchView> createState() => _EslSearchViewState();
}

class _EslSearchViewState extends State<EslSearchView> {
  TextEditingController macStringController = TextEditingController();
  var macAddressScanner = Scanner();

  var _fetchedEsl = Completer<List<ESL>>();
  @override
  void initState() {
    Future<String> macAddressString = macAddressScanner.ScannerReader();
    macAddressString.then((value) {
      macStringController.value = TextEditingValue(text: value);
      debugPrint('29: ESV');
      fetchFromAPI(value);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultar ESL')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildPageTitle('Consultar ESL'),
            Text(
              'Escaneie o código de barra de uma ESL para verificar seus dados',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.justify,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _buildSearchBar(),
                const SizedBox(width: 16),
                _buildCameraReaderButton(),
              ],
            ),
            const SizedBox(height: 8),
            Flexible(
              fit: FlexFit.loose,
              flex: 10,
              child: _buildEslDescriptionCard(),
            ),
          ],
        ),
      ),
    );
  }

  FutureBuilder<List<ESL>> _buildEslDescriptionCard() {
    return FutureBuilder<List<ESL>>(
      future: _fetchedEsl.future, // The future to wait for
      builder: (BuildContext context, AsyncSnapshot<List<ESL>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is loading
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          // If an error occurred
          return Text('Erro: ${snapshot.error}');
        } else {
          // If the future completed successfully
          if (snapshot.data!.isEmpty) {
            return const Text('Nenhuma ESL encontrada!');
          }
          return ListView(
            children: snapshot.data!.map((e) {
              return LmEslWidgetItem(esl: e);
            }).toList(),
          );
        }
      },
    );
  }

  void fetchFromApiByMac(String mac) {
    // List<ESL> esl;
    // EslDao().getEslByMac(mac).then((value) {
    //   debugPrint(value);
    //   esl = (jsonDecode(value) as List)
    //       .map((e) => ESL.fromJsonFetchedFromAPI(e))
    //       .toList();
    //   debugPrint(value);
    //   _fetchedEsl.complete(esl);
    // }).onError((error, stackTrace) {
    //   debugPrint(error.toString());
    //   _fetchedEsl.completeError(
    //       'Não foi possível encontrar a ESL. Entre em contato com os adminstradores do sistema\n\nDetalhes: ${error.toString()}');
    // }).timeout(const Duration(milliseconds: ZEROMQ_TIMEOUT_VALUE),
    //     onTimeout: () {
    //   debugPrint('fetchFromApiByMac timeout');
    //   _fetchedEsl.completeError(
    //       'Tempo de busca esgotado! Entre em contato com os adminstradores do sistema.');
    // });
  }

  Future<List<ESL>> fetchFromAPI(String mac) async {
    final eslListCompleter = Completer<List<ESL>>();

    // var jsonEslList = await EslDao().getAll();
    //
    List<ESL> eslList=[];
    // if (!jsonEslList.contains('lido ou expirado')) {
    //   eslList = (jsonDecode(jsonEslList) as List)
    //       .map((e) => ESL.fromJsonFetchedFromAPI(e))
    //       .toList();
    //   eslList.removeWhere(
    //     (e) {
    //       if (e.mac.getMac().toLowerCase().compareTo(mac.toLowerCase()) != 0) {
    //         return true;
    //       }
    //       return false;
    //     },
    //   );
    //   debugPrint(jsonEslList);
    // } else {
    //   eslList = [];
    // }
    _fetchedEsl.complete(eslList);

    return eslListCompleter.future;
  }

  Text _buildPageTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge,
    );
  }

  Widget _buildSearchBar() {
    return Flexible(
      child: TextFormField(
        controller: macStringController,
        onChanged: (value) {
          _reloadPage(value);
        },
        decoration: const InputDecoration(
          labelText: 'Consultar por MAC',
          border: OutlineInputBorder(),
          prefixIcon: Icon(Icons.search),
        ),
      ),
    );
  }

  ElevatedButton _buildCameraReaderButton() {
    return ElevatedButton(
      style: const ButtonStyle(
        iconSize: MaterialStatePropertyAll(28),
        fixedSize: MaterialStatePropertyAll(Size(50, 50)),
      ),
      onPressed: () async {
        _fetchedEsl = Completer<List<ESL>>();
        String macAddressString = await macAddressScanner.ScannerReader();
        debugPrint('$macAddressString\n\n\n\n\n\n\n\n\n\n\n\n');
        macStringController.value = TextEditingValue(text: macAddressString);
        _reloadPage(macAddressString);
      },
      child: const Icon(Icons.camera_alt_outlined),
    );
  }

  void _reloadPage(String macInputValue) {
    //setState
    setState(() {
      fetchFromAPI(macInputValue);
    });
  }
}
