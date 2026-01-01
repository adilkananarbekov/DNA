import 'package:flutter/material.dart';
import 'dna_helix.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  double _speedMultiplier = 1.0;
  bool _isPaused = false;
  Color _primaryColor = Colors.cyan;
  Color _secondaryColor = Colors.purpleAccent;
  bool _isDarkTheme = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: AppBar(
          title: Text(
            '3D DNA Helix',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
              icon: Icon(_isDarkTheme ? Icons.light_mode : Icons.dark_mode),
              onPressed: () {
                setState(() {
                  _isDarkTheme = !_isDarkTheme;
                });
              },
            )
          ],
        ),
        extendBodyBehindAppBar: true,
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _isDarkTheme
                  ? [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)]
                  : [Colors.blue.shade50, Colors.white],
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: DNAHelix(
                    height: 600,
                    width: 300,
                    primaryColor: _primaryColor,
                    secondaryColor: _secondaryColor,
                    speedMultiplier: _speedMultiplier,
                    isPaused: _isPaused,
                  ),
                ),
              ),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDarkTheme ? Colors.black54 : Colors.white70,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Speed: ${_speedMultiplier.toStringAsFixed(1)}x'),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.remove_circle_outline),
                    onPressed: () {
                      setState(() {
                        _speedMultiplier = (_speedMultiplier - 0.1).clamp(0.0, 5.0);
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
                    onPressed: () {
                      setState(() {
                        _isPaused = !_isPaused;
                      });
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle_outline),
                    onPressed: () {
                      setState(() {
                        _speedMultiplier = (_speedMultiplier + 0.1).clamp(0.0, 5.0);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _colorButton(Colors.cyan, Colors.purpleAccent),
              _colorButton(Colors.green, Colors.orange),
              _colorButton(Colors.blue, Colors.red),
              _colorButton(Colors.pink, Colors.yellow),
            ],
          )
        ],
      ),
    );
  }

  Widget _colorButton(Color c1, Color c2) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _primaryColor = c1;
          _secondaryColor = c2;
        });
      },
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            colors: [c1, c2],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: Border.all(
            color: Colors.white,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
      ),
    );
  }
}
