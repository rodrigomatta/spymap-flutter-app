import 'package:flutter/material.dart';
import 'package:spymap/widgets/verificarAutenticacao.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spymap/widgets/botaoCalculadora.dart';

// Página principal da calculadora falsa
class PaginaCalculadoraFalsa extends StatefulWidget {
  const PaginaCalculadoraFalsa({required Key key}) : super(key: key);

  @override
  _PaginaCalculadoraFalsaState createState() => _PaginaCalculadoraFalsaState();
}

// Estado da página da calculadora falsa
class _PaginaCalculadoraFalsaState extends State<PaginaCalculadoraFalsa> {
  // Histórico e expressão atual na calculadora
  String _historico = ''; // Histórico de operações
  String _expressao = ''; // Expressão atual

  // Função chamada ao clicar nos números e operadores
  void clicarNumero(String texto) {
    // Verifica se a expressão é um código especial
    if (texto == '%' && _expressao == '53105') {
      // Se for, navega para a página de autenticação
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => VerificarAutenticacao()),
      );
    } else if (texto == '%' || texto == 'AC' || texto == 'C') {
      // Ignora caracteres inválidos
      return;
    } else {
      // Substitui vírgulas por pontos e atualiza a expressão
      texto = texto.replaceAll(',', '.');
      setState(() => _expressao += texto);
    }
  }

  // Função chamada ao clicar no botão 'AC' (limpar tudo)
  void limparTudo(String texto) {
    setState(() {
      _historico = '';
      _expressao = '';
    });
  }

  // Função chamada ao clicar no botão 'C' (limpar)
  void limpar(String texto) {
    setState(() {
      _expressao = '';
    });
  }

  // Função chamada ao clicar no botão '=' (avaliar a expressão)
  void avaliar(String texto) {
    // Cria um parser e um contexto para avaliar a expressão matemática
    Parser parser = Parser();
    ContextModel contexto = ContextModel();

    try {
      // Verifica se a expressão não está vazia
      if (_expressao.isNotEmpty) {
        // Verifica se a expressão contém apenas caracteres válidos
        if (_expressao.contains(RegExp(r'^[0-9+\-*/.() ]+$'))) {
          // Parseia e avalia a expressão
          Expression expressao = parser.parse(_expressao);
          double resultado = expressao.evaluate(EvaluationType.REAL, contexto);

          setState(() {
            // Atualiza o histórico e a expressão com o resultado
            _historico = _expressao;
            _expressao = resultado.toString();
          });
        } else {
          // Se a expressão contém caracteres inválidos, exibe uma mensagem de erro
          print('Expressão contém caracteres inválidos');
        }
      } else {
        // Se a expressão estiver vazia, exibe uma mensagem no console
        print('Expressão está vazia');
      }
    } catch (e) {
      // Se ocorrer um erro na análise da expressão, exibe o erro no console
      print('Erro ao analisar a expressão: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Barra de aplicativo
      appBar: AppBar(
        title: Text('Calculadora'),
        backgroundColor: const Color(0xFF283637),
      ),
      // Cor de fundo da tela
      backgroundColor: const Color(0xFF283637),
      // Corpo da tela em um ListView
      body: ListView(
        children: [
          // Container com padding contendo a estrutura da calculadora
          Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                // Exibição do histórico
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(
                      _historico,
                      style: GoogleFonts.rubik(
                        textStyle: TextStyle(
                          fontSize: 24,
                          color: const Color(0xFF545F61),
                        ),
                      ),
                    ),
                  ),
                ),
                // Exibição da expressão atual
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      _expressao,
                      style: GoogleFonts.rubik(
                        textStyle: TextStyle(
                          fontSize: 48,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                // Linhas de botões da calculadora
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // Botão 'AC' (limpar tudo)
                    BotaoCalculadora(
                      texto: 'AC',
                      preenchimentoCor: 0xFF6C807F,
                      tamanhoTexto: 20,
                      funcaoCallback: limparTudo,
                    ),
                    // Botão 'C' (limpar)
                    BotaoCalculadora(
                      texto: 'C',
                      preenchimentoCor: 0xFF6C807F,
                      funcaoCallback: limpar,
                    ),
                    // Botão '%' (porcentagem)
                    BotaoCalculadora(
                      texto: '%',
                      preenchimentoCor: 0xFFFFFFFF,
                      corTexto: 0xFF65BDAC,
                      funcaoCallback: clicarNumero,
                    ),
                    // Botão '/' (divisão)
                    BotaoCalculadora(
                      texto: '/',
                      preenchimentoCor: 0xFFFFFFFF,
                      corTexto: 0xFF65BDAC,
                      funcaoCallback: clicarNumero,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    BotaoCalculadora(
                      texto: '7',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '8',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '9',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '*',
                      preenchimentoCor: 0xFFFFFFFF,
                      corTexto: 0xFF65BDAC,
                      tamanhoTexto: 24,
                      funcaoCallback: clicarNumero,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    BotaoCalculadora(
                      texto: '4',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '5',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '6',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '-',
                      preenchimentoCor: 0xFFFFFFFF,
                      corTexto: 0xFF65BDAC,
                      tamanhoTexto: 38,
                      funcaoCallback: clicarNumero,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    BotaoCalculadora(
                      texto: '1',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '2',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '3',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '+',
                      preenchimentoCor: 0xFFFFFFFF,
                      corTexto: 0xFF65BDAC,
                      tamanhoTexto: 30,
                      funcaoCallback: clicarNumero,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    BotaoCalculadora(
                      texto: '.',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '0',
                      funcaoCallback: clicarNumero,
                    ),
                    BotaoCalculadora(
                      texto: '00',
                      funcaoCallback: clicarNumero,
                      tamanhoTexto: 26,
                    ),
                    BotaoCalculadora(
                      texto: '=',
                      preenchimentoCor: 0xFFFFFFFF,
                      corTexto: 0xFF65BDAC,
                      funcaoCallback: avaliar,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}