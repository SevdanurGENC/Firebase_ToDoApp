import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class GorevEkle extends StatefulWidget {
  @override
  _GorevEkleState createState() => _GorevEkleState();
}

class _GorevEkleState extends State<GorevEkle> {
  //Verileri Kontrollerden Alıcı
  TextEditingController adAlici = TextEditingController();
  TextEditingController tarihAlici = TextEditingController();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  //Verileri Ekleme
  verileriEkle() async {
    FirebaseAuth yetki = FirebaseAuth.instance;
    final User mevcutKullanici = await yetki.currentUser;

    String uidTutucu = mevcutKullanici.uid;
    var zamanTutucu = DateTime.now();

    await fireStore
        .collection("Gorevler")
        .doc(uidTutucu)
        .collection("Gorevlerim")
        .doc(zamanTutucu.toString())
        .update({
      "ad": adAlici.text,
      "sonTarih": tarihAlici.text,
      "zaman": zamanTutucu.toString(),
      "tamZaman": zamanTutucu
    });

    Fluttertoast.showToast(msg: "Görev Başarıyla Eklendi");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Görev Ekle"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: adAlici,
              decoration: InputDecoration(
                labelText: "Görev Adı",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: tarihAlici,
              decoration: InputDecoration(
                labelText: "Son Tarihi",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            height: 70,
            width: double.infinity,
            child: ElevatedButton(
              child: Text(
                "Görevi Ekle",
                style: TextStyle(
                  fontSize: 24,
                ),
              ),
              onPressed: () {
                //Görev Firebase'e Eklenecek
                verileriEkle();
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}