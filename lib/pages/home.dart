import 'package:demo/providers/valentine_provider.dart';
import 'package:demo/widgets/healthTile.dart';
import 'package:flutter/material.dart';
import 'package:wave/config.dart';
import 'package:wave/wave.dart';
import 'package:demo/constants/colors.dart';
import 'package:demo/constants/fonts.dart';
import 'package:provider/provider.dart'; // Add this import
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rxdart/rxdart.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
    _initializeDataIfEmpty();
  }

  Stream<Map<String, dynamic>> _getMetricsStream() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.value({});

    return _firestore
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .flatMap((userDoc) {
      if (!userDoc.exists || !userDoc.data()!.containsKey('device')) {
        return Stream.value({});
      }

      final deviceData = userDoc.data()!['device'] as Map<String, dynamic>;

      // Create a stream for device document
      return _firestore
          .collection('devices')
          .doc('device_type')
          .collection(deviceData['type'])
          .doc(deviceData['id'])
          .snapshots()
          .map((deviceDoc) {
        if (!deviceDoc.exists) return {};
        print('Device data updated: ${deviceDoc.data()}');
        return deviceDoc.data() ?? {};
      });
    });
  }

  Future<void> _initializeDataIfEmpty() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) {
        await _firestore.collection('users').doc(user.uid).set({
          'healthMetrics': {
            'sleepHours': 8,
            'heartRate': 75,
            'bloodPressure': 120,
            'bloodOxygen': 98,
            'weight': 70.0,
            'stress': 50,
          }
        }, SetOptions(merge: true));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isValentine = context.watch<ValentineProvider>().isValentineMode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Health Monitoring',
          style: TextStyle(
            color: isValentine ? Colors.pink[400] : null,
          ),
        ),
      ),
      backgroundColor: isValentine
          ? Colors.pink[50]
          : (isDark
              ? const Color.fromARGB(105, 15, 15, 15)
              : const Color.fromARGB(100, 245, 245, 245)),
      body: Stack(
        children: [
          StreamBuilder<Map<String, dynamic>>(
            stream: _getMetricsStream(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final metrics = snapshot.data ?? {};

              // Parse metrics with safe conversion
              final sleepHours =
                  int.tryParse(metrics['sleepHours']?.toString() ?? '0') ?? 0;
              final heartRate =
                  int.tryParse(metrics['heartRate']?.toString() ?? '0') ?? 0;
              final bloodPressure =
                  int.tryParse(metrics['bloodPressure']?.toString() ?? '0') ??
                      0;
              final bloodOxygen =
                  int.tryParse(metrics['bloodOxygen']?.toString() ?? '0') ?? 0;
              final weight =
                  double.tryParse(metrics['weight']?.toString() ?? '0.0') ??
                      0.0;
              final stress =
                  int.tryParse(metrics['stress']?.toString() ?? '0') ?? 0;

              return SingleChildScrollView(
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
                                blur:
                                    const MaskFilter.blur(BlurStyle.solid, 10),
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
                                  value: sleepHours,
                                  title: 'Sleep Hours',
                                  color: AppColors.sleep, // Updated color
                                  icon: Icons.bedtime,
                                  unit: 'hrs',
                                  isDark: isDark,
                                ),
                                HealthTile(
                                  value: heartRate,
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
                                  value: bloodPressure,
                                  title: 'Blood Pressure',
                                  color:
                                      AppColors.bloodPressure, // Updated color
                                  icon: Icons.speed,
                                  unit: 'mmHg',
                                  isDark: isDark,
                                ),

                                // Blood Oxygen Section
                                HealthTile(
                                  value: bloodOxygen,
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
                                  value: weight.toStringAsFixed(
                                      1), // Format to 1 decimal place
                                  title: 'Weight',
                                  color: AppColors.weight, // Updated color
                                  icon: Icons.monitor_weight,
                                  unit: 'kg',
                                  isDark: isDark,
                                ),

                                // Stress Section
                                HealthTile(
                                  value: stress,
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
              );
            },
          ),
          if (isValentine) _buildValentineOverlay(),
        ],
      ),
    );
  }

  Widget _buildValentineOverlay() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.pink[100]?.withOpacity(0.8),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.pink.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite, color: Colors.red[400], size: 16),
            const SizedBox(width: 4),
            Text(
              "Happy Valentine's Day!",
              style: TextStyle(
                color: Colors.red[400],
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
