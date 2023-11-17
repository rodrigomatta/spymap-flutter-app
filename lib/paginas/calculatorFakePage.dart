import 'package:flutter/material.dart';
import 'package:spymap/widgets/authCheck.dart'; // Import do widget de verificação de autenticação
import 'package:math_expressions/math_expressions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spymap/widgets/calcButton.dart';

// Definindo a classe CalculatorFakePage que é um StatefulWidget
class CalculatorFakePage extends StatefulWidget {
  const CalculatorFakePage({required Key key}) : super(key: key);

  @override
  CalculatorFakePageState createState() => CalculatorFakePageState();
}

// Estado da página da calculadora
class CalculatorFakePageState extends State<CalculatorFakePage> {
  // Variáveis para armazenar o histórico e a expressão atual
  String _historico = ''; // Histórico de expressões
  String _expressao = ''; // Expressão atual sendo construída

  // Função chamada ao clicar nos botões numéricos e de operação
  void clicarNumero(String texto) {
    // Verificando se o texto é '%' e a expressão é '53105' para redirecionar para a tela de autenticação
    if (texto == '%' && _expressao == '53105') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AuthCheck()),
      );
    } else {
      // Adicionando o texto à expressão atual
      setState(() => _expressao += texto);
    }
  }

  // Função chamada ao clicar no botão "AC" (All Clear)
  void limparTudo(String texto) {
    // Limpando tanto o histórico quanto a expressão atual
    setState(() {
      _historico = '';
      _expressao = '';
    });
  }

  // Função chamada ao clicar no botão "C" (Clear)
  void limpar(String texto) {
    // Limpando apenas a expressão atual
    setState(() {
      _expressao = '';
    });
  }

  // Função chamada ao clicar no botão "=" (Igual)
  void avaliar(String texto) {
    // Criando um parser e um contexto para avaliar a expressão matemática
    Parser p = Parser();
    ContextModel cm = ContextModel();

    try {
      // Verificando se a expressão não está vazia
      if (_expressao.isNotEmpty) {
        // Fazendo o parsing e avaliação da expressão
        Expression exp = p.parse(_expressao);

        setState(() {
          // Atualizando o histórico e a expressão atual
          _historico = _expressao;
          _expressao = exp.evaluate(EvaluationType.REAL, cm).toString();
        });
      } else {
        // Tratar o caso em que a expressão está vazia
        print('Expressão está vazia');
      }
    } catch (e) {
      // Tratar erro de parsing
      print('Erro ao analisar a expressão: $e');
    }
  }

  // Método build para construir a interface da página
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calculadora'),
        backgroundColor: const Color(0xFF283637),
      ),
      backgroundColor: const Color(0xFF283637),
      body: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            // Exibindo o histórico no canto inferior direito
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
            // Exibindo a expressão atual no canto inferior direito
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
            // Linhas de botões organizados em filas
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Botão "AC"
                BotaoCalculadora(
                  texto: 'AC',
                  preenchimentoCor: 0xFF6C807F,
                  tamanhoTexto: 20,
                  funcaoCallback: limparTudo,
                ),
                // Botão "C"
                BotaoCalculadora(
                  texto: 'C',
                  preenchimentoCor: 0xFF6C807F,
                  funcaoCallback: limpar,
                ),
                // Botão "%"
                BotaoCalculadora(
                  texto: '%',
                  preenchimentoCor: 0xFFFFFFFF,
                  corTexto: 0xFF65BDAC,
                  funcaoCallback: clicarNumero,
                ),
                // Botão "/"
                BotaoCalculadora(
                  texto: '/',
                  preenchimentoCor: 0xFFFFFFFF,
                  corTexto: 0xFF65BDAC,
                  funcaoCallback: clicarNumero,
                ),
              ],
            ),
            // Linha de botões numéricos e operadores
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                // Botões numéricos de 7 a 9 e operador "*"
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
            // Linha de botões numéricos de 4 a 6 e operador "-"
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
            // Linha de botões numéricos de 1 a 3 e operador "+"
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
            // Linha de botões "." , "0", "00" e "="
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
    );
  }
}