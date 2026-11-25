import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherData {
  final double temperature;
  final int weatherCode;
  final String description;
  final String icon;

  WeatherData({
    required this.temperature,
    required this.weatherCode,
    required this.description,
    required this.icon,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final temp = (current['temperature_2m'] as num?)?.toDouble() ?? 29.0;
    final code = (current['weather_code'] as num?)?.toInt() ?? 1;

    String desc = 'Clear Sky';
    String icon = '☀️';

    if (code == 0) {
      desc = 'Clear Sky';
      icon = '☀️';
    } else if (code <= 3) {
      desc = 'Partly Cloudy';
      icon = '⛅';
    } else if (code <= 48) {
      desc = 'Foggy / Hazy';
      icon = '🌫️';
    } else if (code <= 67) {
      desc = 'Rainy';
      icon = '🌧️';
    } else if (code <= 82) {
      desc = 'Showers';
      icon = '🌦️';
    } else if (code >= 95) {
      desc = 'Thunderstorm';
      icon = '⛈️';
    }

    return WeatherData(
      temperature: temp,
      weatherCode: code,
      description: desc,
      icon: icon,
    );
  }

  factory WeatherData.fallback() {
    return WeatherData(
      temperature: 29.5,
      weatherCode: 1,
      description: 'Partly Cloudy',
      icon: '⛅',
    );
  }
}

class AirQualityData {
  final double pm25;
  final String qualityStatus;
  final String advisory;

  AirQualityData({
    required this.pm25,
    required this.qualityStatus,
    required this.advisory,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>? ?? {};
    final pm25 = (current['pm2_5'] as num?)?.toDouble() ?? 12.0;

    String status = 'Good';
    String advisory = 'Normal outdoor activities recommended.';

    if (pm25 <= 12.0) {
      status = 'Good (PSI 0-50)';
      advisory = 'Air quality is satisfactory. Ideal for race weekend.';
    } else if (pm25 <= 35.4) {
      status = 'Moderate (PSI 51-100)';
      advisory =
          'Acceptable air quality. Most people can engage in outdoor activities.';
    } else if (pm25 <= 55.4) {
      status = 'Unhealthy (PSI 101-200)';
      advisory = 'Reduce prolonged intense outdoor exertion.';
    } else {
      status = 'Very Unhealthy';
      advisory = 'Avoid outdoor exertion. Wear masks if sensitive.';
    }

    return AirQualityData(
      pm25: pm25,
      qualityStatus: status,
      advisory: advisory,
    );
  }

  factory AirQualityData.fallback() {
    return AirQualityData(
      pm25: 14.2,
      qualityStatus: 'Good / Moderate',
      advisory: 'Optimal conditions for Marina Bay Grand Prix.',
    );
  }
}

// API: URL cuaca, kualitas udara, dan kurs

class ExchangeRates {
  final double sgdToIdr;
  final double sgdToUsd;
  final DateTime lastUpdated;

  ExchangeRates({
    required this.sgdToIdr,
    required this.sgdToUsd,
    required this.lastUpdated,
  });

  factory ExchangeRates.fallback() {
    return ExchangeRates(
      sgdToIdr: 11850.0,
      sgdToUsd: 0.745,
      lastUpdated: DateTime.now(),
    );
  }
}

class ApiService {
  static const String weatherUrl =
      'https://api.open-meteo.com/v1/forecast?latitude=1.2914&longitude=103.8640&current=temperature_2m,weather_code';

  static const String airQualityUrl =
      'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=1.2914&longitude=103.8640&current=pm2_5';

  static const String frankfurterUrl =
      'https://api.frankfurter.dev/v1/latest?base=SGD&symbols=IDR,USD';

  // 1. Fetch Marina Bay Circuit Weather
  // API: GET cuaca Marina Bay, pakai fallback jika gagal
  Future<WeatherData> fetchWeather() async {
    try {
      final response = await http
          .get(Uri.parse(weatherUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return WeatherData.fromJson(data);
      }
    } catch (_) {}
    return WeatherData.fallback();
  }
  // API: GET kualitas udara (PM2.5)
  // 2. Fetch Singapore Marina Bay Air Quality (PM2.5 / Haze)
  Future<AirQualityData> fetchAirQuality() async {
    try {
      final response = await http
          .get(Uri.parse(airQualityUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return AirQualityData.fromJson(data);
      }
    } catch (_) {}
    return AirQualityData.fallback();
  }
  // API: GET kurs SGD ke IDR dan USD
  // 3. Fetch Currency Rates (SGD to IDR and USD)
  Future<ExchangeRates> fetchExchangeRates() async {
    try {
      final response = await http
          .get(Uri.parse(frankfurterUrl))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rates = data['rates'] as Map<String, dynamic>? ?? {};
        final idr = (rates['IDR'] as num?)?.toDouble() ?? 11850.0;
        final usd = (rates['USD'] as num?)?.toDouble() ?? 0.745;
        return ExchangeRates(
          sgdToIdr: idr,
          sgdToUsd: usd,
          lastUpdated: DateTime.now(),
        );
      }
    } catch (_) {}
    return ExchangeRates.fallback();
  }
}
