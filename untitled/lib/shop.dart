import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

final at = FirebaseAuth.instance;
final fs = FirebaseFirestore.instance;
class Shop extends StatefulWidget {
  const Shop({Key? key}) : super(key: key);

  @override
  State<Shop> createState() => _ShopState();
}



  getData() async{
    //var r = await fs.collection('product').doc('BIrllKUQY8uvStzk7Zqh').get(); 하나의 컬렉션의 모든 문서 가져오깅
    //if(result.docs.isnotempty
    //var r = await fs.collection('product').add({'data': ''}); // delete()를 쓰면 삭제두 가눙, 업뎃은 update()
    //var r = await fs.collection('product').get(); //조건을 걸고자할땐 겟앞에 웨어넣기
    //for (var doc in r.docs){
     // print(doc['name']);
    var r = await at.createUserWithEmailAndPassword(email: 'kim@test.com', password: '1234567');
    print(r);
    }
class _ShopState extends State<Shop> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('샵페이지임!'),
    );
  }
}
