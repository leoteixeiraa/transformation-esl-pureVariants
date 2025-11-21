import 'package:esl_mobile_app/components/lm_decommissioning_log_item.dart';
import 'package:esl_mobile_app/dto/decommissioning_dto.dart';
import 'package:flutter/material.dart';

import '../../dao/decommissioning_dao.dart';

class DecommissioningLogsView extends StatefulWidget {
  final List<DecommissioningDto> decommissioningsList;

  const DecommissioningLogsView(
      {super.key, required this.decommissioningsList});

  @override
  State<DecommissioningLogsView> createState() =>
      _DecommissioningLogsViewState();
}

class _DecommissioningLogsViewState extends State<DecommissioningLogsView> {
  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Descomissionamento')),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verificar descomissionamentos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Flexible(
                child: FutureBuilder<List<DecommissioningDto>>(
                  future: DecommissioningDao()
                      .getAllByEmployeeCode(), // The future to wait for
                  builder: (BuildContext context,
                      AsyncSnapshot<List<DecommissioningDto>> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      // While the future is loading
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      // If an error occurred
                      return Text('Error: ${snapshot.error}');
                    } else {
                      // If the future completed successfully
                      if (snapshot.data!.isEmpty) {
                        return const Text(
                            'Faça um descomissionamento para que ele seja visualizado aqui.');
                      }
                      return ListView(
                        children: snapshot.data!.map((e) {
                          return LmDecommissioningLogItem(dto: e);
                        }).toList(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      );
}
