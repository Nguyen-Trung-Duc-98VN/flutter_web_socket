import 'package:flutter/material.dart';
import 'package:flutter_web_socket/page/socket/socket.controller.dart';
import 'package:get/get.dart';

class SocketPage extends StatelessWidget {
  final SocketController _socketController = Get.put(SocketController());

  SocketPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 50.0),
        child: Column(
          children: [
            TextField(
                controller: _socketController.textController,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    isDense: true,
                    contentPadding: const EdgeInsets.all(15.0)),
                onEditingComplete: () {
                  _socketController.sendText();
                  FocusScope.of(context).unfocus();
                }),
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: _socketController.sendText,
              child: const Text('Send'),
            ),
            const SizedBox(height: 30.0),
            StreamBuilder(
              stream: _socketController.socket.stream,
              builder: (context, snapshot) {
                return Text(
                  snapshot.hasData ? '${snapshot.data}' : "No Data",
                  style: const TextStyle(fontSize: 20.0),
                );
              },
            )
          ],
        ),
      ),
    );
  }
}
