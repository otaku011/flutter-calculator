import 'package:sqflite/sqflite.dart' as sql;

import 'enums.dart';
import 'converter.dart';
import 'database.dart';

abstract class History {
    final int id;
    final DateTime date;

    History(this.id, this.date);

    Future<int> insertDB([DatabaseInsertOptions? options]);
    Future<int> updateDB([DatabaseUpdateOptions? options]);
    Future<int> deleteDB([DatabaseDeleteOptions? options]);
}

class BasicHistory extends History {
    final String input;
    final String output;

    BasicHistory({
        required this.input,
        required this.output,
        required DateTime date,
        int id = -1
    }) : super(id, date);

    @override
    Future<int> insertDB([DatabaseInsertOptions? options]) async {
        return await Database.insert(options ?? DatabaseInsertOptions(
            databaseTable, {
                "input": input,
                "output": output,
                'date'  : date.toIso8601String(),
            }
        ));
    }

    @override
    Future<int> deleteDB([DatabaseDeleteOptions? options]) async {
        return await Database.delete(options ?? DatabaseDeleteOptions(
            databaseTable,
            where: "id = ?",
            whereArgs: [id]
        ));
    }

    @override
    Future<int> updateDB([DatabaseUpdateOptions? options]) async {
        return await Database.update(options ?? DatabaseUpdateOptions(
            databaseTable, {
                "input": input,
                "output": output,
                'date'  : date.toIso8601String(),
            },
            where: "id = ?",
            whereArgs: [id]
        ));
    }

    static
    DatabaseTables databaseTable = DatabaseTables.basicHistory;

    static
    Future<List<BasicHistory>> queryDB([DatabaseQueryOptions? options]) async {
        List<Map<String, dynamic>> items = await Database.query(options ?? DatabaseQueryOptions(databaseTable));
        return [for (var item in items) BasicHistory(
            id    : item['id'] as int,
            input : item['input'] as String,
            output: item['output'] as String,
            date  : DateTime.parse(item['date'] as String)
        )];
    }

    static
    Future<int> clearDB() async {
        return await Database.delete(DatabaseDeleteOptions(databaseTable));
    }

    static
    Future<void> createDB(sql.Database db) async {
        return await db.execute('''CREATE TABLE ${databaseTable.name} (
            id     INTEGER PRIMARY KEY AUTOINCREMENT,
            input  TEXT,
            output TEXT,
            date   TEXT
        )''');
    }
}

class ScientificHistory extends History {
    final String input;
    final String output;
    final ConverterUnit angleUnit;

    ScientificHistory({
        required this.input,
        required this.output,
        required this.angleUnit,
        required DateTime date,
        int id = -1
    }): super(id, date);

    @override
    Future<int> insertDB([DatabaseInsertOptions? options]) async {
        return await Database.insert(options ?? DatabaseInsertOptions(
            databaseTable, {
                "input": input,
                "output": output,
                "angleUnit": angleUnit.toMapString(),
                'date'  : date.toIso8601String(),
            }
        ));
    }

    @override
    Future<int> deleteDB([DatabaseDeleteOptions? options]) async {
        return await Database.delete(options ?? DatabaseDeleteOptions(
            databaseTable,
            where: "id = ?",
            whereArgs: [id]
        ));
    }

    @override
    Future<int> updateDB([DatabaseUpdateOptions? options]) async {
        return await Database.update(options ?? DatabaseUpdateOptions(
            databaseTable, {
                "input": input,
                "output": output,
                "angleUnit": angleUnit.toMapString(),
                'date'  : date.toIso8601String(),
            },
            where: "id = ?",
            whereArgs: [id]
        ));
    }

    static
    DatabaseTables databaseTable = DatabaseTables.scientificHistory;

    static
    Future<List<ScientificHistory>> queryDB([DatabaseQueryOptions? options]) async {
        List<Map<String, dynamic>> items = await Database.query(options ?? DatabaseQueryOptions(databaseTable));
        return [for (var item in items) ScientificHistory(
            id    : item['id'] as int,
            input : item['input'] as String,
            output: item['output'] as String,
            date  : DateTime.parse(item['date'] as String),
            angleUnit: ConverterUnit.parse(item['angleUnit'] as String),
        )];
    }

    static
    Future<int> clearDB() async {
        return await Database.delete(DatabaseDeleteOptions(databaseTable));
    }

    static
    Future<void> createDB(sql.Database db) async {
        return await db.execute('''CREATE TABLE ${databaseTable.name} (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            input     TEXT,
            output    TEXT,
            angleUnit TEXT,
            date      TEXT
        )''');
    }
}

class ConverterHistory extends History {
    final String input;
    final String output;
    final Converter converter;
    final ConverterUnit inputUnit;
    final ConverterUnit outputUnit;

    ConverterHistory({
        required this.input,
        required this.output,
        required this.converter,
        required this.inputUnit,
        required this.outputUnit,
        required DateTime date,
        int id = -1
    }) : super(id, date);

    @override
    Future<int> insertDB([DatabaseInsertOptions? options]) async {
        return await Database.insert(options ?? DatabaseInsertOptions(
            databaseTable, {
                "input": input,
                "output": output,
                "converter": converter.name,
                "inputUnit": inputUnit.toMapString(),
                "outputUnit": outputUnit.toMapString(),
                'date'  : date.toIso8601String(),
            }
        ));
    }

    @override
    Future<int> deleteDB([DatabaseDeleteOptions? options]) async {
        return await Database.delete(options ?? DatabaseDeleteOptions(
            databaseTable,
            where: "id = ?",
            whereArgs: [id]
        ));
    }

    @override
    Future<int> updateDB([DatabaseUpdateOptions? options]) async {
        return await Database.update(options ?? DatabaseUpdateOptions(
            databaseTable, {
                "input": input,
                "output": output,
                "converter": converter.name,
                "inputUnit": inputUnit.toMapString(),
                "outputUnit": outputUnit.toMapString(),
                'date'  : date.toIso8601String(),
            },
            where: "id = ?",
            whereArgs: [id]
        ));
    }

    static
    DatabaseTables databaseTable = DatabaseTables.converterHistory;

    static
    Future<List<ConverterHistory>> queryDB([DatabaseQueryOptions? options]) async {
        List<Map<String, dynamic>> items = await Database.query(options ?? DatabaseQueryOptions(databaseTable));
        return [for (var item in items) ConverterHistory(
            id: item['id'] as int,
            input: item["input"] as String,
            output: item["output"] as String,
            converter: Converter.values.byName(item["converter"] as String),
            inputUnit: ConverterUnit.parse(item["inputUnit"] as String),
            outputUnit: ConverterUnit.parse(item["outputUnit"] as String),
            date: DateTime.parse(item['date'] as String)
        )];
    }

    static
    Future<int> clearDB() async {
        return await Database.delete(DatabaseDeleteOptions(databaseTable));
    }

    static
    Future<void> createDB(sql.Database db) async {
        return await db.execute('''CREATE TABLE ${databaseTable.name} (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            input      TEXT,
            output     TEXT,
            converter  TEXT,
            inputUnit  TEXT,
            outputUnit TEXT,
            date       TEXT
        )''');
    }
}

class ProgrammerHistory extends History {
    final String input;
    final String output;
    final Radix inputRadix;
    final NumberType numberType;

    ProgrammerHistory({
        required this.input,
        required this.output,
        required this.inputRadix,
        required this.numberType,
        required DateTime date,
        int id = -1
    }) : super(id, date);

    @override
    Future<int> insertDB([DatabaseInsertOptions? options]) async {
        return await Database.insert(options ?? DatabaseInsertOptions(
            databaseTable, {
                "input": input,
                "output": output,
                "inputRadix": inputRadix.name,
                "numberType": numberType.name,
                'date'  : date.toIso8601String(),
            }
        ));
    }

    @override
    Future<int> deleteDB([DatabaseDeleteOptions? options]) async {
        return await Database.delete(options ?? DatabaseDeleteOptions(
            databaseTable,
            where: "id = ?",
            whereArgs: [id]
        ));
    }

    @override
    Future<int> updateDB([DatabaseUpdateOptions? options]) async {
        return await Database.update(options ?? DatabaseUpdateOptions(
            databaseTable, {
                "input": input,
                "output": output,
                "inputRadix": inputRadix.name,
                "numberType": numberType.name,
                'date'  : date.toIso8601String(),
            },
            where: "id = ?",
            whereArgs: [id]
        ));
    }

    static
    DatabaseTables databaseTable = DatabaseTables.programmerHistory;

    static
    Future<List<ProgrammerHistory>> queryDB([DatabaseQueryOptions? options]) async {
        List<Map<String, dynamic>> items = await Database.query(options ?? DatabaseQueryOptions(databaseTable));
        return [for (var item in items) ProgrammerHistory(
            id: item['id'] as int,
            input: item["input"] as String,
            output: item["output"] as String,
            inputRadix: Radix.values.byName(item["inputRadix"] as String),
            numberType: NumberType.values.byName(item["numberType"] as String),
            date: DateTime.parse(item['date'] as String)
        )];
    }

    static
    Future<int> clearDB() async {
        return await Database.delete(DatabaseDeleteOptions(databaseTable));
    }

    static
    Future<void> createDB(sql.Database db) async {
        return await db.execute('''CREATE TABLE ${databaseTable.name} (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            input      TEXT,
            output     TEXT,
            inputRadix TEXT,
            numberType TEXT,
            date       TEXT
        )''');
    }
}

class DateHistory extends History {
    final DateTime fromDate;
    final DateTime toDate;
    final DateOperations operation;
    final String output;
    final int years;
    final int months;
    final int days;

    DateHistory({
        required this.fromDate,
        required this.toDate,
        required this.output,
        required this.operation,
        required this.years,
        required this.months,
        required this.days,
        required DateTime date,
        int id = -1
    }) : super(id, date);

    @override
    Future<int> insertDB([DatabaseInsertOptions? options]) async {
        return await Database.insert(options ?? DatabaseInsertOptions(
            databaseTable, {
                "fromDate": fromDate.toIso8601String(),
                "toDate": toDate.toIso8601String(),
                "operation": operation.name,
                "years": years,
                "months": months,
                "days": days,
                "output": output,
                'date'  : date.toIso8601String(),
            }
        ));
    }

    @override
    Future<int> deleteDB([DatabaseDeleteOptions? options]) async {
        return await Database.delete(options ?? DatabaseDeleteOptions(
            databaseTable,
            where: "id = ?",
            whereArgs: [id]
        ));
    }

    @override
    Future<int> updateDB([DatabaseUpdateOptions? options]) async {
        return await Database.update(options ?? DatabaseUpdateOptions(
            databaseTable, {
                "fromDate": fromDate.toIso8601String(),
                "toDate": toDate.toIso8601String(),
                "operation": operation.name,
                "years": years,
                "months": months,
                "days": days,
                "output": output,
                'date'  : date.toIso8601String(),
            },
            where: "id = ?",
            whereArgs: [id]
        ));
    }

    static
    DatabaseTables databaseTable = DatabaseTables.dateHistory;

    static
    Future<List<DateHistory>> queryDB([DatabaseQueryOptions? options]) async {
        List<Map<String, dynamic>> items = await Database.query(options ?? DatabaseQueryOptions(databaseTable));
        return [for (var item in items) DateHistory(
            id: item['id'] as int,
            fromDate: DateTime.parse(item["fromDate"] as String),
            toDate: DateTime.parse(item["toDate"] as String),
            operation: DateOperations.values.byName(item["operation"] as String),
            years: item['years'] as int,
            months: item['months'] as int,
            days: item['days'] as int,
            output: item["output"] as String,
            date: DateTime.parse(item['date'] as String)
        )];
    }

    static
    Future<int> clearDB() async {
        return await Database.delete(DatabaseDeleteOptions(databaseTable));
    }

    static
    Future<void> createDB(sql.Database db) async {
        return await db.execute('''CREATE TABLE ${DatabaseTables.dateHistory.name} (
            id        INTEGER PRIMARY KEY AUTOINCREMENT,
            fromDate  TEXT,
            toDate    TEXT,
            operation TEXT,
            years     INTEGER,
            months    INTEGER,
            days      INTEGER,
            output    TEXT,
            date      TEXT
        )''');
    }
}