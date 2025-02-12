import 'package:demo/widgets/healthTile.dart';
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:demo/constants/colors.dart';
import 'package:demo/constants/fonts.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref("users/user1/healthMetrics");

  // Health metrics variables
  int _sleepHours = 0;
  int _heartRate = 0;
  int _bloodPressure = 0;
  int _bloodOxygen = 0;
  double _weight = 0.0;
  int _stress = 0;

  @override
  void initState() {
    super.initState();
    _listenToDataChanges();
    _initializeDataIfEmpty();
  }

  void _listenToDataChanges() {
    _dbRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        final data = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          _sleepHours = data['sleepHours'] ?? 0;
          _heartRate = data['heartRate'] ?? 0;
          _bloodPressure = data['bloodPressure'] ?? 0;
          _bloodOxygen = data['bloodOxygen'] ?? 0;
          _weight = (data['weight'] ?? 0).toDouble();
          _stress = data['stress'] ?? 0;
        });
      }
    });
  }

  Future<void> _initializeDataIfEmpty() async {
    final snapshot = await _dbRef.get();
    if (snapshot.value == null) {
      await _dbRef.set({
        "sleepHours": 8,
        "heartRate": 75,
        "bloodPressure": 120,
        "bloodOxygen": 98,
        "weight": 70.0,
        "stress": 50,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Monitoring',
        ),
      ),
      backgroundColor: isDark
          ? const Color.fromARGB(105, 15, 15, 15)
          : const Color.fromARGB(100, 245, 245, 245),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const SizedBox(height: 25), // Increased top padding
              // Replace Image.asset with Stack for water effect
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 200,
                    width: 200,
                    child: WaveWidget(
                      config: CustomConfig(
                        gradients: isDark
                            ? [
                                [Colors.blue[900]!, Colors.blue[800]!],
                                [Colors.blue[800]!, Colors.blue[700]!],
                                [Colors.blue[700]!, Colors.blue[600]!],
                              ]
                            : [
                                [Colors.blue[400]!, Colors.blue[300]!],
                                [Colors.blue[300]!, Colors.blue[200]!],
                                [Colors.blue[200]!, Colors.blue[100]!],
                              ],
                        durations: [19440, 10800, 6000],
                        heightPercentages: [0.65, 0.66, 0.68],
                        blur: const MaskFilter.blur(BlurStyle.solid, 10),
                        gradientBegin: Alignment.bottomLeft,
                        gradientEnd: Alignment.topRight,
                      ),
                      waveAmplitude: 0,
                      size: const Size(200, 200),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.asset(
                      'assets/logo22.png',
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                    // child: ColorFiltered(
                    //   colorFilter: ColorFilter.mode(
                    //     isDark ? Colors.white : Colors.black,
                    //     BlendMode.srcIn,
                    //   ),
                    //   child: Image.asset(
                    //     'assets/logo.png',
                    //     width: 200,
                    //     height: 200,
                    //     fit: BoxFit.cover,
                    //   ),
                  ),
                ],
              ),
              const SizedBox(height: 60),
              // Wrap all rows in padding for consistent spacing
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Column(
                  children: [
                    // Sleep and Heart Rate Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment
                          .center, // Added for vertical alignment
                      children: [
                        HealthTile(
                          value: _sleepHours,
                          title: 'Sleep Hours',
                          color: AppColors.sleep, // Updated color
                          icon: Icons.bedtime,
                          unit: 'hrs',
                          isDark: isDark,
                        ),
                        HealthTile(
                          value: _heartRate,
                          title: 'Heart Rate',
                          color: AppColors.heartRate, // Updated color
                          icon: Icons.favorite,
                          unit: 'bpm',
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Blood Pressure and Blood Oxygen Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Blood Pressure Section
                        HealthTile(
                          value: _bloodPressure,
                          title: 'Blood Pressure',
                          color: AppColors.bloodPressure, // Updated color
                          icon: Icons.speed,
                          unit: 'mmHg',
                          isDark: isDark,
                        ),

                        // Blood Oxygen Section
                        HealthTile(
                          value: _bloodOxygen,
                          title: 'Blood Oxygen',
                          color: AppColors.bloodOxygen, // Updated color
                          icon: Icons.air,
                          unit: '%',
                          isDark: isDark,
                        ),
                      ],
                    ),

                    // Weight and Stress Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Weight Section
                        HealthTile(
                          value: _weight
                              .toStringAsFixed(1), // Format to 1 decimal place
                          title: 'Weight',
                          color: AppColors.weight, // Updated color
                          icon: Icons.monitor_weight,
                          unit: 'kg',
                          isDark: isDark,
                        ),

                        // Stress Section
                        HealthTile(
                          value: _stress,
                          title: 'Stress',
                          color: AppColors.stress, // Updated color
                          icon: Icons.psychology,
                          unit: '%',
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                'Statistics',
                style: AppFonts.h3.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
