import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spymap/paginas/paginaInicial.dart';
import 'package:spymap/paginas/telaLogin.dart';
import 'package:spymap/servicos/servicoAutenticacao.dart';

// Widget para verificar o estado de autenticação e direcionar para a tela apropriada
class VerificarAutenticacao extends StatefulWidget {
  const VerificarAutenticacao({super.key});

  @override
  State<VerificarAutenticacao> createState() => _VerificarAutenticacaoState();
}

class _VerificarAutenticacaoState extends State<VerificarAutenticacao> {
  @override
  Widget build(BuildContext context) {
    // Obtém a instância do serviço de autenticação utilizando o Provider
    ServicoAutenticacao servicoAutenticacao = Provider.of<ServicoAutenticacao>(context);

    // Verifica se o serviço está carregando
    if (servicoAutenticacao.estaCarregando)
      return exibindoCarregamento(); // Se estiver carregando, exibe um indicador de carregamento
    else if (servicoAutenticacao.usuario == null)
      return TelaLogin(); // Se não houver usuário autenticado, redireciona para a tela de login
    else
      return PaginaInicial(); // Se houver usuário autenticado, redireciona para a tela principal
  }
}

// Função que retorna um widget indicando que a aplicação está carregando
exibindoCarregamento() {
  return Scaffold(
    body: Center(
      child: CircularProgressIndicator(),
    ),
  );
}