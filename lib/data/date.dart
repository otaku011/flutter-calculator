import 'enums.dart';

class DateInput {
    final DateOperations operation;
    final int? years; // if operation == (DateOperations.addition | DateOperations.substraction)
    final int? months; // if operation == (DateOperations.addition | DateOperations.substraction)
    final int? days; // if operation == (DateOperations.addition | DateOperations.substraction)
    final DateTime? toDate; // if operation == (DateOperations.difference)

    DateInput({
        required this.operation,
        this.years = 0,
        this.months = 0,
        this.days = 0,
        this.toDate
    });
}
