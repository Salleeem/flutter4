import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CalendarPage extends StatefulWidget {
  @override
  _CalendarPageState createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final TextEditingController _tamanhoCicloController = TextEditingController();
  final TextEditingController _ultimaMenstruacaoController =
      TextEditingController();
  final TextEditingController _duracaoMenstruacaoController =
      TextEditingController();

  DateTime? _ultimaMenstruacaoData;
  int _tamanhoCiclo = 28;
  int _duracaoMenstruacao = 5;

  List<DateTime> _diasMenstruacaoConfirmada = [];
  List<DateTime> _diasPrevistos = [];
  DateTime _proximaMenstruacaoPrevista = DateTime.now();
  DateTime _focusedDay = DateTime.now();
  bool _exibirCalendario = false; // Controla a visibilidade do calendário

  @override
  void initState() {
    super.initState();
    _carregarDados(); // Carrega os dados ao iniciar a página
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Função para salvar dados no Firestore
  Future<void> _salvarDados() async {
    await _firestore.collection('ciclos').add({
      'ultima_menstruacao': _ultimaMenstruacaoData,
      'tamanho_ciclo': _tamanhoCiclo,
      'duracao_menstruacao': _duracaoMenstruacao,
      'dias_menstruacao_confirmada': _diasMenstruacaoConfirmada,
      'dias_previsto': _diasPrevistos,
    });
  }

// Função para carregar dados do Firestore
  // Função para carregar dados do Firestore
// Função para carregar dados do Firestore
  Future<void> _carregarDados() async {
    QuerySnapshot snapshot = await _firestore.collection('ciclos').get();
    if (snapshot.docs.isNotEmpty) {
      var doc = snapshot.docs.last; // Carrega o último documento
      setState(() {
        _ultimaMenstruacaoData =
            (doc['ultima_menstruacao'] as Timestamp).toDate();
        _tamanhoCiclo = doc['tamanho_ciclo'];
        _duracaoMenstruacao = doc['duracao_menstruacao'];
        _diasMenstruacaoConfirmada = List<DateTime>.from(
            doc['dias_menstruacao_confirmada']
                .map((x) => (x as Timestamp).toDate()));
        _diasPrevistos = List<DateTime>.from(
            doc['dias_previsto'].map((x) => (x as Timestamp).toDate()));

        // Calcule os ciclos após carregar os dados
        _calcularCiclos();
        _exibirCalendario = true; // Exibe o calendário
      });
    }
  }

// Função para calcular previsões de ciclo
  void _calcularCiclos() {
    if (_ultimaMenstruacaoData != null) {
      _diasMenstruacaoConfirmada.clear();

      // Adiciona os dias confirmados do ciclo atual em rosa escuro
      for (int j = 0; j < _duracaoMenstruacao; j++) {
        _diasMenstruacaoConfirmada
            .add(_ultimaMenstruacaoData!.add(Duration(days: j)));
      }

      // Inicia a previsão da próxima menstruação
      _proximaMenstruacaoPrevista =
          _ultimaMenstruacaoData!.add(Duration(days: _tamanhoCiclo));

      setState(() {
        _exibirCalendario =
            true; // Certifique-se de que isto está sendo definido corretamente
        _calcularProximaPrevisao(); // Calcula as previsões assim que o ciclo é definido
        _salvarDados(); // Salve os dados aqui ou após a confirmação do ciclo
      });
    }
  }

  // Função para calcular a próxima previsão com base na última confirmação
  void _calcularProximaPrevisao() {
    if (_diasMenstruacaoConfirmada.isNotEmpty) {
      DateTime ultimaConfirmacao = _diasMenstruacaoConfirmada.last;
      _proximaMenstruacaoPrevista =
          ultimaConfirmacao.add(Duration(days: _tamanhoCiclo));

      // Adiciona os dias previstos
      _diasPrevistos.clear(); // Limpa as previsões antigas
      for (int j = 0; j < _duracaoMenstruacao; j++) {
        _diasPrevistos.add(_proximaMenstruacaoPrevista.add(Duration(days: j)));
      }
    }
  }

  // Confirma o dia como menstruado e calcula a próxima previsão
  void _confirmarMenstruacao(DateTime dia) {
    if (!_diasMenstruacaoConfirmada.contains(dia)) {
      setState(() {
        _diasMenstruacaoConfirmada.add(dia);
        _calcularProximaPrevisao();
      });
    }
  }

  // Desmarcar um dia como menstruado e recalcular as previsões
  void _desmarcarMenstruacao(DateTime dia) {
    setState(() {
      _diasMenstruacaoConfirmada.remove(dia);
      _calcularProximaPrevisao();
    });
  }

  // Classifica a chance de gravidez
  String _classificacaoChance(double chance) {
    if (chance > 20) {
      return "Alta";
    } else if (chance > 0) {
      return "Média";
    } else {
      return "Baixa";
    }
  }

  // Calcular a chance de engravidar com base no dia
  double _calcularChanceGravidez(DateTime dia) {
    if (_diasMenstruacaoConfirmada.isEmpty)
      return 0.0; // Se não houver confirmações, chance é 0.

    DateTime diaOvulacao =
        _diasMenstruacaoConfirmada.last.add(Duration(days: _tamanhoCiclo ~/ 2));
    DateTime periodoFertilInicio = diaOvulacao.subtract(Duration(days: 5));
    DateTime periodoFertilFim = diaOvulacao.add(Duration(days: 1));

    if (dia.isAfter(periodoFertilInicio) && dia.isBefore(periodoFertilFim)) {
      return 30.0; // Alta chance durante o período fértil
    } else if (dia.isAfter(periodoFertilInicio.subtract(Duration(days: 3))) &&
        dia.isBefore(periodoFertilInicio)) {
      return 10.0; // Média chance antes do período fértil
    } else {
      return 0.0; // Baixa chance fora do período fértil
    }
  }

  // Exibir informações do ciclo ao segurar o dia
  void _exibirInformacoesDia(DateTime dia) {
    String classificacao = _classificacaoChance(_calcularChanceGravidez(dia));

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Informações do Dia',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Data: ${DateFormat('dd/MM/yyyy').format(dia)}'),
              SizedBox(height: 10),
              Text('Chance de engravidar: $classificacao'),
            ],
          ),
        );
      },
    );
  }

  // Função para calcular previsões de ciclo

  // Função para verificar se o dia é fértil
  bool _isFertil(DateTime dia) {
    if (_diasMenstruacaoConfirmada.isEmpty)
      return false; // Se não houver confirmações, não há dias férteis.

    DateTime diaOvulacao =
        _diasMenstruacaoConfirmada.last.add(Duration(days: _tamanhoCiclo ~/ 2));
    return dia.isAfter(diaOvulacao.subtract(Duration(days: 5))) &&
        dia.isBefore(diaOvulacao.add(Duration(days: 1)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false, // Remove a seta de voltar
        title: Row(
          children: [
            Image.asset(
              'assets/img/sem.png', // Substitua pela sua logo
              height: 40, // Ajuste a altura conforme necessário
            ),
            const SizedBox(width: 8), // Espaço entre a imagem e o título
            const Text('Calendário'),
          ],
        ),
        backgroundColor: const Color(0xFF579EC2), // Cor da AppBar
      ),
      body: Container(
        color: const Color(0xFFF5D5D4), // Cor do fundo
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (!_exibirCalendario)
                Column(
                  children: [
                    const Text(
                      'Preencha as informações:',
                      style: TextStyle(fontSize: 20),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      color: const Color(
                          0xFFF5D5D4), // Cor do espaço do formulário
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            TextField(
                              controller: _tamanhoCicloController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText: 'Tamanho do Ciclo (21 a 35 dias)',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _tamanhoCiclo = int.tryParse(value) ?? 28;
                                });
                              },
                            ),
                            TextField(
                              controller: _ultimaMenstruacaoController,
                              decoration: const InputDecoration(
                                labelText:
                                    'Data da Última Menstruação (dd/MM/yyyy)',
                              ),
                              onTap: () async {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                DateTime? dataSelecionada =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (dataSelecionada != null) {
                                  setState(() {
                                    _ultimaMenstruacaoData = dataSelecionada;
                                    _ultimaMenstruacaoController.text =
                                        DateFormat('dd/MM/yyyy')
                                            .format(dataSelecionada);
                                  });
                                }
                              },
                            ),
                            TextField(
                              controller: _duracaoMenstruacaoController,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                labelText:
                                    'Duração da Menstruação (1 a 10 dias)',
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _duracaoMenstruacao =
                                      int.tryParse(value) ?? 5;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: _calcularCiclos,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                    0xFF9A5071), // Cor do botão "Confirmar"
                                foregroundColor:
                                    Colors.white, // Cor do texto do botão
                              ),
                              child: const Text('Confirmar'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              if (_exibirCalendario)
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        color: const Color(
                            0xFFF5D5D4), // Cor do fundo do calendário
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.arrow_left),
                                  onPressed: () {
                                    setState(() {
                                      _focusedDay = DateTime(
                                        _focusedDay.year,
                                        _focusedDay.month - 1,
                                      );
                                    });
                                  },
                                ),
                                Text(
                                  DateFormat('MMMM yyyy').format(_focusedDay),
                                  style: const TextStyle(fontSize: 20),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.arrow_right),
                                  onPressed: () {
                                    setState(() {
                                      _focusedDay = DateTime(
                                        _focusedDay.year,
                                        _focusedDay.month + 1,
                                      );
                                    });
                                  },
                                ),
                              ],
                            ),
                            GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 7,
                                childAspectRatio: 1.0,
                              ),
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: DateTime(_focusedDay.year,
                                      _focusedDay.month + 1, 0)
                                  .day,
                              itemBuilder: (context, index) {
                                DateTime diaAtual = DateTime(_focusedDay.year,
                                    _focusedDay.month, index + 1);
                                bool isMenstruacaoConfirmada =
                                    _diasMenstruacaoConfirmada
                                        .contains(diaAtual);
                                bool isFertil = _isFertil(diaAtual);
                                bool isMenstruacaoPrevista =
                                    _diasPrevistos.contains(diaAtual);

                                return GestureDetector(
                                  onTap: () {
                                    if (isMenstruacaoConfirmada) {
                                      _desmarcarMenstruacao(diaAtual);
                                    } else {
                                      _confirmarMenstruacao(diaAtual);
                                    }
                                  },
                                  onLongPress: () =>
                                      _exibirInformacoesDia(diaAtual),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isMenstruacaoConfirmada
                                          ? Colors.pink[900]
                                          : (isMenstruacaoPrevista
                                              ? Colors.pink[200]
                                              : (isFertil
                                                  ? Colors.lightBlue
                                                  : Colors.transparent)),
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${diaAtual.day}',
                                      style: TextStyle(
                                          color: isMenstruacaoConfirmada
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          // Adicione a navegação para a dashboard aqui
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF9A5071), // Cor do botão "Voltar"
                          foregroundColor:
                              Colors.white, // Cor do texto do botão
                        ),
                        child: const Text('Voltar'),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xFF579EC2), // Cor sólida do rodapé
        height: 60.0,
      ),
    );
  }
}
