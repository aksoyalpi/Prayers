class Time {
  final List data;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  Time({
    required this.data,
    required this.fajr,
    required this.dhuhr,
    required this.sunrise,
    required this.asr,
    required this.maghrib,
    required this.isha
  });

  factory Time.fromJson(Map<String, dynamic> json, int day) => Time(
    data: json['data'],
    fajr: json['data'][day]['timings']['Fajr'],
    dhuhr: json['data'][day]['timings']["Dhuhr"],
    sunrise: json['data'][day]['timings']["Sunrise"],
    asr: json['data'][day]['timings']["Asr"],
    maghrib: json['data'][day]['timings']["Maghrib"],
    isha: json['data'][day]['timings']["Isha"],
  );

}