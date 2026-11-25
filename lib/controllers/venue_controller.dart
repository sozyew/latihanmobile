import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/venue_gate.dart';
import '../services/venue_notification_service.dart';

class GateDistance {
  final VenueGate gate;
  final double distance;

  const GateDistance({
    required this.gate,
    required this.distance,
  });
  // LBS: gate dianggap dekat jika jaraknya di bawah 150 m
  bool get isNearby => distance < 150;
  // CHALLENGE: format satuan jarak (m/km)
  String get formattedDistance {
    if (distance < 1000) {
      return '${distance.round()} m';
    }

    return '${(distance / 1000).toStringAsFixed(2)} km';
  }
}

class VenueController extends GetxController {
  final VenueNotificationService notifications;

  VenueController({
    required this.notifications,
  });

  final Rxn<Position> currentPosition = Rxn<Position>();

  final RxList<GateDistance> nearbyGates = <GateDistance>[].obs;

  final RxList<Map> reminders = <Map>[].obs;

  final Rxn<VenueGate> selectedGate = Rxn<VenueGate>();

  final RxBool isLoading = false.obs;
  final RxBool hasPermission = false.obs;
  final RxBool locationDisabled = false.obs;

  final RxString errorMessage = ''.obs;

  Box? _reminderBox;
  bool _initialized = false;

  @override
  void onReady() {
    super.onReady();
    initializeVenue();
  }
  // LOCAL STORAGE: membuka box Hive untuk reminder
  Future<void> initializeVenue() async {
    if (_initialized || isLoading.value) return;
    _initialized = true;
    try {
      _reminderBox = await Hive.openBox(
        'venue_gate_reminders',
      );

      loadReminders();

      await notifications.initialize();

      await refreshLocation();
    } catch (e) {
      _initialized = false;
      errorMessage.value = 'Unable to initialize Venue services.';
    }
  }

  void loadReminders() {
    if (_reminderBox == null) return;

    reminders.assignAll(
      _reminderBox!.values.whereType<Map>().toList(),
    );
  }
  // LBS: cek layanan dan izin lokasi
  Future<void> refreshLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        locationDisabled.value = true;
        hasPermission.value = false;

        errorMessage.value = 'Please enable location services on your device.';

        return;
      }

      locationDisabled.value = false;

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        hasPermission.value = false;
        errorMessage.value = 'Location permission was denied.';
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        hasPermission.value = false;

        errorMessage.value = 'Location permission is permanently denied.';

        return;
      }

      hasPermission.value = true;
      // LBS: mengambil posisi GPS pengguna
      final position = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10),
      );

      currentPosition.value = position;

      calculateDistances(position);
    } catch (e) {
      errorMessage.value =
          'Unable to get your current location. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }
  // LBS: jarak garis lurus pengguna ke gate (meter)
  void calculateDistances(Position position) {
    final results = VenueGate.all.map((gate) {
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        gate.latitude,
        gate.longitude,
      );

      return GateDistance(
        gate: gate,
        distance: distance,
      );
    }).toList();
    	// LBS: urutkan gate dari yang terdekat
    results.sort(
      (a, b) => a.distance.compareTo(b.distance),
    );

    nearbyGates.assignAll(results);
  }

  void selectGate(VenueGate gate) {
    selectedGate.value = gate;
  }

  Future<void> saveReminder({
    required VenueGate gate,
    required DateTime dateTime,
  }) async {
    _reminderBox ??= await Hive.openBox('venue_gate_reminders');

    if (!dateTime.isAfter(DateTime.now())) {
      throw Exception('Please select a future date and time.');
    }

    final id = DateTime.now().microsecondsSinceEpoch.remainder(2147483647);
    // NOTIFIKASI: jadwalkan reminder gate
    await notifications.scheduleReminder(
      id: id,
      gateName: gate.name,
      dateTime: dateTime,
    );

    final reminder = <String, dynamic>{
      'id': id,
      'gateId': gate.id,
      'gateName': gate.name,
      'location': gate.location,
      'dateTime': dateTime.toIso8601String(),
    };
    	// LOCAL STORAGE: simpan reminder ke Hive
    await _reminderBox!.put(
      id.toString(),
      reminder,
    );

    loadReminders();
  }

  Future<void> deleteReminder(Map reminder) async {
    final id = reminder['id'] as int?;

    if (id == null) return;
    // NOTIFIKASI: batalkan reminder yang dihapus
    await notifications.cancelReminder(id);

    await _reminderBox?.delete(id.toString());

    loadReminders();
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
