import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'ListView'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map data;
  List dogs = new List();
  ScrollController _scrollController = new ScrollController();

  Future getData() async {
    http.Response response =
        await http.get('https://dog.ceo/api/breeds/image/random/5');
    data = json.decode(response.body);
    List<String> newDogs = new List<String>.from(
        data['message']); // TODO: find a cleaner solution.
    setState(() {
      dogs.addAll(newDogs);
    });
  }

  Future _handleRefresh() async {
    dogs = new List();
    await getData();
    return null;
  }

  @override
  void initState() {
    super.initState();
    getData();

    _scrollController.addListener(() {
      bool atBottom = _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent;
      if (atBottom) {
        getData();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title), // From MyHomePage (widget)
        centerTitle: true,
        leading: Text((dogs.length.toString() ?? null) + ' Dogs'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.clear),
            onPressed: () {
              setState(() {
                dogs.clear();
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              _handleRefresh();
            },
          ),
        ],
      ),
      body: Center(
        child: ListView.builder(
          controller: _scrollController,
          itemCount: dogs.length == null
              ? 0
              : dogs.length, // Nice, ternary supported in flutter
          itemBuilder: (BuildContext context, int index) {
            return Card(
              child: Container(
                child: Image.network(dogs[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
