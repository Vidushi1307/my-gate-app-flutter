import 'package:flutter/material.dart';

class SubmitButton extends StatelessWidget {
  const SubmitButton(
      {super.key, required this.submit_function, required this.button_text});
  final void Function() submit_function;
  final String button_text;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromRGBO(255, 143, 158, 1),
                      Color.fromRGBO(255, 188, 143, 1),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      spreadRadius: 4,
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    )
                  ]
                ),
              child: ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all(Colors.black),
                    shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                        ))),
                onPressed: () {
                  submit_function();
                },
                child: FittedBox(
                  fit: BoxFit.fill,
                  child: Container(
                      margin: const EdgeInsets.all(30),
                      height: 100,
                      width: MediaQuery.of(context).size.width / 1.5,
                      child: Text(
                        button_text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontSize: 50),
                      )
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
