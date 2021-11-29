import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(title: 'Pokemon List'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int offset = 0;
  List<dynamic> PokemonData = [];
  List<dynamic> names = [];
  List<dynamic> urls = [];
  final RefreshController refreshController = RefreshController(
      initialRefresh: true);

  //
  // // function to get all data
  Future<bool> getData({bool isRefresh = false}) async {
    if (isRefresh) {
      offset = 0;
    }
    var _dio = Dio();
    await _dio
        .get('https://pokeapi.co/api/v2/pokemon?offset=$offset&limit=20')
        .then((response) {
      List results = response.data['results'];
      if (isRefresh) {
        PokemonData = results;
      } else {
        PokemonData.addAll(response.data['results']);
      }
      offset++;
      // PokemonData = results;
      List<String> name = PokemonData.map((e) => e["name"].toString()).toList();
      List<String> url = PokemonData.map((e) => e["url"].toString()).toList();
      print(names);
      setState(() {
        names = name;
        urls = url;
      });
    }).catchError((e) {});
    print('error');
    return true;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        onRefresh: () async {
          final result = await getData(isRefresh: true);
          if (result) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
        },
        onLoading: () async {
          final result = await getData();
          if (result) {
            refreshController.loadComplete();
          } else {
            refreshController.loadFailed();
          }
        },
        child: ListView.separated(
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                names[index],
                style: TextStyle(
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2
                )
                ,
              ),
              subtitle: Text(urls[index],
                  style: TextStyle(
                      color: Colors.blue,
                      letterSpacing: 2
                  )),
            );
          },
          separatorBuilder: (context, index) => Divider(),
          itemCount: PokemonData.length,
        ),
      ),
    );
  }
}