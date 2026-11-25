import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';

class HomeController extends GetxController {
  final ApiService _apiService = ApiService();

  final ScrollController scrollController = ScrollController();
  final GlobalKey carouselKey = GlobalKey();

  // Countdown fields
  final days = 0.obs;
  final hours = 0.obs;
  final minutes = 0.obs;
  final seconds = 0.obs;
  Timer? _countdownTimer;

  // Weather & Haze PM2.5 fields
  final weather = Rxn<WeatherData>();
  final airQuality = Rxn<AirQualityData>();
  final isLoadingWeather = true.obs;

  // Race target: Singapore Grand Prix 2027 (October 8, 2027 15:00 SGT)
  static final DateTime raceDate = DateTime(2027, 10, 8, 15, 0, 0);


  // GETX: onInit memulai countdown dan mengambil data cuaca
  @override
  void onInit() {
    super.onInit();
    _startCountdown();
    fetchWeatherAndAirQuality();
  }

  @override
  void onClose() {
    _countdownTimer?.cancel();
    scrollController.dispose();
    super.onClose();
  }

  // Countdown diperbarui setiap 1 detik
  void _startCountdown() {
    _updateTimeLeft();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateTimeLeft();
    });
  }

  void _updateTimeLeft() {
    final now = DateTime.now();
    final difference = raceDate.difference(now);
    if (difference.isNegative) {
      days.value = 0;
      hours.value = 0;
      minutes.value = 0;
      seconds.value = 0;
    } else {
      days.value = difference.inDays;
      hours.value = difference.inHours % 24;
      minutes.value = difference.inMinutes % 60;
      seconds.value = difference.inSeconds % 60;
    }
  }
  // API: cuaca dan kualitas udara diambil bersamaan
  Future<void> fetchWeatherAndAirQuality() async {
    isLoadingWeather.value = true;
    try {
      final results = await Future.wait([
        _apiService.fetchWeather(),
        _apiService.fetchAirQuality(),
      ]);
      weather.value = results[0] as WeatherData;
      airQuality.value = results[1] as AirQualityData;
    } finally {
      isLoadingWeather.value = false;
    }
  }

  // Smooth scroll to ticket carousel when BUY NOW is clicked
  void scrollToCarousel() {
    final ctx = carouselKey.currentContext;
    if (ctx != null) {
      Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
        alignment: 0.04,
      );
    } else if (scrollController.hasClients) {
      scrollController.animateTo(
        300.0, // fallback: perkiraan posisi carousel
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    }
  }
}
