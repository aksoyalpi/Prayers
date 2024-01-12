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
    sunrise: json['data'][day-1]['timings']["Sunrise"],
    dhuhr: json['data'][day-1]['timings']["Dhuhr"],
    asr: json['data'][day-1]['timings']["Asr"],
    maghrib: json['data'][day-1]['timings']["Maghrib"],
    isha: json['data'][day-1]['timings']["Isha"],
    //gregorianDate: DateTime.parse(json['data'][day-1]['date']['gregorian']["date"]),
    //hijriDate: "${json['data'][day-1]['date']['hijri']["month"]["en"]} ${json['data'][day-1]['date']['hijri']["day"]}, ${json['data'][day-1]['date']['hijri']["year"]}"
  );

  factory Time.fromList(List<String> times) => Time(
    fajr: times[0],
    sunrise: times[1],
    dhuhr: times[2],
    asr: times[3],
    maghrib: times[4],
    isha: times[5],
  );

  List<String> toList(){
    return [fajr, sunrise, dhuhr, asr, maghrib, isha];
  }

}