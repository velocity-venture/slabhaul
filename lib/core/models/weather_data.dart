class WeatherData {
  final CurrentWeather current;
  final List<HourlyForecast> hourly;
  final List<DailyForecast> daily;
  final DateTime fetchedAt;

  const WeatherData({
    required this.current,
    required this.hourly,
    required this.daily,
    required this.fetchedAt,
  });
}

class CurrentWeather {
  final double temperatureF;
  final double feelsLikeF;
  final int humidity;
  final double windSpeedMph;
  final int windDirectionDeg;
  final double pressureMb;
  final int weatherCode;
  final String description;

  const CurrentWeather({
    required this.temperatureF,
    required this.feelsLikeF,
    required this.humidity,
    required this.windSpeedMph,
    required this.windDirectionDeg,
    required this.pressureMb,
    required this.weatherCode,
    required this.description,
  });
}

class HourlyForecast {
  final DateTime time;
  final double temperatureF;
  final double windSpeedMph;
  final int windDirectionDeg;
  final double pressureMb;
  final double precipitationMm;

  const HourlyForecast({
    required this.time,
    required this.temperatureF,
    required this.windSpeedMph,
    required this.windDirectionDeg,
    required this.pressureMb,
    required this.precipitationMm,
  });
}

class DailyForecast {
  final DateTime date;
  final double highF;
  final double lowF;
  final DateTime sunrise;
  final DateTime sunset;
  final double precipitationMm;
  final int weatherCode;

  const DailyForecast({
    required this.date,
    required this.highF,
    required this.lowF,
    required this.sunrise,
    required this.sunset,
    required this.precipitationMm,
    required this.weatherCode,
  });
}
