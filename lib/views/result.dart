import 'package:athena/views/home.dart';
import 'package:flutter/material.dart';

class Results extends StatefulWidget {
  final int correct, incorrect, total;
  Results({this.correct, this.incorrect, this.total});
  @override
  _ResultsState createState() => _ResultsState();
}

class _ResultsState extends State<Results> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("${widget.correct}/${widget.total}"),
            SizedBox(height: 0),
            Text(
              "You answered ${widget.correct} answer correctly and ${widget.incorrect} answer incorrectly",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            SizedBox(
              height: 24,
            ),
            GestureDetector(
              onTap: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => Home()));
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                width: MediaQuery.of(context).size.width / 2 - 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  "Go to home",
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}
