import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:spymap/servicos/servicoAutenticacao.dart';
import 'package:provider/provider.dart';
import 'package:spymap/widgets/verificarAutenticacao.dart';

// Página de configuração do aplicativo
class paginaConfiguracao extends StatefulWidget {
  // Funções de callback para alterar cor e ícone
  final Function(String)? alterarCor;
  final Function(String, int)? alterarIcone;

  // Adicione um novo parâmetro para a cor do tema
  final Color corTema;

  // Construtor da classe
  const paginaConfiguracao({
    Key? key,
    this.alterarCor,
    this.alterarIcone,
    required this.corTema,
  }) : super(key: key);

  @override
  State<paginaConfiguracao> createState() => _paginaConfiguracaoState();
}

// Estado da Página de Configuração
class _paginaConfiguracaoState extends State<paginaConfiguracao> with SingleTickerProviderStateMixin {
  // Controlador de animação
  late AnimationController _controlador;
  // Flag para indicar se está carregando
  bool carregando = false;

  // Lista de cores disponíveis
  final List<String> listaCores = <String>['Verde', 'Amarelo', 'Roxo', 'Preto'];
  // Valor atual da cor
  String valorCor = 'Verde';

  // Lista de ícones personalizados disponíveis
  final List<String> listaPontos = <String>[
    'images/spy.png',
    'images/pontoazul.png',
    'images/pontovermelho.png',
    'images/nicolascage.png',
  ];
  // Valor atual do ícone personalizado
  String valorPontos = 'images/pontoazul.png';

  @override
  void initState() {
    super.initState();
    // Inicializa o controlador de animação
    _controlador = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    // Libera os recursos do controlador de animação
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Seção para selecionar a cor do tema
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    'Tema do aplicativo:',
                    style: TextStyle(fontSize: 9.5, fontFamily: 'MagicalChildhood'),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: DropdownPersonalizado(
                      // Cria os itens do dropdown com as cores
                      itens: listaCores.map<DropdownMenuItem<String>>((String valor) {
                        return DropdownMenuItem<String>(
                          value: valor,
                          child: Text(
                            valor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      // Configurações do dropdown
                      textoHint: "Selecione o tema",
                      borderRadius: 10,
                      aoAlterar: (String? novoValor) {
                        // Ao alterar a cor, atualiza o estado e chama a função de callback
                        setState(() {
                          valorCor = novoValor!;
                          if (widget.alterarCor != null) {
                            widget.alterarCor!(novoValor);
                          }
                        });
                      },
                      estiloHint: TextStyle(fontSize: 12), // Tamanho da fonte
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Seção para selecionar o ícone personalizado
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(
                    'Marcador \npersonalizado:',
                    style: TextStyle(fontSize: 9.5, fontFamily: 'MagicalChildhood'),
                  ),
                ),
                SizedBox(width: 42),
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: DropdownPersonalizado(
                      // Cria os itens do dropdown com os ícones personalizados
                      itens: listaPontos.map<DropdownMenuItem<String>>((String valor) {
                        return DropdownMenuItem<String>(
                          value: valor,
                          child: Text(
                            valor,
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      // Configurações do dropdown
                      textoHint: "Selecione o marcador",
                      borderRadius: 10,
                      aoAlterar: (String? novoValor) {
                        // Ao alterar o ícone, atualiza o estado, chama a função de callback
                        // e atualiza os dados no Firestore
                        setState(() {
                          valorPontos = novoValor!;
                          if (widget.alterarIcone != null) {
                            widget.alterarIcone!(novoValor, 500);
                          }
                          String uid = FirebaseAuth.instance.currentUser!.uid;
                          FirebaseFirestore.instance.collection('temas').doc(uid).set({
                            'marcador': novoValor,
                          }, SetOptions(merge: true));
                        });
                      },
                      estiloHint: TextStyle(fontSize: 12), // Tamanho da fonte
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            // Botão para sair da conta
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: widget.corTema, // Use a cor do tema recebida
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                setState(() {
                  carregando = true;
                });
                // Realiza o logout e atualiza o estado
                await context.read<ServicoAutenticacao>().realizarLogout();
                setState(() {
                  carregando = false;
                });
              },
              child: Text(
                'SAIR DA CONTA',
                style: TextStyle(fontSize: 9.5, fontFamily: 'MagicalChildhood'),
              ),
            ),
            // Botão para excluir a conta
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                try {
                  // Obtém o usuário atual
                  User? usuario = FirebaseAuth.instance.currentUser;

                  // Exclui o usuário se existir
                  if (usuario != null) {
                    await usuario.delete();
                    // Redireciona o usuário para a tela de login após a exclusão
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => VerificarAutenticacao()),
                    );
                  }
                } catch (e) {
                  // Trata qualquer erro que possa ocorrer
                  print('Ocorreu um erro: $e');
                }
              },
              child: Text(
                'EXCLUIR CONTA',
                style: TextStyle(fontSize: 9.5, fontFamily: 'MagicalChildhood'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Dropdown personalizado reutilizável
class DropdownPersonalizado extends StatelessWidget {
  final List<DropdownMenuItem<String>> itens;
  final String textoHint;
  final double borderRadius;
  final Function(String?) aoAlterar;
  final TextStyle estiloHint;

  DropdownPersonalizado({
    required this.itens,
    required this.textoHint,
    required this.borderRadius,
    required this.aoAlterar,
    required this.estiloHint,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          color: Colors.black12,
        ),
        child: Container(
          constraints: BoxConstraints(maxWidth: 300),
          child: DropdownButton<String>(
            isExpanded: true,
            hint: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                textoHint,
                style: estiloHint,
              ),
            ),
            items: itens,
            onChanged: aoAlterar,
          ),
        ),
      ),
    );
  }
}