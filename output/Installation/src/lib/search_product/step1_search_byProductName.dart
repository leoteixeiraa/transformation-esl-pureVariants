import 'dart:async';
import 'dart:collection';
import 'package:esl_mobile_app/components/CmpBlinkingListTile.dart';
import 'package:esl_mobile_app/components/CmpEslListTile.dart';
import 'package:esl_mobile_app/models/global_asset_identifier.dart';
import 'package:esl_mobile_app/models/global_location_number_extension.dart';
import 'package:esl_mobile_app/models/mac.dart';
import 'package:esl_mobile_app/services/validation/ignore_diacritics_service.dart';
import 'package:flutter/material.dart';
import 'package:remove_diacritic/remove_diacritic.dart';
import '../../../components/lm_esl_widget_item.dart';
import '../../../components/my_solid_button.dart';
import '../../../dao/esl_dao.dart';
import '../../../models/ESL.dart';

class Step1SearchByProductName extends StatefulWidget {
  Step1SearchByProductName({
    super.key,
    required this.listingEslsFlag,
  });

  bool listingEslsFlag;

  late Future<List<ESL>> ftrEslList;

  var cmpEslListFiltered = Completer<List<ESL>>();
  List<ESL> eslListFiltered = [];
  List<String> eslGLNList = [];
  List<String> sectionList = [];
  List<String> sectionListDescribed = [];

  bool showExpasionPanelFlag = false;

  List<ESL> valueAux = [];

  String productNameInputValue = '';

  List<String> productsNames = [];

  var cmpProductsNameList = Completer<List<String>>();

  bool productNameListLoadedFromAPI = false;

  late TabController tabController;

  var EslListDataWereLoadedFlag = Completer<bool>();

  @override
  State<StatefulWidget> createState() => _Step1SearchByProductNameState();
}

class _Step1SearchByProductNameState extends State<Step1SearchByProductName>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // widget.ftrEslList = EslDao().getAllWithDetails().then(
    //       (valu) {
    //     List<ESL> value = [];
    //     value.add(ESL(
    //       clientId: 1,
    //       storeCode: '1',
    //       mac: MAC(mac: ''),
    //       commissionStatus: '',
    //       giai: GlobalIndividualAssetIdentifier(macValue: MAC(mac: '')),
    //       gtin: '',
    //       installStatus: '',
    //       isAlive: true,
    //       updateStatus: '',
    //       renderBase64: '',
    //       productName: '',
    //       sgln: GlobalLocationNumberExtension(
    //         section: 'CR',
    //         module: '1',
    //         runner: '1',
    //         storeCode: '1',
    //         clientId: 1,
    //       ),
    //     ));
    //     value.add(ESL(
    //       clientId: 1,
    //       storeCode: '1',
    //       mac: MAC(mac: ''),
    //       commissionStatus: '',
    //       giai: GlobalIndividualAssetIdentifier(macValue: MAC(mac: '')),
    //       gtin: '',
    //       installStatus: '',
    //       isAlive: true,
    //       updateStatus: '',
    //       renderBase64: '',
    //       productName: '',
    //       sgln: GlobalLocationNumberExtension(
    //         section: 'EL',
    //         module: '1',
    //         runner: '1',
    //         storeCode: '1',
    //         clientId: 1,
    //       ),
    //     ));
    //     value.add(ESL(
    //       clientId: 1,
    //       storeCode: '1',
    //       mac: MAC(mac: ''),
    //       commissionStatus: '',
    //       giai: GlobalIndividualAssetIdentifier(macValue: MAC(mac: '')),
    //       gtin: '',
    //       installStatus: '',
    //       isAlive: true,
    //       updateStatus: '',
    //       renderBase64: '',
    //       productName: '',
    //       sgln: GlobalLocationNumberExtension(
    //         section: 'JD',
    //         module: '1',
    //         runner: '1',
    //         storeCode: '1',
    //         clientId: 1,
    //       ),
    //     ));
    //
    //     for(var esl in value){
    //       if(!widget.sectionList.contains(esl.sgln?.section) ){
    //         widget.sectionList.add(esl.sgln?.section ?? "");
    //       }
    //
    //     }
    //
    //
    //     //if not loaded yet
    //     //load productsName list for the SEARCH_BAR
    //     loadWidgetProductNames(value);
    //
    //     loadGlnAndListFilteredWidgetLists(value);
    //     // widget.eslListFiltered.add(
    //     //   ESL(
    //     //     clientId: 1,
    //     //     storeCode: '1',
    //     //     mac: MAC(mac: ''),
    //     //     commissionStatus: '',
    //     //     giai: GlobalIndividualAssetIdentifier(macValue: MAC(mac: '')),
    //     //     gtin: '',
    //     //     installStatus: '',
    //     //     isAlive: true,
    //     //     updateStatus: '',
    //     //     renderBase64: '',
    //     //     productName: '',
    //     //     sgln: GlobalLocationNumberExtension(
    //     //       section: 'CR',
    //     //       module: '1',
    //     //       runner: '1',
    //     //       storeCode: '1',
    //     //       clientId: 1,
    //     //     ),
    //     //   ),
    //     // );
    //     widget.cmpEslListFiltered.complete(widget.eslListFiltered);
    //
    //     widget.productNameListLoadedFromAPI = true;
    //     widget.cmpProductsNameList.complete(widget.productsNames);
    //
    //     return valu;
    //   },
    // );

    List<ESL> value = [];
    value = loadEslList();
    widget.valueAux = value;
    loadSectionList(value);

    //if not loaded yet
    //load productsName list for the SEARCH_BAR
    loadWidgetProductNames(value);

    loadGlnAndListFilteredWidgetLists(value);

    widget.cmpEslListFiltered.complete(widget.eslListFiltered);

    widget.productNameListLoadedFromAPI = true;
    widget.cmpProductsNameList.complete(widget.productsNames);

    super.initState();
    widget.tabController =
        TabController(length: widget.sectionListDescribed.length, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _buildFBSearchBar(),
        // title: const Text("Busca por produto"),
        // actions: [
        //   IconButton(
        //       onPressed: () {
        //         //controller.openView();
        //         showSearch(
        //                 context: context,
        //                 delegate: CustomSearchDelegate(
        //                     searchTerms: widget.productsNames))
        //             .then((value) {
        //           super.setState(() {
        //             widget.showExpasionPanelFlag = true;
        //             debugPrint('SBPN(305 ): $value');
        //             widget.productNameInputValue = value ?? '';
        //             //loadSectionList(widget.valueAux);
        //             // widget controller.text = value ?? '';
        //
        //             //widget.tabController = TabController(length: widget.sectionListDescribed.length, vsync: this);
        //             //controller.value= TextEditingValue(text: value ?? '');
        //           });
        //         });
        //       },
        //       icon: const Icon(Icons.search)),
        // ],
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            // Text("Digite o nome do produto", style: TextStyle(fontSize: 18),),
            // SizedBox(height: 16),
            widget.showExpasionPanelFlag
                ? SGLNExpansionPanelList(
                    key: UniqueKey(),
                    eslList: widget.valueAux,
                    productName: widget.productNameInputValue,
                    listingEslsFlag: widget.listingEslsFlag,
                  )
                : SizedBox(),
            SizedBox(height: 16),
            // TabBar(
            //     dividerColor: MyColorStyles.primary,
            //     labelColor: Colors.black,
            //     controller: widget.tabController,
            //     tabs: widget.sectionListDescribed
            //         .map((e) => Tab(
            //               text: e,
            //             ))
            //         .toList()),
            //
            // const SizedBox( height: 16),
            // Expanded(
            //   child: TabBarView(
            //       controller: widget.tabController,
            //       children: widget.sectionListDescribed
            //           .map((e) => _buildFBGlnList(e))
            //           .toList()),
            // ),
          ],
        ),
      ),
    );
  }

  List<ESL> loadEslList() {
    List<ESL> value = [];
    value.add(ESL(
      clientId: 1,
      storeCode: '1',
      mac: MAC(mac: 'fffffffff1e0'),
      commissionStatus: '',
      giai: GlobalIndividualAssetIdentifier(macValue: MAC(mac: '')),
      gtin: '',
      installStatus: '',
      isAlive: true,
      sglnSplitMethod: GlobalLocationNumberExtension.fromStringSplitMethod(
          'storeCode0011 clientId1 secCR cor1 mod1'),
      updateStatus: '',
      renderBase64: '',
      productName: 'Piso Cerâmico Cimentício Acetinado',
      sgln: GlobalLocationNumberExtension(
        section: 'CR',
        module: '1',
        runner: '1',
        storeCode: '0011',
        clientId: 1,
      ),
    ));
    value.add(ESL(
      clientId: 1,
      storeCode: '1',
      mac: MAC(mac: 'fffffffff1e1'),
      commissionStatus: '',
      giai: GlobalIndividualAssetIdentifier(macValue: MAC(mac: '')),
      gtin: '',
      installStatus: '',
      isAlive: true,
      sglnSplitMethod: GlobalLocationNumberExtension.fromStringSplitMethod(
          'storeCode0011 clientId1 secEL cor4 mod4'),
      updateStatus: '',
      renderBase64: '',
      productName: 'Piso Cerâmico Cimentício Acetinado',
      sgln: GlobalLocationNumberExtension(
        section: 'EL',
        module: '4',
        runner: '4',
        storeCode: '0011',
        clientId: 1,
      ),
    ));
    value.add(ESL(
      clientId: 1,
      storeCode: '1',
      mac: MAC(mac: 'fffffffff1e2'),
      commissionStatus: '',
      giai: GlobalIndividualAssetIdentifier(macValue: MAC(mac: '')),
      gtin: '',
      installStatus: '',
      isAlive: true,
      updateStatus: '',
      renderBase64: '',
      productName: 'Lâmpada Led Dicroica Mr16 Tdl 6w Taschibra',
      sglnSplitMethod: GlobalLocationNumberExtension.fromStringSplitMethod(
          'storeCode0011 clientId1 secEL cor2 mod2'),
      sgln: GlobalLocationNumberExtension(
        section: 'EL',
        module: '2',
        runner: '2',
        storeCode: '1',
        clientId: 1,
      ),
    ));
    value.add(ESL(
      clientId: 1,
      storeCode: '1',
      mac: MAC(mac: 'fffffffff1e3'),
      commissionStatus: '',
      giai: GlobalIndividualAssetIdentifier(macValue: MAC(mac: '')),
      gtin: '',
      installStatus: '',
      isAlive: true,
      updateStatus: '',
      renderBase64: '',
      productName: 'Gazebo Aço e Poliéster com Cortina ',
      sglnSplitMethod: GlobalLocationNumberExtension.fromStringSplitMethod(
          'storeCode0011 clientId1 secJD cor3 mod3'),
      sgln: GlobalLocationNumberExtension(
        section: 'JD',
        module: '3',
        runner: '3',
        storeCode: '1',
        clientId: 1,
      ),
    ));
    return value;
  }

  void loadSectionList(List<ESL> value) {
    widget.sectionList = [];
    widget.sectionListDescribed = [];
    for (var esl in value) {
      if (!widget.sectionList.contains(esl.sgln?.section)) {
        // && esl.productName != '' && esl.productName != null && esl.productName == widget.productNameInputValue
        widget.sectionList.add(esl.sgln?.section ?? "");
      }
    }
    for (var e in widget.sectionList) {
      switch (e) {
        case 'CR':
          widget.sectionListDescribed.add('Cerâmica');
          break;
        case 'EL':
          widget.sectionListDescribed.add('Elétrica');
          break;
        case 'JD':
          widget.sectionListDescribed.add('Jardinagem');
          break;
        case 'IL':
          widget.sectionListDescribed.add('Iluminação');
          break;
      }
    }
  }

  void loadGlnAndListFilteredWidgetLists(List<ESL> value) {
    for (var e in value) {
      if (!widget.eslGLNList.contains(e.sgln?.getGLN())) {
        widget.eslGLNList.add(e.sgln!.getGLN());
        widget.eslListFiltered.add(e);
      }
    }
  }

  void loadWidgetProductNames(List<ESL> value) {
    for (var esl in value) {
      //if theres some data about the product
      if (esl.productName != null && esl.productName != '') {
        if (!widget.productsNames.contains(esl.productName)) {
          widget.productsNames.add(esl.productName ?? '');
        }
      }
    }
  }

  FutureBuilder<List<ESL>> _buildFBGlnList(String selectedSectionName) {
    return FutureBuilder<List<ESL>>(
      future: widget.cmpEslListFiltered.future,
      // The future to wait for
      builder: (BuildContext context, AsyncSnapshot<List<ESL>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is loading
          return const Text('Buscando localizações dos produtos...');
        } else if (snapshot.hasError) {
          // If an error occurred
          return Text('Error: ${snapshot.error}');
        } else {
          // If the future completed successfully
          if (snapshot == null ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Text('Nenhum produto comissionado!');
          }
          return Flexible(
            child: ListView(
              children: snapshot.data!
                  .where((e) =>
                      ((e.productName ?? '').toLowerCase().contains(
                              widget.productNameInputValue.toLowerCase()) ||
                          widget.productNameInputValue == '') &&
                      e.sglnSplitMethod?.section ==
                          sectionNametoCode(selectedSectionName))
                  .map(
                (e) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: 8),
                    child: Card(
                      child: CmpBlinkingListTile(e: e),
                    ),
                  );
                },
              ).toList(),
            ),
          );
        }
      },
    );
  }

  FutureBuilder<List<String>> _buildFBSearchBar() {
    return FutureBuilder<List<String>>(
      future: widget.cmpProductsNameList.future,
      // The future to wait for
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is loading
          return const Text('Buscando lista de produtos...');
        } else if (snapshot.hasError) {
          // If an error occurred
          return Text('Error: ${snapshot.error}');
        } else {
          // If the future completed successfully
          if (snapshot == null ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Text('Não foi encontrado nenhum produto!');
          }
          return _buildSearchBar(snapshot.data ?? []);
        }
      },
    );
  }

  // Padding buildSearchButton(BuildContext context) {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 24),
  //     child: SizedBox(
  //       height: 50,
  //       width: double.infinity,
  //       child: MySolidButton(
  //         buttonLabel: const Text('Pesquisar'),
  //         onPressedCallBack: () => {
  //           showSearch(
  //                   context: context,
  //                   delegate:
  //                       CustomSearchDelegate(searchTerms: widget.productsNames))
  //               .then(
  //             (value) {
  //               super.setState(
  //                 () {
  //                   widget.productNameInputValue = value ?? '';
  //                 },
  //               );
  //             },
  //           ),
  //         },
  //       ),
  //     ),
  //   );
  // }

  Widget _buildSearchBar(List<String> productsNames) {
    bool isDark = false;
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);
    return SearchAnchor(
      builder: (BuildContext context, SearchController controller) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SearchBar(
            controller: controller,
            hintText: 'Digite o nome do produto',
            onTap: () {
              //controller.openView();
              showSearch(
                      context: context,
                      delegate: CustomSearchDelegate(
                          searchTerms: widget.productsNames))
                  .then((value) {
                setState(() {
                  widget.showExpasionPanelFlag = true;
                  debugPrint('SBPN(305 ): $value');
                  debugPrint('TESTEEEEEEEEEEEEEEEEEEEEEEEEEE $value');
                  widget.productNameInputValue = value ?? '';
                  //loadSectionList(widget.valueAux);
                  controller.text = value ?? '';

                  //widget.tabController = TabController(length: widget.sectionListDescribed.length, vsync: this);
                  //controller.value= TextEditingValue(text: value ?? '');
                });
              });
            },
            onChanged: (_) {
              controller.openView();
              widget.productNameInputValue = _;
            },
            leading: const Icon(Icons.search),
          ),
        );
      },
      suggestionsBuilder: (BuildContext context, SearchController controller) {
        List<ListTile> lista = [];
        for (var e in productsNames.where((e) => inFilteredList(e))) {
          lista.add(ListTile(
            title: Text('$e'),
            onTap: () {
              setState(() {
                widget.productNameInputValue = e;
                controller.closeView(e);
              });
            },
          ));
        }
        return lista;
      },
    );
  }

  bool inFilteredList(String searchString) {
    if (searchString.isEmpty) {
      return true;
    }
    if (searchString.contains(widget.productNameInputValue)) {
      return true;
    }
    return false;
  }
}

List<Item> generateItems(
    List<ESL> eslList, String productName, bool listingEslsFlag) {
  List<Item> expansionPanelListAsItem = [];

  HashMap<String, List<ESL>> sectionsHashMap = HashMap<String, List<ESL>>();
  for (ESL esl in eslList) {
    if (esl.productName == productName && esl.sgln != null) {
      bool a = esl.productName == productName && esl.sgln != null;
      if (sectionsHashMap[esl.sgln!.section] == null) {
        sectionsHashMap.addAll({
          esl.sgln!.section: [esl]
        });
      } else {
        sectionsHashMap[esl.sgln!.section]?.add(esl);
      }
    }
  }
  for (String section in sectionsHashMap.keys) {
    expansionPanelListAsItem.add(Item(
      headerValue: sectionCodeToName(section),
      expandedWidget: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: !listingEslsFlag
            ? Card(
                child: Column(
                  children: sectionsHashMap[section]!
                      .map(
                        (e) => CmpBlinkingListTile(e: e),
                      )
                      .toList(),
                ),
              )
            : Card(
                child: Column(
                  children: sectionsHashMap[section]!
                      .map(
                        (e) => LmEslWidgetItem(esl: e),
                      )
                      .toList(),
                ),
              ),
      ),
    ));
  }
  return expansionPanelListAsItem;

  // return List<Item>.generate(sectionsHashMapAsList.length, (int index) {
  //       return Item(
  //     headerValue: sectionsHashMapAsList[index],
  //     expandedWidget: Padding(
  //       padding: const EdgeInsets.only(bottom: 8),
  //       child: Card(
  //         child: CmpBlinkingListTile(e: value[index]),
  //       ),
  //     ),
  //   );
  // });
}

class Item {
  Item({
    required this.expandedWidget,
    required this.headerValue,
    this.isExpanded = false,
  });

  Widget expandedWidget;
  String headerValue;
  bool isExpanded;
}

class SGLNExpansionPanelList extends StatefulWidget {
  SGLNExpansionPanelList({
    super.key,
    required this.eslList,
    required this.productName,
    required this.listingEslsFlag,
  });

  List<ESL> eslList;
  String productName;

  //selects the type of card being printed
  bool listingEslsFlag = false;

  @override
  State<SGLNExpansionPanelList> createState() => _SGLNExpansionPanelListState();
}

class _SGLNExpansionPanelListState extends State<SGLNExpansionPanelList> {
  List<Item> data = [];

  @override
  void initState() {
    data = generateItems(
        widget.eslList, widget.productName, widget.listingEslsFlag);
    debugPrint(
        'TEEEEEEEEEEESTEEEEEEEEEEE INIT STATEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        child: _buidPanel(data),
      ),
    );
  }

  Widget _buidPanel(List<Item> data) {
    return ExpansionPanelList(
      expansionCallback: (int index, bool isExpanded) {
        setState(() {
          data[index].isExpanded = isExpanded;
        });
      },
      children: data.map<ExpansionPanel>((Item item) {
        return ExpansionPanel(
          headerBuilder: (BuildContext context, bool isExpanded) {
            return ListTile(
              title: Text(item.headerValue),
            );
          },
          body: ListTile(
            title: item.expandedWidget,
          ),
          isExpanded: item.isExpanded,
        );
      }).toList(),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate<String?> {
  List<String> searchTerms;

  CustomSearchDelegate({required this.searchTerms})
      : super(searchFieldLabel: 'Digite o nome do produto');

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
          onPressed: () {
            query = '';
          },
          icon: const Icon(Icons.clear))
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        onPressed: () {
          close(context, null);
        },
        icon: const Icon(Icons.arrow_back));
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> matchQuery = [];
    for (var productName in searchTerms) {
      if (removeDiacritics(productName)
          .toLowerCase()
          .contains(query.toLowerCase())) {
        matchQuery.add(productName);
      }
    }
    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            close(context, result);
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    IgnoreDiacritcsService service = IgnoreDiacritcsService();
    List<String> matchQuery = [];
    for (var productName in searchTerms) {
      if (service
          .removeDiacritics(productName)
          .toLowerCase()
          .contains(service.removeDiacritics(query.toLowerCase()))) {
        matchQuery.add(productName);
      }
    }

    return ListView.builder(
      itemCount: matchQuery.length,
      itemBuilder: (context, index) {
        var result = matchQuery[index];
        return ListTile(
          title: Text(result),
          onTap: () {
            close(context, result);
          },
        );
      },
    );
  }
}

String sectionNametoCode(String name) {
  switch (name) {
    case 'Cerâmica':
      return 'CR';
    case 'Elétrica':
      return 'EL';
    case 'Jardinagem':
      return 'JD';
    case 'Iluminação':
      return 'JD';
  }
  return '';
}

String sectionCodeToName(String name) {
  switch (name) {
    case 'CR':
      return 'Cerâmica';
    case 'EL':
      return 'Elétrica';
    case 'JD':
      return 'Jardinagem';
    case 'IL':
      return 'Iluminação';
  }
  return '';
}
