import 'package:flutter/material.dart';

import '../../components/my_home_button.dart';

class Step0SearchActions extends StatefulWidget {
  const Step0SearchActions({super.key});

  @override
  State<StatefulWidget> createState() => _Step0SearchActionsState();
}

class _Step0SearchActionsState extends State<Step0SearchActions> {
  final String _currentViewTitle = 'Consulta - Ações';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Consultas", style: TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _buildCards(),
      ),
      resizeToAvoidBottomInset: false,
    );
  }

  Widget _buildCards() {
    return Flex(
      direction: Axis.vertical,
      children: [
        Expanded(
          flex: 1,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                flex: 1,
                child: MyHomeButton(
                    buttonLabel: 'Localizar produtos na loja',
                    onPressedCallBack: () {
                      Navigator.of(context).pushNamed(
                        '/search/byProductName',
                      );
                    },
                    // buttonIcon: Icons.light_mode_outlined),
                    buttonIcon: Icons.manage_search_outlined),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                flex: 1,
                child: MyHomeButton(
                    buttonLabel: 'Localizar etiquetas de um produto',
                    onPressedCallBack: () {
                      Navigator.of(context).pushNamed(
                        '/search/byProductNameListingEsl',
                      );
                    },
                    buttonIcon: Icons.location_on),
                    // buttonIcon: Icons.location_searching),
                    // buttonIcon: Icons.light_mode_outlined),
                    // buttonIcon: Icons.share_location_rounded),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                flex: 1,
                child: MyHomeButton(
                    buttonLabel: 'Consultar etiqueta por MAC',
                    onPressedCallBack: () {
                      Navigator.of(context).pushNamed(
                        '/search/byMac/macReader',
                      );
                    },
                    buttonIcon: Icons.screen_search_desktop_outlined),
              ),
            ],
          ),
        ),
        //Expanded(flex: 1, child: Container()),

        //Expanded(flex: 1, child: Container()),

        // const SizedBox(height: 16,),
        Expanded(
          flex: 1,
          child: Flex(
            direction: Axis.vertical,
            children: [
              Expanded(
                flex: 1,
                child: MyHomeButton(
                    buttonLabel: 'Consultar etiquetas da loja',
                    onPressedCallBack: () {
                      Navigator.of(context).pushNamed(
                        '/search/all',
                      );
                    },
                    buttonIcon: Icons.format_list_numbered),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
