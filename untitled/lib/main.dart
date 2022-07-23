import 'package:flutter/material.dart';
import 'package:untitled/shop.dart';
import './style.dart' as style; //변수명이 겹친다면
import 'package:http/http.dart' as http;
import 'dart:convert'; //제이슨 쓸때 필요바링
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notification.dart';

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
  );

  runApp(MultiProvider(
    //ChangeNotifierProvider 1개일때
    providers: [
      ChangeNotifierProvider(create: (c) => Store1()),
      ChangeNotifierProvider(create: (c) => Store2()),
    ],
    child: MaterialApp(theme: style.theme, home: MyApp()),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  var data = [];
  addData(a) {
    setState(() {
      data.add(a);
    });
  }

  var tab = 0;
  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/data.json'));
    if (result.statusCode == 200) {
    } else {}
    var result2 = jsonDecode(result.body);
    setState(() {
      data = result2;
    });
    print(data);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initNotification(context);
    getData();
    saveData();
  }

  var userImage;

  saveData() async {
    //메모리 사용 방법
    var storage = await SharedPreferences.getInstance(); //저장공간을 쓰겠다는 문법
    var map = {'age': 20};
    storage.setString('map', jsonEncode(map)); //저장
    var re = storage.getString('map') ?? '없슈'; //사용
    print(jsonDecode(re)['age']); //맵자료 꺼내쓰기
    // storage.remove('name'); //자료 삭제

    // storage.setString('name', 'john'); //키 벨류 같은 느낌
    // var result = storage.getString('name');
    // print(result);
  }

  var userContent;
  setUserContent(a) {
    setState(() {
      userContent = a;
    });
  }

  addMyData() {
    var myData = {
      'id': data.length,
      'image': userImage,
      'likes': 5,
      'date': 'July 25',
      'content': userContent,
      'liked': false,
      'user': 'John Kim'
    };
    setState(() {
      data.insert(0, myData);
    });
  }

  var a = const TextStyle(); //이런식으로 스타일은 사용하는게 편리쓰
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(child: Text('+'),onPressed: (){
        showNotification2();
      },),
      appBar: AppBar(
        title: Text(
          'Instagram',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          IconButton(
              onPressed: () async {
                var picker = ImagePicker();
                var image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    userImage = File(image.path);
                  });
                }

                Navigator.push(context, MaterialPageRoute(builder: (c) {
                  return Upload(
                      img: userImage,
                      setUserContent: setUserContent,
                      addMyData: addMyData);
                }));
              },
              icon: Icon(Icons.add_box_outlined))
        ],
      ),
      body: Theme(
          //테마로 감싸서 여기에있는 위젯은 전부 이 테마적용)
          data: ThemeData(
              textTheme: TextTheme(bodyText2: TextStyle(color: Colors.black))),
          //Text('ㅎㅇ',style: Theme.of(context).textTheme.bodyText2) // context에서 가장 가까운 Theme 찾아 적용
          child: Container(
            child: [
              Home(data: data, add: addData),
              Shop(),
            ][tab], //if문보다 직관적임
          )),
      bottomNavigationBar: BottomNavigationBar(
        showSelectedLabels: false,
        showUnselectedLabels: false,
        onTap: (i) {
          setState(() {
            print(i);
            tab = i;
          });
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined), label: '')
        ],
      ),
    );
  }
}

class Home extends StatefulWidget {
  const Home({Key? key, this.data, this.add}) : super(key: key);
  final data;
  final add;

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  var scroll = ScrollController();
  getMore() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/more1.json'));
    var result2 = jsonDecode(result.body);
    widget.add(result2);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    scroll.addListener(() {
      if (scroll.position.pixels == scroll.position.maxScrollExtent) {
        getMore();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.data.isNotEmpty) {
      return ListView.builder(
          itemCount: widget.data.length,
          controller: scroll,
          itemBuilder: (c, i) {
            return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  widget.data[i]['image'].runtimeType == String
                      ? Image.network(widget.data[i]['image'])
                      : Image.file(widget.data[i]['image']),
                  GestureDetector(
                    child: Text('좋ㅇㅏ요 ${widget.data[i]['likes']}'),
                    onTap: () {
                      Navigator.push(
                          context,
                          PageRouteBuilder(
                              pageBuilder: (c, a1, a2) => Profile(),
                              transitionsBuilder: (c, a1, a2, child) =>
                                  FadeTransition(opacity: a1, child: child),
                              transitionDuration:
                                  Duration(milliseconds: 1500)));
                    },
                  ),
                  Text('내이루뭉 ${widget.data[i]['user']}'),
                  Text(''),
                  Text(widget.data[i]['content']),
                ]);
          });
    } else {
      return Text('로딩중');
    }
  }
}

class Upload extends StatelessWidget {
  const Upload({Key? key, this.img, this.setUserContent, this.addMyData})
      : super(key: key);
  final img;
  final setUserContent;
  final addMyData;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                addMyData();
              },
              icon: Icon(Icons.send)),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.file(img),
          Text('이미지업로드화면'),
          TextField(
            onChanged: (text) {
              setUserContent(text);
            },
          ),
          IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(Icons.close))
        ],
      ),
    );
  }
}

class Store1 extends ChangeNotifier {
  var profileImage = [];

  getData() async {
    var result = await http
        .get(Uri.parse('https://codingapple1.github.io/app/profile.json'));
    var result2 = jsonDecode(result.body);
    profileImage = result2;
    notifyListeners();
    print(profileImage);
  }

  var friend = false;
  var follower = 0;
  addFollower() {
    if (friend == false) {
      follower++;
      friend = true;
    } else {
      follower--;
      friend = false;
    }
    notifyListeners();
  }
}

class Profile extends StatelessWidget {
  const Profile({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.watch<Store2>().name,
            style: TextStyle(color: Colors.black)),
      ),
      body: CustomScrollView(
        slivers: [ //슬리버는 항상 슬리버로 시작하는 위젯을 넣어야함
          SliverToBoxAdapter(
            child: ProfileHeader(),
          ),
          SliverGrid(
            delegate: SliverChildBuilderDelegate((context, index) => Image.network(context.watch<Store1>().profileImage[index]),childCount: 3),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
          ),
          //슬리버앱바써서 옷상세정보 나오는 부분 만들어주자

        ],
      ),
    );
  }
}

class Store2 extends ChangeNotifier {
  var name = 'john kim';
}

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('팔로워 ${context.watch<Store1>().follower}명'),
        ElevatedButton(
            onPressed: () {
              context.read<Store1>().addFollower();
            },
            child: Text('follow')),
        ElevatedButton(
            onPressed: () {
              context.read<Store1>().getData();
            },
            child: Text('사진가져오깅'))
      ],
    );
  }
}
