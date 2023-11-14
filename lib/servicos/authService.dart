import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// Exceção personalizada para tratamento de erros de autenticação
class AuthException implements Exception {
  String message;
  AuthException(this.message);
}

// Serviço de autenticação que estende ChangeNotifier para notificar ouvintes sobre mudanças
class AuthService extends ChangeNotifier {
  // Instância do FirebaseAuth para gerenciar a autenticação
  FirebaseAuth _auth = FirebaseAuth.instance;

  // Objeto representando o usuário autenticado
  User? usuario;

  // Variável indicando se o serviço está carregando
  bool isLoading = true;

  // Construtor do serviço, inicializa o serviço de autenticação e verifica o estado de autenticação
  AuthService() {
    _authCheck();
  }

  // Método privado para verificar o estado de autenticação e notificar ouvintes
  _authCheck() {
    _auth.authStateChanges().listen((User? user) {
      usuario = (user == null) ? null : user;
      isLoading = false;
      notifyListeners();
    });
  }

  // Método privado para obter o usuário atual e notificar ouvintes
  _getUser() {
    usuario = _auth.currentUser;
    notifyListeners();
  }

  // Método para registrar um novo usuário com e-mail e senha
  registrar(String email, String senha) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      // Tratamento de exceções específicas
      if (e.code == 'weak-password') {
        throw AuthException("A senha fornecida é muito fraca");
      } else if (e.code == 'email-already-in-use') {
        throw AuthException('Este email já está cadastrado');
      }
    }
  }

  // Método para realizar o login com e-mail e senha
  login(String email, String senha) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: senha);
      _getUser();
    } on FirebaseAuthException catch (e) {
      // Tratamento de exceções específicas
      if (e.code == 'user-not-found') {
        throw AuthException('Usuário não encontrado');
      } else if (e.code == 'wrong-password') {
        throw AuthException('Senha incorreta. Tente novamente');
      } else if (e.code == 'INVALID_LOGIN_CREDENTIALS') {
        throw AuthException('Login e/ou Senha Inválidos');
      } else {
        throw AuthException('An unknown error occurred: ${e.message}');
      }
    }
  }

  // Método para realizar o logout
  logout() async {
    await _auth.signOut();
    _getUser();
  }
}