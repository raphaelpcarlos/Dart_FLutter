import 'package:flutter/material.dart';
import 'package:background_app_bar/background_app_bar.dart';
import 'package:http/http.dart' as http;

import 'dart:async';
import 'dart:convert';

String getCidade;
String cidade;
var getTemperatura;
var getCondicao;
String imagem = "sol";
String msgErro = "";

void main() {
  runApp(
    MaterialApp(
      home: Home(),
      debugShowCheckedModeBanner: false,
    ),
  );
}

//-----Tela Home------
class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController cepController = TextEditingController();
  TextEditingController cidadeController = TextEditingController();

  void _reset() {
    cepController.text = "";
    msgErro = "";
    cidadeController.text = "";
  }

  //funcao retornar imagem
  alteraImagem() {
    if (getCondicao.toString() == "Drizzle") {}
    if (getCondicao.toString() == "Rain") {
      imagem = "raio";
    }
    if (getCondicao.toString() == "Clouds") {
      imagem = "nuvens";
    } else if (false) {
      print(imagem);
      imagem = "rj";
      print(imagem);
    }
  }

//Função para trocar tela
  trocarTela() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Clima()),
    );
  }

  //Buscar cidade
  Future getCep() async {
    String cep = cepController.text;
    String cidade = cidadeController.text;

    if (cep.isNotEmpty) {
      print("aqui");
      if (_validaCEP(cep) != null) {
        msgErro = _validaCEP(cep);
      } else {
        http.Response response =
            await http.get("https://viacep.com.br/ws/$cep/json/");
        var results = jsonDecode(response.body);

        //atribuir o resultado da busco da cidade
        getCidade = results['localidade'];

        //Chama a função para buscar a temperatura

        trocarTela();
        getTempo();
      }
    } else {
      getCidade = cidadeController.text;
      trocarTela();
      getTempo();
    }
  }

  //Buscar temperadura
  Future getTempo() async {
    http.Response response = await http.get(
        "http://api.openweathermap.org/data/2.5/weather?q=$getCidade&Brazil&appid=c32b7acd8f4eda6b1e72c85384b4e776");
    var results = jsonDecode(response.body);

    alteraImagem();

    setState(() {
      var temp = results['main']['temp'] - 273.15;
      getTemperatura = temp.toStringAsPrecision(2);
      getCondicao = results['weather'][0]['main'];
    });
  }

  //Tela buscar cidade
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Clima Tempo", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.green[200],
        actions: <Widget>[
          IconButton(icon: Icon(Icons.refresh), onPressed: _reset),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10.0),
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Icon(Icons.person, size: 120.0, color: Colors.green),
              //busca cep
              TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                    labelText: "Cep",
                    labelStyle: TextStyle(color: Colors.green)),
                maxLength: 8,
                controller: cepController,
              ),
              Text(
                msgErro,
                style: TextStyle(color: Colors.red, fontSize: 10.0),
              ),
              Divider(),
              //Busca cidade
              TextField(
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                    labelText: "Cidade",
                    labelStyle: TextStyle(color: Colors.green)),
                maxLength: 8,
                controller: cidadeController,
              ),
              Text(
                msgErro,
                style: TextStyle(color: Colors.red, fontSize: 10.0),
              ),
              RaisedButton(
                onPressed: getCep,
                child: Text(
                  "Busca CEP",
                  style: (TextStyle(color: Colors.white)),
                ),
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

////-----Buscar Clima------
class Clima extends StatefulWidget {
  @override
  _ClimaState createState() => _ClimaState();
}

//Tela buscar Clima
class _ClimaState extends State<Clima> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Clima Tempo"),
      ),
      body: Column(
        children: <Widget>[
          Image.asset("images/$imagem.jpg",
              fit: BoxFit.cover,
              height: MediaQuery.of(context).size.height / 6,
              width: MediaQuery.of(context).size.width),
          //Card Cidade
          //Card Cidade
          formCard(
              "Cidade",
              getCidade,
              Icon(
                Icons.location_city,
                size: 35.0,
                color: Colors.black,
              )),
          //Card Temperatura
          formCard(
              "Temperatura",
              getTemperatura.toString() + "º",
              Icon(
                Icons.thermostat_rounded,
                size: 35.0,
                color: Colors.black,
              )),

          //Card Clima
          formCard(
            "Clima",
            getCondicao.toString(),
            Icon(
              Icons.cloud_circle,
              size: 35.0,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

//Funcao para retornar o card
Card formCard(String text, String parametro, Icon icon) {
  return Card(
    child: ListTile(
        leading: icon,
        title: Text(text),
        subtitle: Text(parametro,
            style: TextStyle(fontSize: 30), textAlign: TextAlign.center)),
  );
}

//funcao para validar o cep
String _validaCEP(String value) {
  String patttern = r'(^[0-9]*$)';
  RegExp regExp = new RegExp(patttern);
  if (value.length == 0) {
    return "Informe o CEP";
  }
  if (value.length < 7) {
    return "Informe o CEP válido";
  } else if (!regExp.hasMatch(value)) {
    return "O CEP deve conter apenas números";
  }
  return null;
}
//https://api.flutter.dev/flutter/material/ListTile-class.html
