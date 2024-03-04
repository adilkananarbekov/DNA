import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

double rotationMultiplier = 1.0;
bool direction = true;

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.orange,
            title: Text(
              'DNA model from Adilkan',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 3; i < 23; ++i) ...[
                  RotationAnimation(i * 0.15),
                  SizedBox(
                    height: 15,
                  )
                ],
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        rotationMultiplier += 0.1;
                      },
                      child: Text('Increase Rotation Multiplier'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        rotationMultiplier -= 0.1;
                      },
                      child: Text('Decrease Rotation Multiplier'),
                    ),
                    SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        rotationMultiplier = 0;
                      },
                      child: Text('Pause'),
                    ),
                  ],
                ),
              ],
            ),
          )),
    );
  }
}

class RotationAnimation extends StatefulWidget {
  final double delay;

  RotationAnimation(this.delay);

  @override
  _RotationAnimationState createState() => _RotationAnimationState();
}

class _RotationAnimationState extends State<RotationAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    Future.delayed(Duration(milliseconds: (widget.delay * 1000).round()), () {
      if (mounted) {
        _controller.repeat();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (BuildContext context, Widget? child) {
        return Transform(
          alignment: FractionalOffset.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateY(
                _controller.value * rotationMultiplier * 3.14), // Rotate in Y
          child: child,
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          Container(
            width: 185,
            height: 8,
            color: Colors.green,
          ),
          Container(
            width: 185,
            height: 8,
            color: Colors.blue,
          ),
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
