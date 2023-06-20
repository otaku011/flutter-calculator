// ignore_for_file: constant_identifier_names

class Keyboard {
    static const memoryClear = "MC";
    static const memoryRecall = "MR";
    static const memoryPlus = "M+";
    static const memoryMin = "M−";
    static const memory = "M";

    static const openBracket = "(";
    static const closeBracket = ")";

    static const key_0 = "0";
    static const key_1 = "1";
    static const key_2 = "2";
    static const key_3 = "3";
    static const key_4 = "4";
    static const key_5 = "5";
    static const key_6 = "6";
    static const key_7 = "7";
    static const key_8 = "8";
    static const key_9 = "9";

    static const hex_a = "A";
    static const hex_b = "B";
    static const hex_c = "C";
    static const hex_d = "D";
    static const hex_e = "E";
    static const hex_f = "F";

    static const division = "÷";
    static const multiply = "×";
    static const add = "+";
    static const min = "-";
    static const point = ".";
    static const equal = "=";
    static const power = "^";
    static const percentage = "%";
    static const squareRoot = "√";
    static const factorial = "!";
    static const clear = "CLEAR";
    static const delete = "DELETE";
    static const swap = "SWAP";
    static const plusMinus = "±";
    static const modulus = "mod";
    static const leftShift = "lsh";
    static const rightShift = "rsh";
    static const or = "or";
    static const and = "and";
    static const xor = "xor";
    static const inputRadix = "inputRadix";

    static const tenPower = "10$power";
    static const eurelPower = "$eurel$power";
    static const powerOfTwo = "^2";
    static const eurel = "e";
    static const pi = "π";

    static const fNot = "not";
    static const fAbs = "abs";
    static const fLog = "log";
    static const fLn = "ln";
    static const fCeil = "ceil";
    static const fFloor = "floor";
    static const fRound = "round";
    static const fSin = "sin";
    static const fCos = "cos";
    static const fTan = "tan";
    static const fCsc = "csc";
    static const fSec = "sec";
    static const fCot = "cot";
    static const fSinHyper = "${fSin}h";
    static const fCosHyper = "${fCos}h";
    static const fTanHyper = "${fTan}h";
    static const fCscHyper = "${fCsc}h";
    static const fSecHyper = "${fSec}h";
    static const fCotHyper = "${fCot}h";
    static const fSinInverse = "$fSin⁻¹";
    static const fCosInverse = "$fCos⁻¹";
    static const fTanInverse = "$fTan⁻¹";
    static const fCscInverse = "$fCsc⁻¹";
    static const fSecInverse = "$fSec⁻¹";
    static const fCotInverse = "$fCot⁻¹";
    static const fSinHyperInverse = "${fSin}h⁻¹";
    static const fCosHyperInverse = "${fCos}h⁻¹";
    static const fTanHyperInverse = "${fTan}h⁻¹";
    static const fCscHyperInverse = "${fCsc}h⁻¹";
    static const fSecHyperInverse = "${fSec}h⁻¹";
    static const fCotHyperInverse = "${fCot}h⁻¹";

    static bool isNumber(String key){
        return RegExp(r'^\d$').hasMatch(key);
    }

    static bool isHexNumber(String key){
        return RegExp(r'^[A-F]$').hasMatch(key);
    }

    static bool isFunction(String key){
        return RegExp("^(?:${functionsRegex()})\$").hasMatch(key);
    }

    static String functionsRegex(){
        return "$fNot|$fAbs|$fLog|$fLn|$fCeil|$fFloor|$fRound|"
            "$fSin|$fCos|$fTan|$fCsc|$fSec|$fCot|"
            "$fSinInverse|$fCosInverse|$fTanInverse|$fCscInverse|$fSecInverse|$fCotInverse|"
            "$fSinHyper|$fCosHyper|$fTanHyper|$fCscHyper|$fSecHyper|$fCotHyper|"
            "$fSinHyperInverse|$fCosHyperInverse|$fTanHyperInverse|$fCscHyperInverse|$fSecHyperInverse|$fCotHyperInverse"
        ;
    }
}