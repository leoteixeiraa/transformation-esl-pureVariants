import 'dart:async';
import 'package:esl_mobile_app/components/lm_dropdown_button.dart';
import 'package:esl_mobile_app/dao/gln_dao.dart';
import 'package:esl_mobile_app/dao/physical_location_dao.dart';
import 'package:esl_mobile_app/services/cache_management.dart';

import 'package:flutter/material.dart';
import 'package:esl_mobile_app/services/barcode_scanner/scanner.dart';

import '../../components/my_solid_button.dart';
import '../../models/actionArguments/installation_arguments.dart';

class Step2InstallationGlnInput extends StatefulWidget {
  Step2InstallationGlnInput({super.key, this.args});

  late InstallationArguments? args;

  late Future<Map<String, String>> ftrSections;
  Future<List<String>>? ftrRunner;
  Future<List<String>>? ftrModules;

  List<String> sectionKeys = [];
  List<String> sectionValues = [];
  List<String> runnerValues = [];
  List<String> moduleValues = [];

  @override
  State<StatefulWidget> createState() => _Step2InstallationGlnInputState();
}

class _Step2InstallationGlnInputState extends State<Step2InstallationGlnInput> {
  var runnerListStream = StreamController<List<String>>();
  bool _loading = false;

  //MAC ADDRESS SCANNER
  TextEditingController scan = TextEditingController();
  var macAddressScanner = Scanner();

  @override
  void initState() {
    _loading = true;
    String auxSection;// = widget.args?.section ?? '';
    String? auxRunner = widget.args?.runner;
    widget.ftrSections = GlnDao().getSections().then((value) {
      auxSection = value.keys.first;
      widget.ftrRunner = GlnDao().getRunners(currentSection: value.keys.first).then((value) {
        widget.ftrModules = GlnDao().getModules(currentSection: auxSection, currentRunner: value.first);
        return value;
      });
      return value;
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  loadRunnerDropdown(String section) {}

  @override
  Widget build(BuildContext context) {
    widget.args =
        ModalRoute.of(context)!.settings.arguments as InstallationArguments;
    return Scaffold(
      appBar: AppBar(title: const Text('Instalação de etiqueta')),
      body: FutureBuilder<Map<String, String>>(
        future: widget.ftrSections,
        builder: (BuildContext context,
            AsyncSnapshot<Map<String, String>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // While the future is loading
            return _refreshingWidget();
          } else if (snapshot.hasError) {
            // If an error occurred
            return Text('Error: ${snapshot.error}');
          }
          widget.sectionKeys = snapshot.data!.keys.toList();
          widget.sectionValues = snapshot.data!.values.toList();
          widget.args?.section = widget.sectionKeys.first;
          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
            children: [
              _buildSglnCard(),
              const SizedBox(height: 16),
              //_buildButtonRow(),
            ],
          );
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: buildFloatingButton(context),
    );
  }

  Flex _refreshingWidget() {
    return const Flex(
      direction: Axis.vertical,
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flex(
          mainAxisSize: MainAxisSize.max,
          direction: Axis.horizontal,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              children: [
                Row(
                  children: [
                    CircularProgressIndicator(),
                  ],
                ),
                SizedBox(
                  height: 24,
                ),
                Text('Estamos trazendo as informações'),
              ],
            ),
            //   Expanded(child: Text('Estamos trazendo as ')),
          ],
        ),
      ],
    );
  }

  Padding buildFloatingButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: MySolidButton(
          buttonLabel: Text('Revisão'),
          onPressedCallBack: () => {
            Navigator.of(context).pushNamed(
              '/installation/install/checkout',
              arguments: widget.args,
            ),
          },
        ),
      ),
    );
  }

  Widget _buildSglnCard() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          Text('Informe a localização',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          LmDropdownButton(
            itemValuesList: widget.sectionValues,
            itemKeysList: widget.sectionKeys,
            value: widget.sectionValues.isNotEmpty
                ? widget.sectionValues.first
                : '',
            label: 'Seção',
            valueSetter: (value) {
                widget.args!.section = value;
                debugPrint(value);
            },
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<String>>(
            future: widget.ftrRunner,
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While the future is loading
                return _refreshingWidget();
              } else if (snapshot.hasError) {
                // If an error occurred
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return _disabledDropdown('Corredor');
              }
              // var a = ;
              widget.runnerValues = snapshot.data!;
              widget.args?.runner = widget.runnerValues.first;
              return LmDropdownButton(
                itemValuesList: widget.runnerValues,
                value: widget.args!.runner,
                label: 'Corredor',
                valueSetter: (value) {
                  widget.args!.runner = value;
                  debugPrint(value);
                },
              );
            },
          ),
          const SizedBox(height: 24),
          FutureBuilder<List<String>>(
            future: widget.ftrRunner,
            builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While the future is loading
                return _refreshingWidget();
              } else if (snapshot.hasError) {
                // If an error occurred
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData) {
                return _disabledDropdown('Módulo');
              }
              // var a = ;
              widget.moduleValues= snapshot.data!;
              widget.args?.module = widget.moduleValues.first;
              return LmDropdownButton(
                itemValuesList: widget.moduleValues,
                value: widget.args!.module,
                label: 'Módulo',
                valueSetter: (value) {
                  widget.args!.module = value;
                  debugPrint(value);
                },
              );
            },
          ),
          const SizedBox(height: 24),
        ],
      );
}

Widget _disabledDropdown(String labelParam) {
  return LmDropdownButton(
    itemValuesList: const [],
    value: '',
    label: labelParam,
    valueSetter: (value) {},
  );
}
