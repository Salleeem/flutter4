import 'package:flutter_test/flutter_test.dart';
import 'package:bioo/todopage.dart'; // Substitua pelo caminho correto

void main() {
  group('TodoItem', () {
    test('deve criar um TodoItem com título e status padrão', () {
      final item = TodoItem(title: 'Tarefa 1');
      expect(item.title, 'Tarefa 1');
      expect(item.isCompleted, false);
      expect(item.isNote, false);
    });

    test('deve converter um TodoItem para JSON', () {
      final item = TodoItem(title: 'Tarefa 2', isCompleted: true, isNote: true);
      final json = item.toJson();
      expect(json['title'], 'Tarefa 2');
      expect(json['isCompleted'], true);
      expect(json['isNote'], true);
    });

    test('deve criar um TodoItem a partir do JSON', () {
      final json = {'title': 'Tarefa 3', 'isCompleted': false, 'isNote': false};
      final item = TodoItem.fromJson(json);
      expect(item.title, 'Tarefa 3');
      expect(item.isCompleted, false);
      expect(item.isNote, false);
    });
  });
}
