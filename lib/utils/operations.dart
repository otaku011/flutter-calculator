import 'dart:math' as math;

import 'string.dart';

class Operation {
    static bool isContainDecimal(String num1, [String num2 = ""]){
        return num1.contains(".") || num2.contains(".");
    }

    static String sqrt(String num1){
        if (double.parse(num1) < 0) throw Exception("The square root value must be greater than 0. [value: $num1]");
        return math.sqrt(double.parse(num1)).toString().toRealDigit();
    }

    static String percentage(String num1){
        return (double.parse(num1) / 100).toString().toRealDigit();
    }

    static String factorial(String num1){
        num1 = num1.toRealDigit();
        if (num1.contains(".")) throw Exception("Factorial value must be an integer [value: $num1]");
        if (double.parse(num1) < 0) throw ArgumentError('Factorial is not defined for negative integers');

        String output = "1";
        for (double i = 1; i <= double.parse(num1); i++) {
            output = (BigInt.parse(output) * BigInt.from(i)).toString();
        }
        return output.toRealDigit();
    }

    static String add(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        String output = (isContainDecimal(num1, num2)
            ? double.parse(num1) + double.parse(num2)
            : BigInt.parse(num1) + BigInt.parse(num2)
        ).toString();
        return output.toRealDigit();
    }

    static String subtract(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        String output = (isContainDecimal(num1, num2)
            ? double.parse(num1) - double.parse(num2)
            : BigInt.parse(num1) - BigInt.parse(num2)
        ).toString();
        return output.toRealDigit();
    }

    static String multiply(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        String output = (isContainDecimal(num1, num2)
            ? double.parse(num1) * double.parse(num2)
            : BigInt.parse(num1) * BigInt.parse(num2)
        ).toString();
        return output.toRealDigit();
    }

    static String division(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        String output = (isContainDecimal(num1, num2)
            ? double.parse(num1) / double.parse(num2)
            : BigInt.parse(num1) / BigInt.parse(num2)
        ).toString();
        return output.toRealDigit();
    }

    static String modulus(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        String output = (isContainDecimal(num1, num2)
            ? double.parse(num1) % double.parse(num2)
            : BigInt.parse(num1) % BigInt.parse(num2)
        ).toString();
        return output.toRealDigit();
    }

    static String floorDivision(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        String output = (isContainDecimal(num1, num2)
            ? double.parse(num1) ~/ double.parse(num2)
            : BigInt.parse(num1) ~/ BigInt.parse(num2)
        ).toString();
        return output.toRealDigit();
    }

    static String power(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        if (isContainDecimal(num1, num2) || RegExp(r'^-').hasMatch(num2)){
            return math.pow(double.parse(num1), double.parse(num2)).toString().toRealDigit();
        }

        BigInt baseInt = BigInt.parse(num1);
        BigInt exponentInt = BigInt.parse(num2);

        if (exponentInt == BigInt.zero) {
            return '1';
        } else if (exponentInt.isNegative) {
            throw ArgumentError("Exponent cannot be negative");
        } else {
            BigInt result = BigInt.one;
            while (exponentInt > BigInt.zero) {
                if (exponentInt & BigInt.one == BigInt.one) {
                    result *= baseInt;
                }
                baseInt *= baseInt;
                exponentInt >>= 1;
            }
            return result.toString().toRealDigit();
        }
    }

    static String leftShift(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        if (!num1.isInteger() || !num2.isInteger()) throw Exception("num1 or num2 is not integer [num1: $num1, num2: $num2]");
        return multiply(num1, power("2", num2));
    }

    static String rightShift(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        if (!num1.isInteger() || !num2.isInteger()) throw Exception("num1 or num2 is not integer [num1: $num1, num2: $num2]");
        return (BigInt.parse(num1) >> int.parse(num2)).toString().toRealDigit();
    }

    static String xor(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        if (!num1.isInteger() || !num2.isInteger()) throw Exception("num1 or num2 is not integer [num1: $num1, num2: $num2]");
        return (BigInt.parse(num1) ^ BigInt.parse(num2)).toString().toRealDigit();
    }

    static String and(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        if (!num1.isInteger() || !num2.isInteger()) throw Exception("num1 or num2 is not integer [num1: $num1, num2: $num2]");
        return (BigInt.parse(num1) & BigInt.parse(num2)).toString().toRealDigit();
    }

    static String or(String num1, String num2){
        num1 = num1.toRealDigit();
        num2 = num2.toRealDigit();
        if (!num1.isInteger() || !num2.isInteger()) throw Exception("num1 or num2 is not integer [num1: $num1, num2: $num2]");
        return (BigInt.parse(num1) | BigInt.parse(num2)).toString().toRealDigit();
    }

    /// Calculates the value of the given mathematical expression.
    ///
    /// The input `expression` is a string containing a mathematical
    /// expression that can use integer or decimal numbers and the
    /// following operators:
    ///
    /// - `+` for addition
    /// - `-` for subtraction
    /// - `*` for multiplication
    /// - `/` for division
    /// - `%` for modulus
    /// - `^` for power
    /// - `~/` for floor division
    /// - `()` for grouping
    static String calculate(String expression){
        String numbers = '(?<!\\d)[-+]?\\d*\\.?\\d+';
        RegExp regex = RegExp(
            "\\($numbers\\)|"
            "(?:$numbers)(?:[-+*/%\\^]|~/)(?:$numbers)"
        );
        expression = expression.toRealDigit().replaceAll(RegExp(r"[ \n]"), "");
        int cache = 0;
        while (regex.hasMatch(expression)){

            // Exponential operation
            expression = expression.reverse()
            .replaceAllMapped(
                RegExp("(\\d+\\.?\\d*[-+]?(?!\\d))(\\^)\\)(\\d+\\.?\\d*[-]?(?!\\d))\\("),
                (match) => Operation.power(match[3]!.reverse(), match[1]!.reverse()).reverse()
            )
            .replaceAllMapped(
                RegExp("(\\d+\\.?\\d*[-+]?(?!\\d))(\\^)(\\d+\\.?\\d*[+]?(?!\\d))"),
                (match) => Operation.power(match[3]!.reverse(), match[1]!.reverse()).reverse()
            )
            .reverse();

            // Division & multiplication & modulus operation
            expression = expression.replaceAllMapped(
                RegExp("($numbers)([*/%]|~/)($numbers)"),
                (match) {
                    switch (match[2]){
                        case "*": return Operation.multiply(match[1]!, match[3]!);
                        case "/": return Operation.division(match[1]!, match[3]!);
                        case "%": return Operation.modulus(match[1]!, match[3]!);
                        case "~/": return Operation.floorDivision(match[1]!, match[3]!);
                    }
                    return "";
                }
            );

            // Addition & subtraction operation
            expression = expression.replaceAllMapped(
                RegExp("($numbers)([-+])($numbers)"),
                (match) {
                    switch (match[2]){
                        case "+": return Operation.add(match[1]!, match[3]!);
                        case "-": return Operation.subtract(match[1]!, match[3]!);
                    }
                    return "";
                }
            );

            // Remove unnecesary brackets
            expression = expression.replaceAllMapped(
                RegExp('\\(($numbers)\\)'),
                (match) => match[1]!
            );

            if (cache > 2000) break;
            ++cache;
        }
        return expression.toRealDigit();
    }
}