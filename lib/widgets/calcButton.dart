// Importando os pacotes necessários do Flutter e do Google Fonts
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// Definindo a classe BotaoCalculadora que é um StatelessWidget
class BotaoCalculadora extends StatelessWidget {
  // Declarando os parâmetros necessários para a construção do botão
  final String texto;
  final int preenchimentoCor;
  final int corTexto;
  final double tamanhoTexto;
  final Function(String) funcaoCallback;

  // Construtor da classe
  const BotaoCalculadora({
    Key? key,
    // Parâmetros obrigatórios
    required this.texto,
    required this.funcaoCallback,
    // Parâmetros opcionais com valores padrão
    this.preenchimentoCor = 0,
    this.corTexto = 0xFFFFFFFF,
    this.tamanhoTexto = 28,
  }) : super(key: key);

  // Método build para construir a interface do widget
  @override
  Widget build(BuildContext context) {
    // Retornando um contêiner com margem
    return Container(
      margin: const EdgeInsets.all(10),
      // Utilizando um SizedBox para limitar as dimensões do botão
      child: SizedBox(
        width: 65,
        height: 65,
        // Utilizando um TextButton como botão
        child: TextButton(
          // Configurando o estilo do TextButton
          style: TextButton.styleFrom(
            // Definindo a forma do botão como circular
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            // Definindo a cor de fundo com base no parâmetro preenchimentoCor
            backgroundColor: preenchimentoCor != 0 ? Color(preenchimentoCor) : null,
            // Definindo a cor do texto com base no parâmetro corTexto
            primary: Color(corTexto),
          ),
          // Definindo a ação a ser executada quando o botão é pressionado
          onPressed: () {
            funcaoCallback(texto);
          },
          // Exibindo o texto no botão utilizando a fonte Rubik do Google Fonts
          child: Text(
            texto,
            style: GoogleFonts.rubik(
              textStyle: TextStyle(
                fontSize: tamanhoTexto,
              ),
            ),
          ),
        ),
      ),
    );
  }
}