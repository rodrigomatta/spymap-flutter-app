import 'package:firebase_core/firebase_core.dart'; // Importa o pacote Firebase Core para inicializar o Firebase
import 'package:flutter/material.dart'; // Importa o pacote Flutter Material para usar widgets do Material Design
import 'package:provider/provider.dart'; // Importa o pacote Provider para gerenciamento de estado
import 'package:spymap/paginas/paginaCalculadoraFake.dart';
import 'package:spymap/servicos/servicoAutenticacao.dart'; // Importa o serviço de autenticação do aplicativo
//import 'package:spymap/widgets/authCheck.dart'; // Importa o widget de verificação de autenticação

void main() async { // Função principal que é o ponto de entrada do aplicativo
  WidgetsFlutterBinding.ensureInitialized(); // Garante que o binding do widget esteja inicializado
  await Firebase.initializeApp(); // Inicializa o Firebase

  runApp( // Inicia o aplicativo
    MultiProvider( // Fornece múltiplos provedores para o aplicativo
      providers: [
        ChangeNotifierProvider(create: (context) => ServicoAutenticacao()), // Fornece o serviço de autenticação para o aplicativo
      ],
      child: MaterialApp( // Cria o aplicativo com Material Design
        home: PaginaCalculadoraFalsa(key: UniqueKey()), // Define AuthCheck como a primeira tela do aplicativo
        debugShowCheckedModeBanner: false, // Remove o banner de modo de depuração
      )
    )
  );
}