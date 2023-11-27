class Time {
  final List data;
  final int day;
  final String dhuhr;
  final String sunrise;
  final String asr;
  final String maghrib;
  final String isha;

  Time({
    required this.data,
    required this.day,
    required this.dhuhr,
    required this.sunrise,
    required this.asr,
    required this.maghrib,
    required this.isha
  });

  factory Time.fromJson(Map<String, dynamic> json) => Time(
    data: json['data'],
    day: DateTime.now().day,
    dhuhr: json['data']["day"]["Dhuhr"],
    sunrise: json['data']["day"]["Sunrise"],
    asr: json['data']["day"]["Asr"],
    maghrib: json['data']["day"]["Maghrib"],
    isha: json['data']["day"]["Isha"],
  );

}