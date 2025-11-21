import 'package:flutter/material.dart';

class InstallationGlnForm extends StatefulWidget {
  const InstallationGlnForm({super.key});

  @override
  State<InstallationGlnForm> createState() => _InstallationGlnFormState();
}

class _InstallationGlnFormState extends State<InstallationGlnForm> {
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(20),
        children: [
          //Row para o botao de instalação
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //botao de instalação
              ElevatedButton(
                  onPressed: () {
                    //formKey.currentState?.save();
                    //print('Seção: $_gln');
                    //print('Seção: $_mac');
                  },
                  child: const Text('Install')),
            ],
          ),
        ],
      );
}
