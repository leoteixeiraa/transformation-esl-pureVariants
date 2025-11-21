import 'dart:async';
// import 'dart:ffi'; // Not available on web platform

import 'package:esl_mobile_app/components/MyTextButton.dart';
import 'package:esl_mobile_app/components/my_solid_button.dart';
import 'package:esl_mobile_app/dao/esl_dao.dart';
import 'package:esl_mobile_app/dao/gln_dao.dart';
import 'package:esl_mobile_app/models/actionArguments/installation_arguments.dart';
import 'package:esl_mobile_app/styles/app_themes.dart';
import 'package:flutter/material.dart';

import '../../../components/lm_dropdown_button.dart';
import '../../../components/lm_esl_widget_item.dart';
import '../../../models/ESL.dart';

class Step1SearchAll extends StatefulWidget {
  Step1SearchAll({super.key});

  late Future<List<ESL>> ftrEslList;
  late Future<Map<String, String>> ftrSectionList;

  bool filterApplied = false;
  bool filterVisibility = true;

  var cmpEslList = Completer<List<ESL>>();

  var cmpSectionList = Completer<List<String>>();
  var cmpRunnerList = Completer<List<String>>();
  var cmpModuleList = Completer<List<String>>();

  var cmpMacList = Completer<List<String>>();
  var cmpProductList = Completer<List<String>>();

  String selectedSection = 'Qualquer';
  String? selectedRunner = 'Qualquer';
  String? selectedModule = 'Qualquer';

  String? selectedMac = 'Qualquer';
  String? selectedProduct = 'Qualquer';

  bool flag = false;

  @override
  State<Step1SearchAll> createState() => _Step1SearchAllState();
}

class _Step1SearchAllState extends State<Step1SearchAll> {
  Set<String> selectedSection = <String>{};

  @override
  void initState() {
    widget.ftrEslList = EslDao().getAllWithDetails().then((value) {
      List<String> sectionListThen = [];
      List<String> runnerListThen = [];
      List<String> moduleListThen = [];

      List<String> macListThen = [];
      List<String> productListThen = [];

      for (ESL esl in value) {
        String? auxSection = esl.sgln?.section.trimRight();
        String? auxRunner = esl.sgln?.runner.trimRight();
        String? auxModule = esl.sgln?.module.trimRight();

        String? auxMac = esl.mac.toString().toUpperCase();
        String? auxProduct = esl.productName;

        //phsical locaation informations
        if (auxSection != null &&
            !sectionListThen.contains(auxSection) &&
            auxSection != '') {
          sectionListThen.add(auxSection);
        }
        if (auxRunner != null &&
            !runnerListThen.contains(auxRunner) &&
            auxRunner != '') {
          runnerListThen.add(auxRunner);
        }
        if (auxModule != null &&
            !moduleListThen.contains(auxModule) &&
            auxModule != '') {
          moduleListThen.add(auxModule);
        }
        //esl informations
        if (auxProduct != null &&
            !productListThen.contains(auxProduct) &&
            auxProduct != '') {
          productListThen.add(auxProduct);
        }
        if (auxMac != null && !macListThen.contains(auxMac) && auxMac != '') {
          macListThen.add(auxMac);
        }
      }
      //physiocal location data
      sectionListThen.sort();
      sectionListThen.insert(0, 'Qualquer');
      widget.cmpSectionList.complete(sectionListThen);
      //widget.selectedSections.addAll(sectionListThen);

      runnerListThen.sort();
      runnerListThen.insert(0, 'Qualquer');
      widget.cmpRunnerList.complete(runnerListThen);
      //widget.selectedRunners.addAll(runnerListThen);

      moduleListThen.sort();
      moduleListThen.insert(0, 'Qualquer');
      widget.cmpModuleList.complete(moduleListThen);
      //widget.selectedModules.addAll(moduleListThen);

      //esl device data
      macListThen.sort();
      macListThen.insert(0, 'Qualquer');
      widget.cmpMacList.complete(macListThen);

      productListThen.sort();
      productListThen.insert(0, 'Qualquer');
      widget.cmpProductList.complete(productListThen);

      widget.cmpEslList.complete(value);
      return value;
    });
    widget.ftrSectionList = GlnDao().getSections();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Color textColor = MyColorStyles.grey300;

    return Scaffold(
      appBar: AppBar(title: const Text('Consulta de etiqueta')),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Visibility(
              maintainSize: false,
              maintainState: true,
              maintainAnimation: true,
              visible: widget.filterVisibility,
              child: Column(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text('Filtros',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text("Seção", style: TextStyle(fontWeight: FontWeight.bold),),
                  buildSectionFilter(),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text("Corredor", style: TextStyle(fontWeight: FontWeight.bold),),
                  buildRunnerFilter(),
                  const SizedBox(
                    height: 8,
                  ),
                  const Text("Modulo", style: TextStyle(fontWeight: FontWeight.bold),),
                  buildModuleFilter(),
                  const SizedBox(
                    height: 8,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      MyTextButton(
                          onPressed: () {
                            setState(() {
                              widget.selectedSection = 'Qualquer';
                              widget.selectedRunner = 'Qualquer';
                              widget.selectedModule = 'Qualquer';

                              widget.selectedMac = 'Qualquer';
                              widget.selectedProduct = 'Qualquer';

                              widget.filterApplied = false;
                              widget.filterVisibility = false;
                            });
                          },
                          label: 'Limpar'),
                      MyTextButton(
                          onPressed: () {
                            setState(() {
                              widget.filterApplied = true;
                              widget.filterVisibility = false;
                            });
                          },
                          label: 'Aplicar filtros')
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            _buildEslList(),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endContained,
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 16, 50),
        child: MySolidButton(
          buttonLabel: Icon(Icons.filter_alt_sharp, color: MyColorStyles.white),
          onPressedCallBack: () {
            setState(() {
              widget.filterVisibility = !widget.filterVisibility;
            });
          },
        ),
      ),
    );
  }

  FutureBuilder<List<String>> buildSectionFilter() {
    return FutureBuilder<List<String>>(
      future: widget.cmpSectionList.future, // The future to wait for
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is loading
          return const Text('Buscando informações...');
        } else if (snapshot.hasError) {
          // If an error occurred
          return Text('Error: ${snapshot.error}');
        } else {
          // If the future completed successfully
          if (snapshot == null ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Text('Nenhuma seção encontrada!');
          }
          return LmDropdownButton(
            itemValuesList: snapshot.data!,
            itemKeysList: const [],
            value: widget.selectedSection,
            label: 'Seção',
            valueSetter: (value) {
              widget.selectedSection = value;
              debugPrint(value);
            },
          );
        }
      },
    );
  }

  FutureBuilder<List<String>> buildRunnerFilter() {
    return FutureBuilder<List<String>>(
      future: widget.cmpRunnerList.future, // The future to wait for
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is loading
          return const Text('Buscando informações...');
        } else if (snapshot.hasError) {
          // If an error occurred
          return Text('Error: ${snapshot.error}');
        } else {
          // If the future completed successfully
          if (snapshot == null ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Text('Nenhum corredor encontrado!');
          }
          const a = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
          return LmDropdownButton(
            itemValuesList: snapshot.data!,
            itemKeysList: const [],
            value: widget.selectedRunner,
            label: 'Corredor',
            valueSetter: (value) {
              widget.selectedRunner = value;
              debugPrint(value);
            },
          );
        }
      },
    );
  }

  FutureBuilder<List<String>> buildModuleFilter() {
    return FutureBuilder<List<String>>(
      future: widget.cmpModuleList.future, // The future to wait for
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is loading
          return const Text('Buscando informações...');
        } else if (snapshot.hasError) {
          // If an error occurred
          return Text('Error: ${snapshot.error}');
        } else {
          // If the future completed successfully
          if (snapshot == null ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Text('Nenhum modulo encontrado!');
          }
          return LmDropdownButton(
            itemValuesList: snapshot.data!,
            itemKeysList: const [],
            value: widget.selectedRunner,
            label: 'Módulo',
            valueSetter: (value) {
              widget.selectedRunner = value;
              debugPrint(value);
            },
          );
        }
      },
    );
  }

  FutureBuilder<List<String>> buildMacFilter() {
    return FutureBuilder<List<String>>(
      future: widget.cmpMacList.future, // The future to wait for
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is loading
          return const Text('Buscando informações...');
        } else if (snapshot.hasError) {
          // If an error occurred
          return Text('Error: ${snapshot.error}');
        } else {
          // If the future completed successfully
          if (snapshot == null ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Text('Nenhum mac encontrado!');
          }
          return LmDropdownButton(
            itemValuesList: snapshot.data!,
            itemKeysList: const [],
            value: widget.selectedMac,
            label: 'Endereço MAC',
            valueSetter: (value) {
              widget.selectedMac = value;
              debugPrint(value);
            },
          );
        }
      },
    );
  }

  FutureBuilder<List<String>> buildProductFilter() {
    return FutureBuilder<List<String>>(
      future: widget.cmpProductList.future, // The future to wait for
      builder: (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While the future is loading
          return const Text('Buscando informações...');
        } else if (snapshot.hasError) {
          // If an error occurred
          return Text('Error: ${snapshot.error}');
        } else {
          // If the future completed successfully
          if (snapshot == null ||
              snapshot.data == null ||
              snapshot.data!.isEmpty) {
            return const Text('Nenhum produto encontrado!');
          }
          return LmDropdownButton(
            itemValuesList: snapshot.data!,
            itemKeysList: const [],
            value: widget.selectedProduct,
            label: 'Produto',
            valueSetter: (value) {
              widget.selectedProduct = value;
              debugPrint(value);
            },
          );
        }
      },
    );
  }

  Flexible _buildEslList() {
    return Flexible(
      fit: FlexFit.loose,
      flex: 10,
      child: FutureBuilder<List<ESL>>(
        future: widget.cmpEslList.future, // The future to wait for
        builder: (BuildContext context, AsyncSnapshot<List<ESL>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While the future is loading
            return const Text('Buscando informações...');
          } else if (snapshot.hasError) {
            // If an error occurred
            return Text('Error: ${snapshot.error}');
          } else {
            // If the future completed successfully
            if (snapshot == null ||
                snapshot.data == null ||
                snapshot.data!.isEmpty) {
              return const Text('Nenhuma ESL encontrada!');
            }
            return ListView(
              children: snapshot.data!.map((e) {
                var eslSection = e.sgln?.section.trimRight();
                var eslRunner = e.sgln?.runner.trimRight();
                var eslModule = e.sgln?.module.trimRight();
                var eslMac = e.mac.toString().toUpperCase();
                var eslProduct = e.productName;
                //if filter applied select the items
                if (widget.filterApplied) {
                  if ((widget.selectedSection == eslSection ||
                          widget.selectedSection?.compareTo('Qualquer') == 0) &&
                      (widget.selectedRunner == eslRunner ||
                          widget.selectedRunner?.compareTo('Qualquer') == 0) &&
                      (widget.selectedModule == eslModule ||
                          widget.selectedModule?.compareTo('Qualquer') == 0) &&
                      (widget.selectedMac == eslMac ||
                          widget.selectedMac?.compareTo('Qualquer') == 0) &&
                      (widget.selectedProduct == eslProduct ||
                          widget.selectedProduct?.compareTo('Qualquer') == 0)) {
                    return LmEslWidgetItem(esl: e);
                  } else {
                    return const SizedBox();
                  } //if filter not applied list all
                } else {
                  return LmEslWidgetItem(esl: e);
                }
              }).toList(),
            );
          }
        },
      ),
    );
  }
}
/*
FilterChip buildSectionFilterChip(String e) {
  return FilterChip(
    selectedColor: MyColorStyles.primary200,
    checkmarkColor: MyColorStyles.primary600,
    labelStyle: TextStyle(color: MyColorStyles.primary600),
    backgroundColor: MyColorStyles.primary100,
    color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return MyColorStyles.danger500;
          } else if (states.contains(MaterialState.disabled)) {
            return MyColorStyles.grey200;
          }
          return MyColorStyles.danger500;
        }),
    label: Text(e.toString()),
    selected: widget.selectedSection.contains(e.toString()),
    onSelected: (value) {
      setState(() {
        if(value){
          widget.selectedSection.add(e.toString());
        }else {
          widget.selectedSection.remove(e.toString());
        }
      });
    },
  );
}
FilterChip buildModuleFilterChip(String e) {
  return FilterChip(
    selectedColor: MyColorStyles.primary200,
    checkmarkColor: MyColorStyles.primary600,
    labelStyle: TextStyle(color: MyColorStyles.primary600),
    backgroundColor: MyColorStyles.primary100,
    color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return MyColorStyles.primary600;
          } else if (states.contains(MaterialState.disabled)) {
            return MyColorStyles.grey200;
          }
          return MyColorStyles.danger500;
        }),
    label: Text(e.toString()),
    selected: widget.selectedModule.contains(e.toString()),
    onSelected: (value) {
      setState(() {
        if(value){
          widget.selectedModule.add(e.toString());
        }else {
          widget.selectedModule.remove(e.toString());
        }
      });
    },
  );
}

FilterChip buildRunnerFilterChip(String e) {
  return FilterChip(
    selectedColor: MyColorStyles.primary200,
    checkmarkColor: MyColorStyles.primary600,
    labelStyle: TextStyle(color: MyColorStyles.primary600),
    backgroundColor: MyColorStyles.primary100,
    color: MaterialStateProperty.resolveWith<Color?>(
            (Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return MyColorStyles.primary600;
          } else if (states.contains(MaterialState.disabled)) {
            return MyColorStyles.grey200;
          }
          return MyColorStyles.danger500;
        }),
    label: Text(e.toString()),
    selected: widget.selectedRunner.contains(e.toString()),
    onSelected: (value) {
      setState(() {
        if(value){
          widget.selectedRunner.add(e.toString());
        }else {
          widget.selectedRunner.remove(e.toString());
        }
      });
    },
  );
}*/
