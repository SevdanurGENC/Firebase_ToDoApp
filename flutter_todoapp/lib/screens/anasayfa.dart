import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_todoapp/screens/gorevekle.dart';

class AnaSayfa extends StatefulWidget {
  @override
  _AnaSayfaState createState() => _AnaSayfaState();
}

class _AnaSayfaState extends State<AnaSayfa> {
  //--Mevcut Kullanici uidsi
  String mevcutkullaniciUidTutucu;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  //İlk Sayfa Açıldığında
  @override
  void initState() {
    // TODO: implement initState
    mevcutKullaniciUidsiAl();
    super.initState();
  }

  mevcutKullaniciUidsiAl() async {
    //Veritabanından Uid Al
    FirebaseAuth yetki = FirebaseAuth.instance;
    final User mevcutKullanici = await yetki.currentUser;

    setState(() {
      mevcutkullaniciUidTutucu = mevcutKullanici.uid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Yapılacaklar"),
        actions: [
          IconButton(icon: Icon(Icons.exit_to_app), onPressed: () async {
            await FirebaseAuth.instance.signOut();
          }),
        ],
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder(
          stream: fireStore
              .collection("Gorevler")
              .doc(mevcutkullaniciUidTutucu)
              .collection("Gorevlerim")
              .snapshots(),
          builder: (context, veriTabanindanGelenVeriler) {
            if (veriTabanindanGelenVeriler.connectionState ==
                ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              final alinanVeri = veriTabanindanGelenVeriler.data.docs;
              return ListView.builder(
                itemCount: alinanVeri.length,
                itemBuilder: (context, index) {
                  //Eklenme Zamanı Tutucu
                  var eklenmeZamani =
                  (alinanVeri[index]["tamZaman"] as Timestamp).toDate();
                  return Container(
                    margin: EdgeInsets.fromLTRB(10, 5, 10, 3),
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                alinanVeri[index]["ad"],
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height: 7,
                              ),
                              Text(
                                DateFormat.yMd()
                                    .add_jm()
                                    .format(eklenmeZamani)
                                    .toString(),
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                alinanVeri[index]["sonTarih"],
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () async {
                                await fireStore
                                    .collection("Gorevler")
                                    .doc(mevcutkullaniciUidTutucu)
                                    .collection("Gorevlerim")
                                    .doc(
                                  alinanVeri[index]["zaman"],
                                )
                                    .delete();
                              })
                        ],
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
        onPressed: () {
          //Görev Ekleme Sayfasına Gitsin
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => GorevEkle()),
          );
        },
      ),
    );
  }
}