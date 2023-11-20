import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spymap/servicos/servicoAutenticacao.dart';

// Tela de Login é um StatefulWidget
class TelaLogin extends StatefulWidget {
  const TelaLogin({Key? key});

  @override
  State<TelaLogin> createState() => _TelaLoginState();
}

// Estado da Tela de Login
class _TelaLoginState extends State<TelaLogin> with TickerProviderStateMixin {
  // Chave global para o formulário
  final formKey = GlobalKey<FormState>();
  // Controladores para os campos de email e senha
  final controladorEmail = TextEditingController();
  final controladorSenha = TextEditingController();

  // Variáveis para controlar o estado da tela
  bool estaFazendoLogin = true;
  late String titulo;
  late String rotuloBotaoAcao;
  late String rotuloBotaoAlternar;
  bool carregando = false;

  @override
  void initState() {
    super.initState();
    configurarAcaoFormulario(true);
  }

  // Método para configurar as variáveis de acordo com o modo de ação (Login ou Registro)
  configurarAcaoFormulario(bool acao) {
    setState(() {
      estaFazendoLogin = acao;
      if (estaFazendoLogin) {
        titulo = "Bem Vindo ao SpyMap";
        rotuloBotaoAcao = "Login";
        rotuloBotaoAlternar = "Ainda não tem conta? Cadastre-se agora";
      } else {
        titulo = "Crie sua conta";
        rotuloBotaoAcao = "Cadastrar";
        rotuloBotaoAlternar = "Voltar ao Login.";
      }
    });
  }

  // Método para realizar o login
  fazerLogin() async {
    setState(() => carregando = true);
    try {
      await context.read<ServicoAutenticacao>().realizarLogin(controladorEmail.text, controladorSenha.text);
    } on ExcecaoAutenticacao catch (e) {
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
    }
  }

  // Método para realizar o registro
  registrar() async {
    setState(() => carregando = true);
    try {
      await context.read<ServicoAutenticacao>().registrar(controladorEmail.text, controladorSenha.text);
    } on ExcecaoAutenticacao catch (e) {
      setState(() => carregando = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.mensagem)));
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
                        controller: controladorEmail,
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
                        validator: (valor) {
                          String padrao = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
                          RegExp regex = RegExp(padrao);
                          if (!regex.hasMatch(valor!))
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
                        controller: controladorSenha,
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
                        validator: (valor) {
                          if (valor!.isEmpty) {
                            return 'Informe sua senha!';
                          } else if (valor.length < 8) {
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
                            if (estaFazendoLogin) {
                              fazerLogin();
                            } else {
                              registrar();
                            }
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: (carregando)
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
                                      rotuloBotaoAcao,
                                      style: TextStyle(fontSize: 20),
                                    ),
                                  )
                                ],
                        ),
                      ),
                    ),
                    // Botão para alternar entre Login e Registro
                    TextButton(
                      onPressed: () => configurarAcaoFormulario(!estaFazendoLogin),
                      child: Text(rotuloBotaoAlternar),
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