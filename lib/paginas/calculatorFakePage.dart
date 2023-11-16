import 'package:flutter/material.dart';
import 'package:spymap/widgets/authCheck.dart';

class CalculatorFakePage extends StatefulWidget {
  const CalculatorFakePage({Key? key});

  @override
  State<CalculatorFakePage> createState() => _CalculatorFakePageState();
}

class _CalculatorFakePageState extends State<CalculatorFakePage> {
  // Função para criar um botão da calculadora
  Widget botaoCalculadora(String textoBotao, Color corBotao, Color corTexto) {
    return Container(
      child: ElevatedButton(
        onPressed: () {
          // TODO: Adicionar lógica para pressionar o botão
          calculo(textoBotao);
        },
        child: Text(
          textoBotao,
          style: TextStyle(
            fontSize: 35,
            color: corTexto,
          ),
        ),
        style: ElevatedButton.styleFrom(
          primary: corBotao, // Cor de fundo do botão
          shape: CircleBorder(),
          padding: EdgeInsets.all(20),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Calculadora'),
        backgroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            // Tela da calculadora
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Text(
                      textoTela,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 100,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botões de operações
                      botaoCalculadora('AC', Colors.grey, Colors.black),
                      botaoCalculadora('+/-', Colors.grey, Colors.black),
                      botaoCalculadora('%', Colors.grey, Colors.black),
                      botaoCalculadora('/', Colors.amber[700]!, Colors.white),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      botaoCalculadora('7', Colors.grey[850]!, Colors.white),
                      botaoCalculadora('8', Colors.grey[850]!, Colors.white),
                      botaoCalculadora('9', Colors.grey[850]!, Colors.white),
                      botaoCalculadora('x', Colors.amber[700]!, Colors.white),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      botaoCalculadora('4', Colors.grey[850]!, Colors.white),
                      botaoCalculadora('5', Colors.grey[850]!, Colors.white),
                      botaoCalculadora('6', Colors.grey[850]!, Colors.white),
                      botaoCalculadora('-', Colors.amber[700]!, Colors.white),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      botaoCalculadora('1', Colors.grey[850]!, Colors.white),
                      botaoCalculadora('2', Colors.grey[850]!, Colors.white),
                      botaoCalculadora('3', Colors.grey[850]!, Colors.white),
                      botaoCalculadora('+', Colors.amber[700]!, Colors.white),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Botão 0
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.grey[850], // Cor de fundo do botão
                          shape: StadiumBorder(),
                          padding: EdgeInsets.fromLTRB(34, 20, 128, 20),
                        ),
                        onPressed: () {
                          // Lógica do botão 0
                          calculo('0');
                        },
                        child: Text(
                          "0",
                          style: TextStyle(
                            fontSize: 35,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      botaoCalculadora(',', Colors.grey[850]!, Colors.white),
                      botaoCalculadora('=', Colors.grey[700]!, Colors.white),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lógica da calculadora
  dynamic textoTela = '0';
  double numeroUm = 0;
  double numeroDois = 0;

  dynamic resultado = '';
  dynamic resultadoFinal = '';
  dynamic operacao = '';
  dynamic operacaoAnterior = '';

  void calculo(textoBotao) {
    if (textoBotao == 'AC') {
      textoTela = '0';
      numeroUm = 0;
      numeroDois = 0;
      resultado = '';
      resultadoFinal = '0';
      operacao = '';
      operacaoAnterior = '';
    } else if (operacao == '=' && textoBotao == '=') {
      if (operacaoAnterior == '+') {
        resultadoFinal = somar();
      } else if (operacaoAnterior == '-') {
        resultadoFinal = subtrair();
      } else if (operacaoAnterior == 'x') {
        resultadoFinal = multiplicar();
      } else if (operacaoAnterior == '/') {
        resultadoFinal = dividir();
      }
    } else if (textoBotao == '+' || textoBotao == '-' || textoBotao == 'x' || textoBotao == '/' || textoBotao == '=') {
      if (numeroUm == 0) {
        numeroUm = double.parse(resultado.replaceAll(',', '.'));
      } else {
        numeroDois = double.parse(resultado.replaceAll(',', '.'));
      }

      if (operacao == '+') {
        resultadoFinal = somar();
      } else if (operacao == '-') {
        resultadoFinal = subtrair();
      } else if (operacao == 'x') {
        resultadoFinal = multiplicar();
      } else if (operacao == '/') {
        resultadoFinal = dividir();
      }
      operacaoAnterior = operacao;
      operacao = textoBotao;
      resultado = '';
    } else if (textoBotao == '%') {
      if (resultado == '53105') {
        // Redirecionar para AuthCheck em caso de condição específica
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AuthCheck()),
        );
      } else {
        if (double.tryParse(resultado) != null) {
          resultado = (numeroUm / 100).toString();
          resultadoFinal = contemDecimal(resultado);
        } else {
          // Exibir Snackbar em caso de erro
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: valor inválido para porcentagem')),
          );
        }
      }
    } else if (textoBotao == '.') {
      if (!resultado.toString().contains('.')) {
        resultado = resultado.toString() + '.';
      }
      resultadoFinal = resultado;
    } else if (textoBotao == '+/-') {
      resultado.toString().startsWith('-') ? resultado = resultado.toString().substring(1) : resultado = '-' + resultado.toString();
      resultadoFinal = resultado;
    } else {
      resultado = resultado + textoBotao;
      resultadoFinal = resultado;
    }
    setState(() {
      textoTela = resultadoFinal;
    });
  }

  String somar() {
    resultado = (numeroUm + numeroDois).toString();
    numeroUm = double.parse(resultado);
    return contemDecimal(resultado);
  }

  String subtrair() {
    resultado = (numeroUm - numeroDois).toString();
    numeroUm = double.parse(resultado);
    return contemDecimal(resultado);
  }

  String multiplicar() {
    resultado = (numeroUm * numeroDois).toString();
    numeroUm = double.parse(resultado);
    return contemDecimal(resultado);
  }

  String dividir() {
    resultado = (numeroUm / numeroDois).toString();
    numeroUm = double.parse(resultado);
    return contemDecimal(resultado);
  }

  String contemDecimal(resultado) {
    if (resultado.toString().contains('.')) {
      List<String> splitDecimal = resultado.toString().split('.');
      if (!(int.parse(splitDecimal[1]) > 0)) resultado = splitDecimal[0].toString();
    }
    return resultado.toString().replaceAll('.', ',');
  }
}