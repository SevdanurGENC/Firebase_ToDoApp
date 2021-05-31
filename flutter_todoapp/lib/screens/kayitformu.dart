import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class KayitFormu extends StatefulWidget {
  @override
  _KayitFormuState createState() => _KayitFormuState();
}

//Kullanıcının Kayıtlı Olup Olmama Durumu (Global Değişken)
bool kayitDurumu = false;
//----Kayıt Parametreleri
String kullaniciAdi, email, parola;

class _KayitFormuState extends State<KayitFormu> {
  //Doğrulama Anahtarı
  var _dogrulamaAnahtari = GlobalKey<FormState>();
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _dogrulamaAnahtari,
      child: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: ListView(
          children: [
            Container(
              height: 150,
              child: Image.asset("images/todo.png"),
            ),
            if (!kayitDurumu)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  onChanged: (alinanAd) {
                    kullaniciAdi = alinanAd;
                  },
                  validator: (alinanAd) {
                    return alinanAd.isEmpty
                        ? "Kullanıcı Adı Boş Bırakılamaz!"
                        : null;
                  },
                  decoration: InputDecoration(
                    labelText: "Kullanıcı Adı:",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                keyboardType: TextInputType.emailAddress,
                onChanged: (alinanEmail) {
                  email = alinanEmail;
                },
                validator: (alinanEmail) {
                  return alinanEmail.contains("@") ? null : "Geçersiz Email!";
                },
                decoration: InputDecoration(
                  labelText: "Email Adresi:",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                obscureText: true,
                onChanged: (alinanParola) {
                  parola = alinanParola;
                },
                validator: (alinanParola) {
                  return alinanParola.length >= 6
                      ? null
                      : "Parolanız En Az 6 Karakter Olmalıdır!";
                },
                decoration: InputDecoration(
                  labelText: "Parola:",
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                height: 50,
                child: ElevatedButton(
                  child: kayitDurumu
                      ? Text(
                    "Giriş Yap",
                    style: TextStyle(fontSize: 24),
                  )
                      : Text(
                    "Kaydol",
                    style: TextStyle(fontSize: 24),
                  ),
                  onPressed: () {
                    kayitEkle();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red,
                    shadowColor: Colors.black,
                  ),
                ),
              ),
            ),
            Container(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    kayitDurumu = !kayitDurumu;
                  });
                },
                child: kayitDurumu
                    ? Text(
                  "Hesabım Yok",
                )
                    : Text(
                  "Zaten Hesabım Var",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Veri Doğrulanıp Kullanıcı Kaydı Yapılacak
  void kayitEkle() {
    if (_dogrulamaAnahtari.currentState.validate()) {
      //Firebase e Veri Ekleme İşlemi Yapılacak
      formuTestEt(kullaniciAdi, email, parola);
    }
  }
}

formuTestEt(String kullaniciAdi, String email, String parola) async {
  final yetki = FirebaseAuth.instance;
  UserCredential yetkiSonucu;
  //Kayıt Durumu True İse Giriş Yap
  if (kayitDurumu) {
    //Giriş Yapacak
    yetkiSonucu = await yetki.signInWithEmailAndPassword(
        email: email, password: parola);
  }
  //Kayıt Durumu False İse Kaydol
  else {
    //Kaydol
    yetkiSonucu = await yetki.createUserWithEmailAndPassword(
        email: email, password: parola);

    String uidTutucu = yetkiSonucu.user.uid;

    await   FirebaseFirestore.instance
        .collection("Kullanicilar")
        .doc(uidTutucu)
        .update({"kullaniciAdi": kullaniciAdi, "email": email});

  }
}