import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/input_formatters.dart';

class VehicleInfoCard extends StatelessWidget {
  final TextEditingController plateCtl;
  final TextEditingController motorCtl;
  final TextEditingController nameCtl;

  const VehicleInfoCard({
    super.key,
    required this.plateCtl,
    required this.motorCtl,
    required this.nameCtl,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isVeryNarrow = constraints.maxWidth < 320;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isVeryNarrow) ...[
                TextField(
                  controller: plateCtl,
                  inputFormatters: [PlateInputFormatter()],
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w800),
                  decoration: const InputDecoration(
                    labelText: 'Plat Nomor',
                    hintText: 'B 1234 XYZ',
                    fillColor: Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: motorCtl,
                  textCapitalization: TextCapitalization.words,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(
                    labelText: 'Jenis Motor',
                    hintText: 'Vario / Beat',
                    fillColor: Color(0xFFF8FAFC),
                  ),
                ),
              ] else ...[
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: TextField(
                        controller: plateCtl,
                        inputFormatters: [PlateInputFormatter()],
                        textCapitalization: TextCapitalization.characters,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w800),
                        decoration: const InputDecoration(
                          labelText: 'Plat Nomor',
                          hintText: 'B 1234 XYZ',
                          fillColor: Color(0xFFF8FAFC),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 4,
                      child: TextField(
                        controller: motorCtl,
                        textCapitalization: TextCapitalization.words,
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w700),
                        decoration: const InputDecoration(
                          labelText: 'Jenis Motor',
                          hintText: 'Vario / Beat',
                          fillColor: Color(0xFFF8FAFC),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              TextField(
                controller: nameCtl,
                textCapitalization: TextCapitalization.words,
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  labelText: 'Nama Pelanggan (Boleh kosong)',
                  prefixIcon: Icon(Icons.person_outline_rounded,
                      color: AppColors.inkMuted),
                  fillColor: Color(0xFFF8FAFC),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
