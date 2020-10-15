import 'package:nexthour/repository/database_creator.dart';
import 'package:nexthour/model/todo.dart';

import '../global.dart';

class RepositoryServiceTodo {

  static Future<List<Todo>> getAllTodos() async {
    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}''';

    final data = await cdb.rawQuery(sql);


    for (final node in data) {
      final todo = Todo.fromMap(node);
      todos.add(todo);
    }
    return todos;
  }

  static Future<List<Todo>> getAllTodos2() async {
    var response = await cdb.query(DatabaseCreator.todoTable);
    todos = response.map((c) => Todo.fromMap(c)).toList();
    return todos;


  }

  static Future<Todo> getTodo(int id) async {
//    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
//    WHERE ${DatabaseCreator.id} = $id''';
//    final data = await db.rawQuery(sql);

    final sql = '''SELECT * FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?''';

    List<dynamic> params = [id];
    final data = await cdb.rawQuery(sql, params);

    final todo = Todo.fromMap(data.first);
    return todo;
  }

  static Future<void> addTodo(Todo todo) async {
    /*final sql = '''INSERT INTO ${DatabaseCreator.todoTable}
    (
      ${DatabaseCreator.id},
      ${DatabaseCreator.name},
      ${DatabaseCreator.info},
      ${DatabaseCreator.isDeleted}
    )
    VALUES
    (
      ${todo.id},
      "${todo.name}",
      "${todo.info}",
      ${todo.isDeleted ? 1 : 0}
    )''';*/

    final sql = '''INSERT INTO ${DatabaseCreator.todoTable}
    (
      ${DatabaseCreator.id},
      ${DatabaseCreator.name},
      ${DatabaseCreator.info},
      ${DatabaseCreator.type},
      ${DatabaseCreator.movieId},
      ${DatabaseCreator.tvSeriesId},
      ${DatabaseCreator.seasonId},
      ${DatabaseCreator.episodeId},
      ${DatabaseCreator.dTaskId},
      ${DatabaseCreator.dUserId},
      ${DatabaseCreator.progress}
    )
    VALUES (?,?,?,?,?,?,?,?,?,?,?)''';
    List<dynamic> params = [todo.id, todo.name, todo.path, todo.type, todo.movieId, todo.tvSeriesId, todo.seasonId,
      todo.episodeId, todo.dTaskId, todo.dUserId, todo.progress];

    final result = await cdb.rawInsert(sql, params);
    DatabaseCreator.databaseLog('Add todo', sql, null, result, params);
  }

  static Future<void> deleteTodo(Todo todo) async {
    /*final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.isDeleted} = 1
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';*/
    final sql = '''DELETE
    FROM ${DatabaseCreator.todoTable}
    WHERE ${DatabaseCreator.id} = ?
''';
//    final sql = '''UPDATE ${DatabaseCreator.todoTable}
//    SET ${DatabaseCreator.isDeleted} = 1
//    WHERE ${DatabaseCreator.id} = ?
//    ''';
//
    List<dynamic> params = [todo.id];
//    final result = await db6.rawUpdate(sql, params);
//    final result2 = await db6.delete(DatabaseCreator.todoTable, where: "${DatabaseCreator.id} = ?", whereArgs: [122]);
    final result2 = await cdb.delete(DatabaseCreator.todoTable);
    print(result2);
//
//    DatabaseCreator.databaseLog('Delete todo', sql, null, result, params);
  }


  static Future<void> updateTodo(Todo todo) async {
    /*final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.name} = "${todo.name}"
    WHERE ${DatabaseCreator.id} = ${todo.id}
    ''';*/

    final sql = '''UPDATE ${DatabaseCreator.todoTable}
    SET ${DatabaseCreator.name} = ?
    WHERE ${DatabaseCreator.id} = ?
    ''';

    List<dynamic> params = [todo.name, todo.id];
    final result = await cdb.rawUpdate(sql, params);

    DatabaseCreator.databaseLog('Update todo', sql, null, result, params);
  }

  static Future<int> todosCount() async {
    final data = await cdb.rawQuery('''SELECT COUNT(*) FROM ${DatabaseCreator.todoTable}''');
    int count = data[0].values.elementAt(0);
    int idForNewItem = count++;
    return idForNewItem;
  }
}

