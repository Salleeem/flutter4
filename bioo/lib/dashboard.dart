import 'package:bioo/login.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  final String nome;

  DashboardPage({required this.nome});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final TextEditingController _tamanhoCicloController = TextEditingController();
  final TextEditingController _ultimaMenstruacaoController = TextEditingController();
  final TextEditingController _duracaoMenstruacaoController = TextEditingController();

  DateTime? _ultimaMenstruacaoData;
  int _tamanhoCiclo = 28;
  int _duracaoMenstruacao = 5;

  List<DateTime> _diasMenstruacao = [];
  List<DateTime> _diasFertilidade = [];
  DateTime _focusedDay = DateTime.now();
  bool _exibirCalendario = false; // Controla a visibilidade do calendário

  void _calcularCiclo() {
    if (_ultimaMenstruacaoData != null) {
      _diasMenstruacao.clear();
      _diasFertilidade.clear();

      DateTime proximaMenstruacao = _ultimaMenstruacaoData!;

      // Apenas adiciona a primeira suposição
      for (int i = 0; i < 1; i++) {
        for (int j = 0; j < _duracaoMenstruacao; j++) {
          _diasMenstruacao.add(proximaMenstruacao.add(Duration(days: j)));
        }

        // Calcular o período fértil (geralmente ocorre 14 dias antes da próxima menstruação)
        DateTime inicioFertilidade = proximaMenstruacao.subtract(const Duration(days: 14));
        for (int j = 0; j < 6; j++) {
          _diasFertilidade.add(inicioFertilidade.add(Duration(days: j)));
        }

        // Calcular a próxima menstruação
        proximaMenstruacao = proximaMenstruacao.add(Duration(days: _tamanhoCiclo));
      }

      setState(() {
        _exibirCalendario = true; // Exibe o calendário após o cálculo
      });
    }
  }

  void _logout(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  // Função para editar os dias de menstruação
  void _editarDia(DateTime dia) {
    setState(() {
      if (_diasMenstruacao.contains(dia)) {
        // Se o dia já estiver marcado como menstruado, remove
        _diasMenstruacao.remove(dia);
        // Adicionar novas suposições após confirmação
        DateTime proximaMenstruacao = dia.add(Duration(days: _tamanhoCiclo));
        for (int i = 0; i < _duracaoMenstruacao; i++) {
          _diasMenstruacao.add(proximaMenstruacao.add(Duration(days: i)));
        }
        // Calcular o período fértil
        DateTime inicioFertilidade = proximaMenstruacao.subtract(const Duration(days: 14));
        for (int i = 0; i < 6; i++) {
          _diasFertilidade.add(inicioFertilidade.add(Duration(days: i)));
        }
      } else {
        // Caso contrário, adiciona como menstruado
        _diasMenstruacao.add(dia);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (!_exibirCalendario) // Exibir o questionário se o calendário não estiver visível
              Column(
                children: [
                  Text(
                    'Bem-vindo, ${widget.nome}!',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
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
                      labelText: 'Data da Última Menstruação (dd/MM/yyyy)',
                    ),
                    onTap: () async {
                      FocusScope.of(context).requestFocus(FocusNode());
                      DateTime? dataSelecionada = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                      );
                      if (dataSelecionada != null) {
                        setState(() {
                          _ultimaMenstruacaoData = dataSelecionada;
                          _ultimaMenstruacaoController.text = DateFormat('dd/MM/yyyy').format(dataSelecionada);
                        });
                      }
                    },
                  ),
                  TextField(
                    controller: _duracaoMenstruacaoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duração da Menstruação (1 a 10 dias)',
                    ),
                    onChanged: (value) {
                      setState(() {
                        _duracaoMenstruacao = int.tryParse(value) ?? 5;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _calcularCiclo,
                    child: const Text('Calcular Ciclo'),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            // Exibir o calendário apenas se _exibirCalendario for verdadeiro
            if (_exibirCalendario) ...[
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                          });
                        },
                      ),
                      Text(
                        DateFormat('MMMM yyyy').format(_focusedDay),
                        style: const TextStyle(fontSize: 20),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () {
                          setState(() {
                            _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                          });
                        },
                      ),
                    ],
                  ),
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      childAspectRatio: 1.0,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day,
                    itemBuilder: (context, index) {
                      DateTime diaAtual = DateTime(_focusedDay.year, _focusedDay.month, index + 1);
                      bool isMenstruacao = _diasMenstruacao.contains(diaAtual);
                      bool isFertilidade = _diasFertilidade.contains(diaAtual);

                      return GestureDetector(
                        onTap: () => _editarDia(diaAtual), // Edita o dia ao clicar
                        child: Container(
                          margin: const EdgeInsets.all(4.0),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isMenstruacao
                                ? Colors.pink // Rosa escuro para menstrução confirmada
                                : (_diasMenstruacao.contains(diaAtual) ? Colors.pink.withOpacity(0.3) : Colors.transparent), // Rosa claro para menstruação possível
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${diaAtual.day}',
                            style: TextStyle(
                              color: isMenstruacao ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
