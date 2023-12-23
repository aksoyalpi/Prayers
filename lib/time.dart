class Time {
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;
  //final DateTime gregorianDate;
  //final String hijriDate;

  Time({
    required this.fajr,
    required this.dhuhr,
    required this.sunrise,
    required this.asr,
    required this.maghrib,
    required this.isha,
    //required this.gregorianDate,
    //required this.hijriDate
  });

  factory Time.fromJson(Map<String, dynamic> json, int day) => Time(
    fajr: json['data'][day-1]['timings']['Fajr'],
    dhuhr: json['data'][day-1]['timings']["Dhuhr"],
    sunrise: json['data'][day-1]['timings']["Sunrise"],
    asr: json['data'][day-1]['timings']["Asr"],
    maghrib: json['data'][day-1]['timings']["Maghrib"],
    isha: json['data'][day-1]['timings']["Isha"],
    //gregorianDate: DateTime.parse(json['data'][day-1]['date']['gregorian']["date"]),
    //hijriDate: "${json['data'][day-1]['date']['hijri']["month"]["en"]} ${json['data'][day-1]['date']['hijri']["day"]}, ${json['data'][day-1]['date']['hijri']["year"]}"
  );

  List<String> toList(){
    return [fajr, dhuhr, sunrise, asr, maghrib, isha];
  }

}