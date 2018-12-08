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
      title: 'Doggo List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'An Doggo List'),
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
  bool isPerformingRequest = false;

  Future getData() async {
    if (!isPerformingRequest) {
      isPerformingRequest = true;
      http.Response response =
          await http.get('https://dog.ceo/api/breeds/image/random/5');
      data = json.decode(response.body);
      List<String> newDogs = new List<String>.from(
          data['message']); // TODO: find a cleaner solution.
      setState(() {
        dogs.addAll(newDogs);
        isPerformingRequest = false;
      });
    }
  }

  Future _handleRefresh() async {
    dogs =
        new List(); // TODO: Is this the best way to go? Is there garbage collection?
    await getData();
    return null;
  }

  void _handleClearList() {
    setState(() {
      dogs.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    getData();

    _scrollController.addListener(() {
      bool _atBottom = _scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent;
      bool _hasValues = dogs != null && dogs.length > 0;
      if (_atBottom && _hasValues) {
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
        leading: IconButton(
          icon: Icon(Icons.clear),
          onPressed: _handleClearList,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _handleRefresh,
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
            if (index == dogs.length - 1) {
              // Hrm, this is interesting.
              return _buildProgressIndicator();
            } else {
              return Card(
                child: Container(
                  child: Image.network(dogs[index]),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return new Padding(
      padding: const EdgeInsets.all(8.0), // 8px padding
      child: Center(
        child: Opacity(
          // opacity: isPerformingRequest ? 1.0 : 0.0,
          opacity: 1,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
