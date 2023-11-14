import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spymap/servicos/authService.dart';

// Tela de Login é um StatefulWidget
class TelaLogin extends StatefulWidget {
  const TelaLogin({super.key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

// Estado da Tela de Login
class _TelaLoginState extends State<TelaLogin> with TickerProviderStateMixin {
  // Chave global para o formulário
  final formKey = GlobalKey<FormState>();
  // Controladores para os campos de email e senha
  final email = TextEditingController();
  final senha = TextEditingController();

  // Variáveis para controlar o estado da tela
  bool isLogin = true;
  late String titulo;
  late String actionButton;
  late String toggleButton;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    setFormAction(true);
  }

  // Método para configurar as variáveis de acordo com o modo de ação (Login ou Registro)
  setFormAction(bool acao) {
    setState(() {
      isLogin = acao;
      if (isLogin) {
        titulo = "Bem Vindo ao SpyMap";
        actionButton = "Login";
        toggleButton = "Ainda não tem conta? Cadastre-se agora";
      } else {
        titulo = "Crie sua conta";
        actionButton = "Cadastrar";
        toggleButton = "Voltar ao Login.";
      }
    });
  }

  // Método para realizar o login
  login() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().login(email.text, senha.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  // Método para realizar o registro
  registrar() async {
    setState(() => loading = true);
    try {
      await context.read<AuthService>().registrar(email.text, senha.text);
    } on AuthException catch (e) {
      setState(() => loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  // Método de construção da interface do usuário
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(146, 105, 29, 236), 
      body: AnimatedBackground(
        behaviour: RandomParticleBehaviour(
          options: ParticleOptions(
            spawnMinSpeed: 50.0,
            spawnMaxSpeed: 60.0,
            particleCount: 68,
            minOpacity: 0.4,
            spawnOpacity: 0.4,
            baseColor: Colors.black,
            image: Image(image: AssetImage('images/spy.png')),
          ),
        ),
        vsync: this,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(top: 100),
              child: Form(
                key: formKey,
                child: Column(
                  children: [
                    // Título da tela
                    Text(
                      titulo,
                      style: TextStyle(
                        color: Colors.amber,
                        fontSize: 35,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.5,
                      ),
                    ),
                    // Campo de entrada de email
                    Padding(
                      padding: EdgeInsets.all(25),
                      child: TextFormField(
                        controller: email,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.amber),
                        ),
                        style: TextStyle(color: Colors.amber),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regex = RegExp(pattern);
                          if (!regex.hasMatch(value!))
                            return 'Insira um email válido';
                          else
                            return null;
                        },
                      ),
                    ),
                    // Campo de entrada de senha
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 25),
                      child: TextFormField(
                        controller: senha,
                        obscureText: true,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.amber),
                          ),
                          labelText: 'Senha',
                          labelStyle: TextStyle(color: Colors.amber),
                        ),
                        style: TextStyle(color: Colors.amber),
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'informe sua senha!';
                          } else if (value.length < 8) {
                            return 'Sua senha deve conter no mínimo 8 caracteres';
                          }
                          return null;
                        },
                      ),
                    ),
                    // Botão para realizar a ação (Login ou Registro)
                    Padding(
                      padding: EdgeInsets.all(25),
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            if (isLogin) {
                              login();
                            } else {
                              registrar();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: (loading)
                              ? [
                                  Padding(
                                    padding: EdgeInsets.all(16),
                                    child: SizedBox(
                                      width: 25,
                                      height: 25,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                      ),
                                    ),
                                  )
                                ]
                              : [
                                  Icon(Icons.check),
                                  Padding(
                                    padding: EdgeInsets.all(17),
                                    child: Text(
                                      actionButton,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  )
                                ],
                        ),
                      ),
                    ),
                    // Botão para alternar entre Login e Registro
                    TextButton(
                      onPressed: () => setFormAction(!isLogin),
                      child: Text(toggleButton),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
