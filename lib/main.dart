import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

void main() => runApp(MyHomePage());

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // The client and host sides of a channel are connected through a
  // channel name passed in the channel constructor.
  // All channel names used in a single app must be unique;
  // prefix the channel name with a unique ‘domain prefix’,
  // for example: samples.flutter.dev/battery.

  final LocalAuthentication auth = LocalAuthentication();
  bool _canCheckBiometrics;
  List<BiometricType> _availableBiometrics;
  String _authorized = 'Not Authorized';

  Future<void> _checkBiometrics() async {
    bool canCheckBiometrics;
    try {
      canCheckBiometrics = await auth.canCheckBiometrics;
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _canCheckBiometrics = canCheckBiometrics;
    });
  }

  Future<void> _getAvailableBiometrics() async {
    List<BiometricType> availableBiometrics;
    try {
      availableBiometrics = await auth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      print(e);
    }
    if (!mounted) return;

    setState(() {
      _availableBiometrics = availableBiometrics;
    });
  }

  Future<void> _authenticate() async {
    bool authenticated = false;
    try {
      authenticated = await auth.authenticateWithBiometrics(
          localizedReason: 'Scan you fingerprint to authenticate',
          useErrorDialogs: true,
          stickyAuth: true);
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      _authorized = authenticated ? 'Authorized' : 'Not Authorized';
    });
  }

  static const platform = const MethodChannel('samples.flutter.dev/battery');

  // Get battery level
  String _batteryLevel = 'Unknown battery level';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final int result = await platform.invokeMethod('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Text('Can check biometrics: $_canCheckBiometrics\n'),
            RaisedButton(
              child: const Text('Check biometrics'),
              onPressed: _checkBiometrics,
            ),
            Text('Available biometrics: $_availableBiometrics\n'),
            RaisedButton(
              child: const Text('Get available biometrics'),
              onPressed: _getAvailableBiometrics,
            ),
            Text('Current State: $_authorized\n'),
            RaisedButton(
              child: const Text('Authenticate'),
              onPressed: _authenticate,
            )
          ],
        ),
      ),
    ));
    // Platform integration example

    // ################

    // return Material(
    //   child: Center(
    //     child: Column(
    //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //       children: [
    //         RaisedButton(
    //           child: Text('Get Battery Level'),
    //           onPressed: _getBatteryLevel,
    //         ),
    //         Text(_batteryLevel),
    //       ],
    //     ),
    //   ),
    // );
  }
}

