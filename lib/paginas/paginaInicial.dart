import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spymap/paginas/paginaConfiguracao.dart';
import 'package:spymap/paginas/paginaLocalizacao.dart';
import 'package:spymap/paginas/paginaMapa.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Página inicial da aplicação
class PaginaInicial extends StatefulWidget {
  const PaginaInicial({super.key});

  @override
  State<PaginaInicial> createState() => _PaginaInicialState();
}

class _PaginaInicialState extends State<PaginaInicial> {
  // Variáveis de estado
  int indiceSelecionado = 0;
  String? idUsuario;
  Color corAppBar = Colors.green;
  Color? corBarraNavegacaoInferior = Colors.green[800];
  late List<Widget> telas;
  late StreamSubscription<QuerySnapshot> _inscricao;
  ValueNotifier<String> caminhoIconeNotificador = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();

    // Inicializa as telas e a inscrição no Firestore
    telas = [
      PaginaLocalizacao(),
      Container(), // Espaço reservado para a PaginaMapa
      paginaConfiguracao(
        alterarCor: alterarCor,
        corTema: corAppBar, // Passe a cor do tema
      )
    ];
    _inscricao = FirebaseFirestore.instance.collection(FirebaseAuth.instance.currentUser!.uid).snapshots().listen(_atualizarEstado);

    // Carrega o tema selecionado do Firestore
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('temas').doc(uid).get().then((doc) {
      if (doc.exists && doc.data()!['tema'] != null) {
        alterarCor(doc.data()!['tema']);
      }
    });
  }

  @override
  void dispose() {
    // Cancela a inscrição no Firestore ao sair da página
    _inscricao.cancel();
    super.dispose();
  }

  void _atualizarEstado(QuerySnapshot snapshot) {
    if (snapshot.docs.isNotEmpty) {
      String? novoIdUsuario = snapshot.docs.first.id;

      // Verifica se o documento adicionado é o documento 'temas'
      if (novoIdUsuario == 'temas') {
        return;
      }

      // Verifica se o idUsuario mudou antes de criar uma nova PaginaMapa
      if (novoIdUsuario != idUsuario) {
        setState(() {
          idUsuario = novoIdUsuario;
          telas[1] = PaginaMapa(idUsuario!, caminhoIconeNotificador); // Substitui o espaço reservado pela PaginaMapa real
        });
      }
    }
  }

  void mudarIcone(String caminho, int largura) {
    setState(() {
      caminhoIconeNotificador.value = caminho;
    });
  }

  void alterarCor(String cor) {
    setState(() {
      switch (cor) {
        case 'Amarelo':
          corAppBar = Colors.yellow;
          corBarraNavegacaoInferior = Colors.yellow[500] ?? Colors.yellow;
          break;
        case 'Roxo':
          corAppBar = Colors.purple;
          corBarraNavegacaoInferior = Colors.purple[800] ?? Colors.purple;
          break;
        case 'Preto':
          corAppBar = Colors.black;
          corBarraNavegacaoInferior = Colors.black;
          break;
        default:
          corAppBar = Colors.green;
          corBarraNavegacaoInferior = Colors.green[800] ?? Colors.green;
      }
    });

    // Salva o tema selecionado no Firestore
    String uid = FirebaseAuth.instance.currentUser!.uid;
    FirebaseFirestore.instance.collection('temas').doc(uid).set({
      'tema': cor,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra superior
      appBar: AppBar(
        title: Text('SpyMap Tracker'),
        centerTitle: true, // Centraliza o título
        backgroundColor: corAppBar, // Altera a cor de fundo para verde
      ),
      
      // Corpo da página
      body: telas[indiceSelecionado],

      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        onTap: (indice) {
          setState(() {
            indiceSelecionado = indice;
          });
        },
        unselectedItemColor: Colors.white70,
        backgroundColor: corBarraNavegacaoInferior,
        currentIndex: indiceSelecionado,
        selectedItemColor: Colors.amber[800],

        // Itens da barra de navegação
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Início',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Mapas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_applications),
            label: 'Configurações',
          ),
        ],
      ),
    );
  }
}