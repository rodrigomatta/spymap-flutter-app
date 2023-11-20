import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Exceção personalizada para tratamento de erros de autenticação
class ExcecaoAutenticacao implements Exception {
  String mensagem;
  ExcecaoAutenticacao(this.mensagem);
}

// Serviço de autenticação que estende ChangeNotifier para notificar ouvintes sobre mudanças
class ServicoAutenticacao extends ChangeNotifier {
  // Instância do FirebaseAuth para gerenciar a autenticação
  FirebaseAuth _autenticacao = FirebaseAuth.instance;

  // Objeto representando o usuário autenticado
  User? usuario;

  // Variável indicando se o serviço está carregando
  bool estaCarregando = true;

  // Construtor do serviço, inicializa o serviço de autenticação e verifica o estado de autenticação
  ServicoAutenticacao() {
    _verificarAutenticacao();
  }

  // Método privado para verificar o estado de autenticação e notificar ouvintes
  _verificarAutenticacao() {
    _autenticacao.authStateChanges().listen((User? usuario) {
      this.usuario = (usuario == null) ? null : usuario;
      estaCarregando = false;
      notifyListeners();
    });
  }

  // Método privado para obter o usuário atual e notificar ouvintes
  _obterUsuario() {
    usuario = _autenticacao.currentUser;
    notifyListeners();
  }

  // Método para registrar um novo usuário com e-mail e senha
  registrar(String email, String senha) async {
    try {
      await _autenticacao.createUserWithEmailAndPassword(email: email, password: senha);
      _obterUsuario();
    } on FirebaseAuthException catch (e) {
      // Tratamento de exceções específicas
      if (e.code == 'weak-password') {
        throw ExcecaoAutenticacao("A senha fornecida é muito fraca");
      } else if (e.code == 'email-already-in-use') {
        throw ExcecaoAutenticacao('Este email já está cadastrado');
      }
    }
  }

  // Método para realizar o login com e-mail e senha
  realizarLogin(String email, String senha) async {
    try {
      await _autenticacao.signInWithEmailAndPassword(email: email, password: senha);
      _obterUsuario();
    } on FirebaseAuthException catch (e) {
      // Tratamento de exceções específicas
      if (e.code == 'user-not-found') {
        throw ExcecaoAutenticacao('Usuário não encontrado');
      } else if (e.code == 'wrong-password') {
        throw ExcecaoAutenticacao('Senha incorreta. Tente novamente');
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        throw ExcecaoAutenticacao('Login e/ou Senha Inválidos');
      } else {
        throw ExcecaoAutenticacao('Ocorreu um erro desconhecido: ${e.message}');
      }
    }
  }

  // Método para realizar o logout
  realizarLogout() async {
    await _autenticacao.signOut();
    _obterUsuario();
  }
}