import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/venue_controller.dart';
import '../models/venue_gate.dart';
import '../widgets/motion.dart';

const Color bgColor = Color(0xFF0B0B10);
const Color surfaceColor = Color(0xFF15151E);
const Color borderColor = Color(0xFF2E2E3D);
const Color primaryRed = Color(0xFFE10600);
const Color secondaryText = Color(0xFFB5B5C3);
const Color successColor = Color(0xFF2ECC71);
// GETX: GetView memberi akses ke VenueController
class VenuePage extends GetView<VenueController> {
  const VenuePage({super.key});

  void _showGateDetails(VenueGate gate) {
    controller.selectGate(gate);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Circuit Park Gate',
                style: TextStyle(
                  color: primaryRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                gate.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                gate.location,
                style: const TextStyle(
                  color: secondaryText,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 22),
              const Divider(color: borderColor),
              const SizedBox(height: 12),
              const Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: primaryRed,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Marina Bay Street Circuit',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Get.back();
                    _showReminder(gate);
                  },
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('Set Reminder'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showReminder(VenueGate gate) {
    Get.bottomSheet(
      ReminderSheet(
        gate: gate,
        controller: controller,
      ),
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Venue Map',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 19,
              ),
            ),
            Text(
              'Marina Bay Street Circuit',
              style: TextStyle(
                color: secondaryText,
                fontSize: 11,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: controller.refreshLocation,
            icon: const Icon(
              Icons.my_location,
              color: primaryRed,
            ),
            tooltip: 'Refresh location',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: FadeSlideIn(
        offsetY: 12,
        duration: const Duration(milliseconds: 380),
        child: RefreshIndicator(
        color: primaryRed,
        backgroundColor: surfaceColor,
        onRefresh: controller.refreshLocation,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // CIRCUIT MAP
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: _CircuitMap(
                      onGateTap: _showGateDetails,
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.fromLTRB(18, 12, 18, 0),
                child: Row(
                  children: [
                    Icon(
                      Icons.touch_app,
                      color: primaryRed,
                      size: 16,
                    ),
                    SizedBox(width: 7),
                    Text(
                      'Tap a gate to view its details. Pinch to zoom.',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // GPS STATUS
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Obx(() {
                  final position = controller.currentPosition.value;

                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: primaryRed.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.gps_fixed,
                            color: primaryRed,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'GPS Location',
                                style: TextStyle(
                                  color: secondaryText,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                position == null
                                    ? 'Waiting for Location...'
                                    : '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                controller.isLoading.value
                                    ? 'Getting Your Location...'
                                    : controller.hasPermission.value
                                        ? 'Location Connected'
                                        : 'Location Permission Required',
                                style: TextStyle(
                                  color: controller.hasPermission.value
                                      ? successColor
                                      : Colors.orange,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: controller.refreshLocation,
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),

              Obx(() {
                if (controller.errorMessage.value.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.errorMessage.value,
                          style: const TextStyle(
                            color: Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                        if (controller.locationDisabled.value ||
                            !controller.hasPermission.value)
                          TextButton(
                            onPressed: () {
                              if (controller.locationDisabled.value) {
                                controller.openLocationSettings();
                              } else {
                                controller.openAppSettings();
                              }
                            },
                            child: const Text(
                              'Open Settings',
                              style: TextStyle(color: primaryRed),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 24),

              // GATE LIST HEADER
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Gates & Proximity',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        ),
                        Obx(() => Text(
                              '${controller.nearbyGates.length} Gates',
                              style: const TextStyle(
                                color: secondaryText,
                                fontSize: 11,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              // LBS + GETX: daftar gate diperbarui lewat Obx
              // NEAREST GATES
              Obx(() {
                if (controller.nearbyGates.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: Text(
                        'Waiting for GPS Location...',
                        style: TextStyle(color: secondaryText),
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  itemCount: controller.nearbyGates.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = controller.nearbyGates[index];
                    final gate = item.gate;

                    return Pressable(
                      child: Material(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(18),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(18),
                          onTap: () => _showGateDetails(gate),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                Container(
                                  width: 42,
                                  height: 42,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF242433),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Text(
                                    gate.id.replaceAll(RegExp(r'[^0-9]'), ''),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        gate.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.isNearby
                                            ? '${item.formattedDistance} · Nearby'
                                            : item.formattedDistance,
                                        style: TextStyle(
                                          color: item.isNearby
                                              ? successColor
                                              : secondaryText,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Material(
                                  color: const Color(0xFF242433),
                                  shape: const CircleBorder(),
                                  child: InkWell(
                                    customBorder: const CircleBorder(),
                                    onTap: () => _showReminder(gate),
                                    child: const SizedBox(
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        Icons.notifications_none_rounded,
                                        size: 19,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }),

              const SizedBox(height: 26),

              // SAVED REMINDERS
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                ),
                child: const Text(
                  'My Gate Reminders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Obx(() {
                if (controller.reminders.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 18,
                    ),
                    child: Text(
                      'No reminders scheduled yet.',
                      style: TextStyle(
                        color: secondaryText,
                        fontSize: 12,
                      ),
                    ),
                  );
                }

                return Column(
                  children: controller.reminders.map((reminder) {
                    final date = DateTime.parse(
                      reminder['dateTime'],
                    );

                    return Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        reminder['gateName'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                      subtitle: Text(
                        '${date.day}/${date.month}/${date.year}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: secondaryText,
                          fontSize: 11,
                        ),
                      ),
                      trailing: IconButton(
                        onPressed: () => controller.deleteReminder(reminder),
                        icon: const Icon(
                          Icons.delete_outline,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    );
                  }).toList(),
                );
              }),
            ],
          ),
        ),
      ),
      ),
    );
  }
}

// INTERACTIVE CIRCUIT MAP
class _CircuitMap extends StatefulWidget {
  final Function(VenueGate) onGateTap;

  const _CircuitMap({
    required this.onGateTap,
  });

  @override
  State<_CircuitMap> createState() => _CircuitMapState();
}

class _CircuitMapState extends State<_CircuitMap> {
  final TransformationController _transformController =
      TransformationController();

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = width * 0.75;
        // Peta berupa gambar yang bisa di-zoom dan digeser
        return SizedBox(
          width: width,
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 1,
                  maxScale: 5,
                  boundaryMargin: const EdgeInsets.all(50),
                  child: SizedBox(
                    width: width,
                    height: height,
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: Image.asset(
                            'assets/images/circuit-park-map.jpg',
                            fit: BoxFit.fill,
                            errorBuilder: (_, __, ___) {
                              return Container(
                                color: const Color(0xFF22222C),
                                alignment: Alignment.center,
                                child: const Text(
                                  'Circuit map image not found.\nCheck assets/images/circuit-park-map.jpg',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),

                        // GATE MARKERS
                        ...VenueGate.all.map((gate) {
                          return Positioned(
                            left: width * gate.mapX - 17,
                            top: height * gate.mapY - 22,
                            child: GestureDetector(
                              onTap: () => widget.onGateTap(gate),
                              child: Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  color: primaryRed,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: primaryRed.withValues(
                                        alpha: 0.65,
                                      ),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  gate.id.replaceAll('gate', ''),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
              ),

              // MAP CONTROLS
              Positioned(
                right: 10,
                top: 10,
                child: Column(
                  children: [
                    _mapButton(
                      Icons.add,
                      () {
                        final matrix = _transformController.value.clone();

                        final currentScale = matrix.getMaxScaleOnAxis();

                        if (currentScale < 5) {
                          matrix.scale(1.3);
                          _transformController.value = matrix;
                        }
                      },
                    ),
                    const SizedBox(height: 7),
                    _mapButton(
                      Icons.remove,
                      () {
                        final matrix = _transformController.value.clone();

                        final currentScale = matrix.getMaxScaleOnAxis();

                        if (currentScale > 1) {
                          matrix.scale(0.77);
                          _transformController.value = matrix;
                        }
                      },
                    ),
                    const SizedBox(height: 7),
                    _mapButton(
                      Icons.center_focus_strong,
                      () {
                        _transformController.value = Matrix4.identity();
                      },
                    ),
                  ],
                ),
              ),

              Positioned(
                left: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Marina Bay Circuit',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _mapButton(
    IconData icon,
    VoidCallback onPressed,
  ) {
    return Material(
      color: const Color(0xDD15151E),
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(30),
        child: SizedBox(
          width: 38,
          height: 38,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }
}

// REMINDER BOTTOM SHEET

class ReminderSheet extends StatefulWidget {
  final VenueGate gate;
  final VenueController controller;

  const ReminderSheet({
    super.key,
    required this.gate,
    required this.controller,
  });

  @override
  State<ReminderSheet> createState() => _ReminderSheetState();
}

class _ReminderSheetState extends State<ReminderSheet> {
  DateTime selectedDate = DateTime(2027, 10, 8);

  TimeOfDay selectedTime = const TimeOfDay(
    hour: 16,
    minute: 30,
  );

  bool isSaving = false;

  final List<DateTime> raceDates = [
    DateTime(2027, 10, 8),
    DateTime(2027, 10, 9),
    DateTime(2027, 10, 10),
  ];

  Future<void> _selectTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (result != null) {
      setState(() {
        selectedTime = result;
      });
    }
  }

  Future<void> _save() async {
    setState(() => isSaving = true);

    final dateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );
    // Mengirim tanggal dan jam pilihan ke controller
    try {
      await widget.controller.saveReminder(
        gate: widget.gate,
        dateTime: dateTime,
      );

      if (!mounted) return;

      Get.back();

      Get.snackbar(
        'Reminder saved',
        'Your reminder for ${widget.gate.name} has been scheduled.',
        backgroundColor: surfaceColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      if (!mounted) return;

      Get.snackbar(
        'Unable to save reminder',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: surfaceColor,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) {
        setState(() => isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: const BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Set Reminder',
              style: TextStyle(
                color: primaryRed,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Remind Me at the Gate',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.gate.name,
              style: const TextStyle(
                color: secondaryText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Race Day',
              style: TextStyle(
                color: secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: List.generate(
                raceDates.length,
                (index) {
                  final date = raceDates[index];
                  final selected = selectedDate.day == date.day;

                  const days = ['Fri', 'Sat', 'Sun'];

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedDate = date;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 13,
                          ),
                          decoration: BoxDecoration(
                            color:
                                selected ? primaryRed : const Color(0xFF242433),
                            borderRadius: BorderRadius.circular(11),
                            border: Border.all(
                              color: selected ? primaryRed : borderColor,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                days[index],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '${date.day} Oct',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Reminder Time',
              style: TextStyle(
                color: secondaryText,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _selectTime,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF242433),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.access_time,
                      color: primaryRed,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      selectedTime.format(context),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Change',
                      style: TextStyle(
                        color: primaryRed,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryRed,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Save Reminder',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
