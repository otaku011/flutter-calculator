import "dart:math" as math;

import 'string.dart';

import '../data/converter.dart';
import 'operations.dart';
import 'float.dart';

class ConverterOperation {
    static String length(String num1, ConverterUnit inputUnit, ConverterUnit outputUnit){
        num1 = num1.toRealDigit();
        return Operation.division(Operation.multiply(num1, outputUnit.value), inputUnit.value);
    }

    static String area(String num1, ConverterUnit inputUnit, ConverterUnit outputUnit){
        num1 = num1.toRealDigit();
        return Operation.division(Operation.multiply(num1, outputUnit.value), inputUnit.value);
    }

    static String volume(String num1, ConverterUnit inputUnit, ConverterUnit outputUnit){
        num1 = num1.toRealDigit();
        return Operation.division(Operation.multiply(num1, outputUnit.value), inputUnit.value);
    }

    static String time(String num1, ConverterUnit inputUnit, ConverterUnit outputUnit){
        num1 = num1.toRealDigit();
        return Operation.division(Operation.multiply(num1, outputUnit.value), inputUnit.value);
    }

    static String weight(String num1, ConverterUnit inputUnit, ConverterUnit outputUnit){
        num1 = num1.toRealDigit();
        return Operation.division(Operation.multiply(num1, outputUnit.value), inputUnit.value);
    }

    static String frequency(String num1, ConverterUnit inputUnit, ConverterUnit outputUnit){
        num1 = num1.toRealDigit();
        return Operation.division(Operation.multiply(num1, outputUnit.value), inputUnit.value);
    }

    static String pressure(String num1, ConverterUnit inputUnit, ConverterUnit outputUnit){
        num1 = num1.toRealDigit();
        return Operation.division(Operation.multiply(num1, outputUnit.value), inputUnit.value);
    }

    static String temperature(String num1, ConverterUnit inputUnit, ConverterUnit outputUnit){
        num1 = num1.toRealDigit();
        if (num1.isEmpty) throw Exception("value is empty [value: $num1]");
        String celsius = "";
             if (inputUnit == ConverterUnit.temperatureCelsius   ){ celsius = num1; }
        else if (inputUnit == ConverterUnit.temperatureKelvin    ){ celsius = Operation.calculate("$num1 - 273.15"); }
        else if (inputUnit == ConverterUnit.temperatureReamur    ){ celsius = Operation.calculate("$num1 * 5 / 4"); }
        else if (inputUnit == ConverterUnit.temperatureFahrenheit){ celsius = Operation.calculate("($num1 - 32) * 5 / 9"); }
        else if (inputUnit == ConverterUnit.temperatureRomer     ){ celsius = Operation.calculate("($num1 - 7.5) * 40 / 21"); }
        else if (inputUnit == ConverterUnit.temperatureRankine   ){ celsius = Operation.calculate("($num1 - 491.67) * 5 / 9"); }
        else if (inputUnit == ConverterUnit.temperatureDelisle   ){ celsius = Operation.calculate("100 - $num1 * 2 / 3"); }

             if (outputUnit == ConverterUnit.temperatureCelsius   ){ return celsius; }
        else if (outputUnit == ConverterUnit.temperatureKelvin    ){ return Operation.calculate("$celsius + 273.15"); }
        else if (outputUnit == ConverterUnit.temperatureReamur    ){ return Operation.calculate("$celsius * 4 / 5"); }
        else if (outputUnit == ConverterUnit.temperatureFahrenheit){ return Operation.calculate("$celsius * 9 / 5 + 32"); }
        else if (outputUnit == ConverterUnit.temperatureRomer     ){ return Operation.calculate("$celsius * 21 / 40 + 7.5"); }
        else if (outputUnit == ConverterUnit.temperatureRankine   ){ return Operation.calculate("($celsius + 273.15) * 9 / 5"); }
        else if (outputUnit == ConverterUnit.temperatureDelisle   ){ return Operation.calculate("(100 - $celsius) * 3 / 2"); }
        return celsius;
    }

    static String angle(String num1, ConverterUnit inputUnit, ConverterUnit outputUnit){
        num1 = num1.toRealDigit();
        if (num1.isEmpty) throw Exception("value is empty [value: $num1]");
        String degree = "";
             if (inputUnit == ConverterUnit.angleDegree ){ degree = num1; }
        else if (inputUnit == ConverterUnit.angleGradian){ degree = Operation.calculate("($num1 * 9) / 10"); }
        else if (inputUnit == ConverterUnit.angleRadian ){ degree = Operation.calculate("($num1 * 180) / ${math.pi}"); }

             if (outputUnit == ConverterUnit.angleDegree ){ return degree; }
        else if (outputUnit == ConverterUnit.angleGradian){ return Operation.calculate("($degree * 10) / 9"); }
        else if (outputUnit == ConverterUnit.angleRadian ){ return Operation.calculate("($degree * ${math.pi}) / 180"); }
        return degree;
    }

    static String number(String num1, ConverterUnit inputUnit, ConverterUnit outputUnit){
        String binary = "";
        if (num1.isEmpty) throw Exception("value is empty [value: $num1]");
        if (inputUnit == ConverterUnit.numberBinary){
                 if (outputUnit == ConverterUnit.numberBinary     ){ return num1; }
            else if (outputUnit == ConverterUnit.numberInteger    ){ return BigInt.parse(num1, radix: 2).toString().toRealDigit(); }
            else if (outputUnit == ConverterUnit.numberHexadecimal){ return BigInt.parse(num1, radix: 2).toRadixString(16).toUpperCase(); }
            else if (outputUnit == ConverterUnit.numberOctal      ){ return BigInt.parse(num1, radix: 2).toRadixString(8); }
            else if (outputUnit == ConverterUnit.numberFloat32    ){
                if (num1.length > 32) throw Exception("Binary value more than 32 bits. [binary: $num1]");
                return binaryToFloat(num1.padLeft(32, "0")).toRealDigit();
            }
            else if (outputUnit == ConverterUnit.numberFloat64){
                if (num1.length > 64) throw Exception("Binary value more than 64 bits. [binary: $num1]");
                return binaryToFloat(num1.padLeft(64, "0")).toRealDigit();
            }
        }
        else if (inputUnit == ConverterUnit.numberInteger){
                 if (outputUnit == ConverterUnit.numberBinary     ){ return BigInt.parse(num1).toRadixString(2); }
            else if (outputUnit == ConverterUnit.numberInteger    ){ return num1.toRealDigit(); }
            else if (outputUnit == ConverterUnit.numberHexadecimal){ return BigInt.parse(num1).toRadixString(16).toUpperCase(); }
            else if (outputUnit == ConverterUnit.numberOctal      ){ return BigInt.parse(num1).toRadixString(8).toUpperCase(); }
            else if (outputUnit == ConverterUnit.numberFloat32    ){ return binaryToFloat(floatToBinary(double.parse(num1), 32)).toString().toRealDigit(); }
            else if (outputUnit == ConverterUnit.numberFloat64    ){ return double.parse(num1).toString().toRealDigit(); }
        }
        else if (inputUnit == ConverterUnit.numberHexadecimal) {
            binary = BigInt.parse(num1, radix: 16).toRadixString(2);
                 if (outputUnit == ConverterUnit.numberBinary     ){ return BigInt.parse(num1, radix: 16).toRadixString(2); }
            else if (outputUnit == ConverterUnit.numberInteger    ){ return BigInt.parse(num1, radix: 16).toString().toRealDigit(); }
            else if (outputUnit == ConverterUnit.numberHexadecimal){ return num1.toUpperCase(); }
            else if (outputUnit == ConverterUnit.numberOctal      ){ return BigInt.parse(num1, radix: 16).toRadixString(8); }
            else if (outputUnit == ConverterUnit.numberFloat32    ){
                if (binary.length > 32) throw Exception("Binary value more than 32 bits. [binary: $binary]");
                return binaryToFloat(binary.padLeft(32, "0")).toString().toRealDigit();
            }
            else if (outputUnit == ConverterUnit.numberFloat64){
                if (binary.length > 64) throw Exception("Binary value more than 64 bits. [binary: $binary]");
                return binaryToFloat(binary.padLeft(64, "0")).toString().toRealDigit();
            }
        }
        else if (inputUnit == ConverterUnit.numberOctal){
            binary = BigInt.parse(num1, radix: 8).toRadixString(2);
                 if (outputUnit == ConverterUnit.numberBinary     ){ return BigInt.parse(num1, radix: 8).toRadixString(2); }
            else if (outputUnit == ConverterUnit.numberInteger    ){ return BigInt.parse(num1, radix: 8).toString().toRealDigit(); }
            else if (outputUnit == ConverterUnit.numberHexadecimal){ return BigInt.parse(num1, radix: 8).toRadixString(16).toUpperCase(); }
            else if (outputUnit == ConverterUnit.numberOctal      ){ return num1; }
            else if (outputUnit == ConverterUnit.numberFloat32    ){
                if (binary.length > 32) throw Exception("Binary value more than 32 bits. [binary: $binary]");
                return binaryToFloat(binary.padLeft(32, "0")).toString().toRealDigit();
            }
            else if (outputUnit == ConverterUnit.numberFloat64){
                if (binary.length > 64) throw Exception("Binary value more than 64 bits. [binary: $binary]");
                return binaryToFloat(binary.padLeft(64, "0")).toString().toRealDigit();
            }
        }
        else if (inputUnit == ConverterUnit.numberFloat32){
                 if (outputUnit == ConverterUnit.numberBinary     ){ return floatToBinary(double.parse(num1), 32); }
            else if (outputUnit == ConverterUnit.numberInteger    ){ return double.parse(num1).toInt().toString().toRealDigit(); }
            else if (outputUnit == ConverterUnit.numberHexadecimal){ return BigInt.parse(floatToBinary(double.parse(num1), 32), radix: 2).toRadixString(16).toUpperCase(); }
            else if (outputUnit == ConverterUnit.numberOctal      ){ return BigInt.parse(floatToBinary(double.parse(num1), 32), radix: 2).toRadixString(8).toUpperCase(); }
            else if (outputUnit == ConverterUnit.numberFloat32    ){ return num1; }
            else if (outputUnit == ConverterUnit.numberFloat64    ){ return double.parse(num1).toString().toRealDigit(); }
        }
        else if (inputUnit == ConverterUnit.numberFloat64){
                 if (outputUnit == ConverterUnit.numberBinary     ){ return floatToBinary(double.parse(num1), 64); }
            else if (outputUnit == ConverterUnit.numberInteger    ){ return double.parse(num1).toInt().toString().toRealDigit(); }
            else if (outputUnit == ConverterUnit.numberHexadecimal){ return BigInt.parse(floatToBinary(double.parse(num1), 64), radix: 2).toRadixString(16).toUpperCase(); }
            else if (outputUnit == ConverterUnit.numberOctal      ){ return BigInt.parse(floatToBinary(double.parse(num1), 64), radix: 2).toRadixString(8).toUpperCase(); }
            else if (outputUnit == ConverterUnit.numberFloat32    ){ return double.parse(num1).toStringAsPrecision(10).toRealDigit(); }
            else if (outputUnit == ConverterUnit.numberFloat64    ){ return num1; }
        }
        return num1;
    }
}