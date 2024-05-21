import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:koreadictioanry/data.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<Map<String, dynamic>> dictionary = data;

  FlutterTts flutterTts = FlutterTts();
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeTts();
  }

  Future<void> initializeTts() async {
    await flutterTts.setLanguage("ko-KR");
    await flutterTts.setPitch(1.0);
    await flutterTts.setSpeechRate(0.5);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Korea Myanmar Dictionary"),
      ),
      body: Column(
        children: [
          /*
          TextFormField(
            onChanged: _onChange,
          ),

           */
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              // controller: _controller,
              onChanged: _onChange,
              decoration: InputDecoration(
                hintText: 'Search for a word',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
                contentPadding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              ),
            ),
          ),

          SizedBox(height: 8.0,),
          if(dictionary.isEmpty) Expanded(child: Center(child: Text("No Result Found"),)),
          if(dictionary.isNotEmpty) Text("${dictionary.length} results found!", style: TextStyle(color: Colors.grey),),
          Expanded(
              child: ListView.separated(
                  physics: BouncingScrollPhysics(),
                  itemBuilder: (context, index) => _card(dictionary[index]),
                  separatorBuilder: (index, context) => Divider(),
                  itemCount: dictionary.length
              )
          )
        ],
      ),
    );
  }

  void _onChange(String str){
    // filter and set state data
    // Find the map containing the specified Myanmar word
    var result = data.where((item) => item["myn_word"].toString().contains(str) ||  item["kr_word"].toString().contains(str)).toList();
    setState(() {
      dictionary = result;
    });
  }

  Widget _card(Map<String, dynamic> meaning){
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(child: Text(meaning['myn_word'] ?? "မင်္ဂလာပါ")),
          Expanded(child: Text(meaning['kr_word'] ?? "안녕하세요")),
          IconButton(onPressed: (){ speakText(meaning['kr_word'] ?? "안녕하세요"); }, icon: Icon(Icons.speaker))
        ],
      ),
    );
  }


  Future<void> speakText(String text) async {
    await flutterTts.speak(text);
  }
  
}
