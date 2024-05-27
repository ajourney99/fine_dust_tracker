import 'package:flutter/material.dart';
import 'package:fine_dust_tracker/services/fine_dust_api_service.dart';
import 'package:fine_dust_tracker/models/measurement_station_model.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<MeasurementStation?> _measurementStationFuture;

  @override
  void initState() {
    super.initState();
    _measurementStationFuture = fineDustAPIService();

    initializeDateFormatting('ko_KR', null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<MeasurementStation?>(
        future: _measurementStationFuture,
        builder: (context, snapshot) {
          final isLoading = snapshot.connectionState == ConnectionState.waiting;

          return Stack(
            children: [
              buildContent(snapshot),
              if (isLoading) buildLoadingSpinner(),
            ],
          );
        },
      ),
    );
  }

  Widget buildContent(AsyncSnapshot<MeasurementStation?> snapshot) {
    if (snapshot.hasError) {
      return const Center(
        child: Text('Error fetching data'),
      );
    } else if (snapshot.hasData) {
      final currentStation = snapshot.data!;
      final currentAddr = currentStation.currentAddr;
      final pm10Value = currentStation.pm10Value;
      final pm25Value = currentStation.pm25Value;
      final dataTime = currentStation.dataTime;
      final pm10AirQuality = currentStation.pm10AirQuality();
      final pm25AirQuality = currentStation.pm25AirQuality();
      final backgroundColor = currentStation.backgroundColor();

      final lastUpdatedTime = DateFormat('M월 dd일\na h시', 'ko')
          .format(dataTime)
          .replaceAll('AM', '오전')
          .replaceAll('PM', '오후');

      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.bottomRight,
            end: Alignment.topLeft,
            colors: [
              backgroundColor,
              const Color.fromARGB(255, 235, 235, 235),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 현재 위치
              Text(
                currentAddr,
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 25),
              // 정보 기준 시각
              Text(
                "$lastUpdatedTime 기준",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        const Text(
                          '미세먼지',
                          style: TextStyle(fontSize: 17),
                        ),
                        const SizedBox(height: 5),
                        // 미세먼지 수치
                        Text(
                          pm10AirQuality,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // const Icon(Icons.tag_faces_outlined, size: 100),
                        const SizedBox(height: 10),
                        Text(
                          '$pm10Value ㎛',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        const Text('초미세먼지', style: TextStyle(fontSize: 17)),
                        const SizedBox(height: 5),
                        // 초미세먼지 수치
                        Text(
                          pm25AirQuality,
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // const Icon(Icons.mood_bad_outlined, size: 100),
                        const SizedBox(height: 10),
                        Text(
                          '$pm25Value ㎛',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              TextButton(
                onPressed: () {
                  setState(
                    () {
                      _measurementStationFuture = fineDustAPIService();
                    },
                  );
                },
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 45,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return const Center(
        child: Text('No data available'),
      );
    }
  }

  Widget buildLoadingSpinner() {
    return const Center(
      child: CircularProgressIndicator(color: Colors.white),
    );
  }
}
