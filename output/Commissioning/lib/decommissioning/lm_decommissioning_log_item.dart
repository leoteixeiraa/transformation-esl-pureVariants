import 'package:esl_mobile_app/dto/decommissioning_dto.dart';
import 'package:esl_mobile_app/dto/dto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/notification_exception_decoder.dart';

//CustomListItem
class LmDecommissioningLogItem extends StatelessWidget {
  final DecommissioningDto dto;

  const LmDecommissioningLogItem({super.key, required this.dto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DecommissioningDescription(dto: dto),
        ],
      ),
    );
  }
}

//_VideoDescription
class _DecommissioningDescription extends StatelessWidget {
  const _DecommissioningDescription({required this.dto});
  final DecommissioningDto dto;

  @override
  Widget build(BuildContext context) {
    var timestamp = dto.timestamp;
    String dateString = timestamp != null
        ? DateFormat("HH:mm:ss dd/MM/yyyy").format(DateTime.parse(timestamp))
        : "";
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${dateString.substring(0, 5)} de ${dateString.substring(9, 19)}",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 20),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    SelectableText('MAC: ${dto.mac.getMac()}',
                        style: const TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(height: 4),
                    Text(
                      textAlign: TextAlign.justify,
                      "Status da operação: ${decodeNotificationMessage(dto.statusDecription ?? '')}",
                      softWrap: true,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (dto.status == ActionStatus.success)
                      const Icon(
                        Icons.check_circle_outline,
                        color: Color(0xFF3C7E27),
                      ),
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}
