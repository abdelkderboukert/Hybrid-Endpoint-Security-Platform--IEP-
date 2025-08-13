import 'package:flutter/material.dart';

void main() {
  runApp(const MyWidget());
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        // appBar: AppBar(
        //   title: const Center(child: Text('Hello World')),
        //   backgroundColor: const Color.fromARGB(255, 37, 93, 190),
        // ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: Colors.cyanAccent,
                width: 150.0,
                height: 150.0,
                // margin: const EdgeInsets.all(20.0),
                alignment: Alignment.bottomRight,
                child: const Center(
                  child: Text('Hello World', style: TextStyle(fontSize: 24)),
                ),
              ),
              Container(
                color: const Color.fromARGB(255, 255, 147, 24),
                width: 50.0,
                height: 150.0,
                // margin: const EdgeInsets.all(20.0),
                alignment: Alignment.bottomRight,
                child: const Center(
                  child: Text('Hello World', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
