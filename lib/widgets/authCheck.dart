import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spymap/paginas/homePage.dart';
import 'package:spymap/paginas/telaLogin.dart';
import 'package:spymap/servicos/authService.dart';

// Widget para verificar o estado de autenticação e direcionar para a tela apropriada
class AuthCheck extends StatefulWidget {
  const AuthCheck({super.key});

  @override
  State<AuthCheck> createState() => _AuthCheckState();
}

class _AuthCheckState extends State<AuthCheck> {
  @override
  Widget build(BuildContext context) {
    // Obtém a instância do serviço de autenticação utilizando o Provider
    AuthService auth = Provider.of<AuthService>(context);

    // Verifica se o serviço está carregando
    if (auth.isLoading)
      return loading(); // Se estiver carregando, exibe um indicador de carregamento
    else if (auth.usuario == null)
      return TelaLogin(); // Se não houver usuário autenticado, redireciona para a tela de login
    else
      return HomePage(); // Se houver usuário autenticado, redireciona para a tela principal
  }
}

// Função que retorna um widget indicando que a aplicação está carregando
loading() {
  return Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}