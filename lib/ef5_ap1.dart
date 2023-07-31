import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert' as convert;

const Color white = Color.fromARGB(255, 226, 233, 240);
const Color grey = Color.fromARGB(255, 97, 103, 122);

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: white,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (_) => const MyWidget(),
        '/imagem': (context) {
          final imagemSelecionada =
              ModalRoute.of(context)!.settings.arguments as Imagem;
          return ImagemPage(imagemSelecionada);
        }
      },
    );
  }
}

enum Estado { concluido, falhaAoCarregar }

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  final listaImagens = <Imagem>[];
  var estado = Estado.concluido;

  @override
  void initState() {
    getImages();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final conteudo = switch (estado) {
      Estado.concluido => ImagemListView(listaImagens),
      Estado.falhaAoCarregar => const ErrorScreen()
    };

    return Scaffold(
      appBar: AppBar(
        backgroundColor: grey,
        title: const Text('App Fotos'),
      ),
      body: conteudo,
    );
  }

  Future<void> getImages() async {
    try {
      final url = await http.get(Uri.parse(
          'https://raw.githubusercontent.com/LinceTech/dart-workshops/main/flutter-async/ap_1/request.json'));
      if (url.statusCode == 200) {
        final listaJson = convert.jsonDecode(url.body);
        for (final json in listaJson) {
          listaImagens.add(Imagem.fromJson(json));
        }
      } else {
        estado = Estado.falhaAoCarregar;
      }
    } catch (e) {
      estado = Estado.falhaAoCarregar;
      throw Exception('Não foi possivel carregar as fotos \n $e');
    } finally {
      setState(() => {});
    }
  }
}

class Imagem {
  Imagem.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        url = json['url'],
        thumbnailUrl = json['thumbnailUrl'];

  final int id;
  final String title;
  final String url;
  final String thumbnailUrl;
}

class ImagemListView extends StatelessWidget {
  const ImagemListView(this.listaImagem, {super.key});

  final List<Imagem> listaImagem;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.builder(
          itemCount: listaImagem.length,
          itemBuilder: (context, i) {
            return ImagemTile(listaImagem[i]);
          }),
    );
  }
}

class ImagemTile extends StatelessWidget {
  const ImagemTile(this.imagem, {super.key});

  final Imagem imagem;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(imagem.title),
      onTap: () {
        Navigator.of(context).pushNamed('/imagem', arguments: imagem);
      },
      contentPadding: const EdgeInsets.only(bottom: 15),
      leading: AspectRatio(
        aspectRatio: 1,
        child: Image.network(
          imagem.thumbnailUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, object, trace) {
            return Text("Erro carregando imagem: $object");
          },
        ),
      ),
    );
  }
}

class ImagemPage extends StatelessWidget {
  const ImagemPage(this.imagem, {super.key});

  final Imagem imagem;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: grey,
        title: Text(imagem.title),
      ),
      body: Center(
        child: Image.network(
          imagem.thumbnailUrl,
          fit: BoxFit.fill,
          width: double.infinity,
        ),
      ),
    );
  }
}

class ErrorScreen extends StatelessWidget {
  const ErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Não foi possível carregar os dados',
        style: TextStyle(
          color: Colors.black,
          fontSize: 15,
        ),
      ),
    );
  }
}
