import 'package:flutter/material.dart';
import 'package:koreadictioanry/data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Korea Myanmar Dictionary"),
      ),
      body: Column(
        children: [
          TextFormField(),
          Expanded(
              child: ListView.separated(
                  itemBuilder: (context, index) => _card(data[index]),
                  separatorBuilder: (index, context) => Divider(),
                  itemCount: data.length
              )
          )
        ],
      ),
    );
  }

  Widget _card(Map<String, dynamic> meaning){
    return Column(
      children: [
        Text(meaning['myn_word'] ?? ""),
        Text(meaning['kr_word'] ?? "")
      ],
    );
  }
}
