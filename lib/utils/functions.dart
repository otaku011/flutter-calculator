import "dart:math" as math;


import 'string.dart';
import 'operations.dart';

class Functions {

    // log(10)(x) = log(e)(x) / log(e)(10), x > 0
    static String log(String num1){
        if (double.parse(num1) <= 0) throw Exception("log() value is less than or equal 0 [value: $num1]");
        return Operation.division(
            math.log(double.parse(num1)).toString(),
            math.log(10).toString()
        );
    }

    // ln(x) = log(e)(x), x > 0
    static String ln(String num1){
        if (double.parse(num1) <= 0) throw Exception("ln() value is less than or equal 0 [value: $num1]");
        return math.log(double.parse(num1)).toString().toRealDigit();
    }

    static String not(String num1){
        if (!num1.isInteger()) throw Exception("not() value is not an integer [value: $num1]");
        return (~ BigInt.parse(num1)).toString().toRealDigit();
    }

    static String abs(String num1){
        return RegExp(r'^-').hasMatch(num1)? num1.substring(1) : num1;
    }

    static String ceil(String num1){
        return double.parse(num1).ceilToDouble().toString().toRealDigit();
    }

    static String floor(String num1){
        return double.parse(num1).floorToDouble().toString().toRealDigit();
    }

    static String round(String num1){
        return double.parse(num1).roundToDouble().toString().toRealDigit();
    }

    // SIN - CSC -----------------------------------------------------------------------
    static String sin(String num1){
        if (double.parse(num1) % math.pi == 0) return "0";
        return math.sin(double.parse(num1)).toString().toRealDigit();
    }

    // sinh(x) = (e^x - e^(-x)) / 2
    static String sinh(String num1){
        return Operation.calculate("(${math.e} ^ $num1 - ${math.e} ^ -$num1) / 2");
    }

    static String asin(String num1){
        if (double.parse(num1) < -1 || double.parse(num1) > 1) throw Exception("asin() value is more than 1 or less than -1 [value: $num1]");
        return math.asin(double.parse(num1)).toString().toRealDigit();
    }

    // asinh(x) = ln(x + sqrt(x^2 + 1))
    static String asinh(String num1){
        return ln(Operation.calculate("$num1 + ${Operation.sqrt(Operation.calculate("$num1 ^ 2 + 1"))}"));
    }

    // csc(x) = 1 / sin(x)
    static String csc(String num1){
        return Operation.division("1", sin(num1));
    }

    // csch(x) = 1 / sinh(x)
    static String csch(String num1){
        return Operation.division("1", sinh(num1));
    }

    // acsc(x) = asin(1 / x), -1 <= x <= 1, x != 0
    static String acsc(String num1){
        if (double.parse(num1) < -1 || double.parse(num1) > 1) throw Exception("acsc() value is more than 1 or less than -1 [value: $num1]");
        if (double.parse(num1) == 0) throw Exception("acsc() value is zero [value: $num1]");
        return asin(Operation.division("1", num1));
    }

    // acsch(x) = ln(1 / x + sqrt(1 / x ^ 2 + 1)), x != 0
    static String acsch(String num1){
        if (double.parse(num1) == 0) throw Exception("acsch() value is zero [value: $num1]");
        return ln(Operation.calculate("1 / $num1 + ${Operation.sqrt(Operation.calculate("1 / $num1 ^ 2 + 1"))}"));
    }

    // COS - SEC -----------------------------------------------------------------------
    static String cos(String num1){
        if ((double.parse(num1) / (math.pi / 2)) % 2 == 1) return "0";
        return math.cos(double.parse(num1)).toString().toRealDigit();
    }

    static String acos(String num1){
        if (double.parse(num1) < -1 || double.parse(num1) > 1) throw Exception("acos() value is more than 1 or less than -1 [value: $num1]");
        return math.acos(double.parse(num1)).toString().toRealDigit();
    }

    // cosh(x) = (e ^ x + e ^ (-x))/2
    static String cosh(String num1){
        return Operation.calculate("(${math.e} ^ $num1 + ${math.e} ^ -$num1) / 2");
    }

    // acosh(x) = ln(x + sqrt(x ^ 2 - 1)), x >= 1
    static String acosh(String num1){
        if (double.parse(num1) < 1) throw Exception("acosh() value is less than 1 [value: $num1]");
        return ln(Operation.calculate("$num1 + ${Operation.sqrt(Operation.calculate("$num1 ^ 2 - 1"))}"));
    }

    // sec(x) = 1 / cos(x)
    static String sec(String num1){
        return Operation.division("1", cos(num1));
    }

    // asec(x) = acos(1 / x), x <= -1, x >= 1
    static String asec(String num1){
        if (-1 < double.parse(num1) && double.parse(num1) < 1) throw Exception("asec() value is more -1 and less than 1 [value: $num1]");
        return acos(Operation.division("1", num1));
    }

    // sech(x) = 1 / cosh(x)
    static String sech(String num1){
        return Operation.division("1", cosh(num1));
    }

    // asech(x) = ln((1 + sqrt(1 - x^2)) / x), 0 < x < 1
    static String asech(String num1){
        if (double.parse(num1) <= 0 || double.parse(num1) >= 1) throw Exception("asech() value is less than or equal 0 or value is more than or equal 1 [value: $num1]");
        return ln(Operation.calculate("(1 + ${Operation.sqrt(Operation.calculate("1 - $num1 ^ 2"))}) / $num1"));
    }

    // TAN - COT -----------------------------------------------------------------------
    static String tan(String num1){
        if ((double.parse(num1) / (math.pi / 2)) % 2 == 1) throw Exception("tan() value cause infinity result [value: $num1]");
        if (double.parse(num1) % math.pi == 0) return "0";
        return math.tan(double.parse(num1)).toString().toRealDigit();
    }

    static String atan(String num1){
        return math.atan(double.parse(num1)).toString().toRealDigit();
    }

    // tanh(x) = sinh(x) / cosh(x)
    static String tanh(String num1){
        return Operation.division(sinh(num1), cosh(num1));
    }

    // atanh(x) = ln((1 + x) / (1 - x)) / 2, -1 <= x <= 1
    static String atanh(String num1){
        if (double.parse(num1) < -1 || double.parse(num1) > 1) throw Exception("atanh() value is more than 1 or less than -1 [value: $num1]");
        return Operation.division(ln(Operation.calculate("(1 + $num1) / (1 - $num1)")), "2");
    }

    // cot(x) = 1 / tan(x), tan(x) != 0
    static String cot(String num1){
        if (double.parse(tan(num1)) == 0) throw Exception("cot() value in tan() is 0 [value: $num1]");
        return Operation.division("1", tan(num1));
    }

    // acot(x) = atan(1 / x), x != 0
    static String acot(String num1){
        if (double.parse(num1) == 0) throw Exception("acot() value is zero [value: $num1]");
        return atan(Operation.division("1", num1));
    }

    // coth(x) = cosh(x) / sinh(x), tanh(x) != 0
    static String coth(String num1){
        if (double.parse(tanh(num1)) == 0) throw Exception("coth() value in tanh() is 0 [value: $num1]");
        return Operation.division(cosh(num1), sinh(num1));
    }

    // acoth(x) = ln[(x + 1) / (x - 1)] / 2, x > 1, x < -1
    static String acoth(String num1){
        if (-1 <= double.parse(num1) && double.parse(num1) <= 1) throw Exception("acoth() value in range from -1 to 1 [value: $num1]");
        return Operation.division(ln(Operation.calculate("($num1 + 1) / ($num1 - 1)")), "2");
    }
}