import 'dart:convert';

import 'enums.dart';
import '../utils/string.dart';

class ConverterUnit {
    final String name;
    final String symbol;

    /// The value of a unit used for conversion calculations. The value should be
    /// given in terms of a standard unit. For example, if the standard unit is
    /// meter, then the value for meter should be 1, and the value for kilometer
    /// should be 0.001 (1 meter = 0.001 kilometer).
    ///
    /// This value will be used as a helper to convert from one unit to another,
    /// according to the following formula:
    ///
    /// > `f(x) = x * [output unit value] / [input unit value]`
    ///
    /// Note that this formula cannot be used for units that have their own
    /// conversion formula, such as temperature or angle units.
    ///
    /// For example, to convert 2 kilometers to centimeters using this value:
    ///
    /// > ```dart
    /// > final kilometerValue = 0.001;
    /// > final centimeterValue = 100;
    /// >
    /// > final result = 2 * centimeterValue / kilometerValue;
    /// > print(result); // Output: 200000
    /// > ```
    ///
    /// The result of this calculation is 200000, which represents 2 kilometers
    /// converted to centimeters using the specified values for kilometer and
    /// centimeter units.
    final String _value;

    const ConverterUnit(this.name, this.symbol, String value) : _value = value;

    bool get isStandardUnit => value == "1";
    String get value => _value.toRealDigit();

    @override
    bool operator ==(Object other){
        return
            other is ConverterUnit &&
            name == other.name &&
            symbol == other.symbol &&
            value == other.value
        ;
    }

    @override
    int get hashCode => name.hashCode ^ symbol.hashCode ^ value.hashCode;

    String toMapString(){
        return jsonEncode({"name": name, "symbol": symbol, "value": value});
    }

    static ConverterUnit parse(String jsonData){
        var data = jsonDecode(jsonData);
        return ConverterUnit(data["name"], data["symbol"], data["value"]);
    }

    static List<ConverterUnit> getUnitsBy(Converter converter){
        switch (converter){
            case Converter.angle      : return angle;
            case Converter.area       : return area;
            case Converter.frequency  : return frequency;
            case Converter.length     : return length;
            case Converter.number     : return number;
            case Converter.pressure   : return pressure;
            case Converter.temperature: return temperature;
            case Converter.time       : return time;
            case Converter.volume     : return volume;
            case Converter.weight     : return weight;
        }
    }

    static const length = [
        lengthKilometer , lengthHectometer, lengthDekameter ,
        lengthMeter     , lengthDecimeter , lengthCentimeter,
        lengthMillimeter, lengthMicrometer, lengthNanometer ,
        lengthMile      , lengthInch      , lengthYard      ,
        lengthFeet
    ];
    static const lengthKilometer  = ConverterUnit("Kilometer", "km", "1E-3");
    static const lengthHectometer = ConverterUnit("Hectometer", "hm", "1E-2");
    static const lengthDekameter  = ConverterUnit("Dekameter", "dam", "1E-1");
    static const lengthMeter      = ConverterUnit("Meter", "m", "1"); // standard unit
    static const lengthDecimeter  = ConverterUnit("Decimeter", "dm", "1E+1");
    static const lengthCentimeter = ConverterUnit("Centimeter", "cm", "1E+2");
    static const lengthMillimeter = ConverterUnit("Millimeter", "mm", "1E+3");
    static const lengthMicrometer = ConverterUnit("Micrometer", "μm", "1E+6");
    static const lengthNanometer  = ConverterUnit("Nanometer", "nm", "1E+9");
    static const lengthMile       = ConverterUnit("Mile", "mi", "6.21371E-4");
    static const lengthInch       = ConverterUnit("Inch", "in", "39.3701");
    static const lengthYard       = ConverterUnit("Yard", "yd", "1.09361");
    static const lengthFeet       = ConverterUnit("Feet", "ft", "3.28084");

    static const area = [
        areaSquareKilometer , areaSquareHectometer, areaSquareDekameter ,
        areaSquareMeter     , areaSquareDecimeter , areaSquareCentimeter,
        areaSquareMillimeter, areaSquareMicrometer, areaSquareNanometer ,
        areaSquareMile      , areaSquareInch      , areaSquareYard      ,
        areaSquareFeet      , areaHectare         , areaAre
    ];
    static const areaSquareKilometer  = ConverterUnit("Square Kilometer", "km²", "1E-6");
    static const areaSquareHectometer = ConverterUnit("Square Hectometer", "hm²", "1E-4");
    static const areaSquareDekameter  = ConverterUnit("Square Dekameter", "dam²", "1E-2");
    static const areaSquareMeter      = ConverterUnit("Square Meter", "m²", "1"); // standard unit
    static const areaSquareDecimeter  = ConverterUnit("Square Decimeter", "dm²", "1E+2");
    static const areaSquareCentimeter = ConverterUnit("Square Centimeter", "cm²", "1E+4");
    static const areaSquareMillimeter = ConverterUnit("Square Millimeter", "mm²", "1E+6");
    static const areaSquareMicrometer = ConverterUnit("Square Micrometer", "μm²", "1E+12");
    static const areaSquareNanometer  = ConverterUnit("Square Nanometer", "nm²", "1E+18");
    static const areaSquareMile       = ConverterUnit("Square Mile", "mi²", "3.861E-7");
    static const areaSquareInch       = ConverterUnit("Square Inch", "in²", "1550.0031");
    static const areaSquareYard       = ConverterUnit("Square Yard", "yd²", "1.19599");
    static const areaSquareFeet       = ConverterUnit("Square Feet", "ft²", "10.76391");
    static const areaHectare          = ConverterUnit("Hectare", "ha", "1E-4");
    static const areaAre              = ConverterUnit("Are", "a", "1E-2");

    static const volume = [
        volumeQubicKilometer , volumeQubicHectometer, volumeQubicDekameter ,
        volumeQubicMeter     , volumeQubicDecimeter , volumeQubicCentimeter,
        volumeQubicMillimeter, volumeQubicMicrometer, volumeQubicNanometer ,
        volumeQubicMile      , volumeQubicInch      , volumeQubicYard      ,
        volumeQubicFeet      , volumeLiter          , volumeMilliliter
    ];
    static const volumeQubicKilometer  = ConverterUnit("Qubic Kilometer", "km³", "1E-9");
    static const volumeQubicHectometer = ConverterUnit("Qubic Hectometer", "hm³", "1E-6");
    static const volumeQubicDekameter  = ConverterUnit("Qubic Dekameter", "dam³", "1E-3");
    static const volumeQubicMeter      = ConverterUnit("Qubic Meter", "m³", "1"); // standard unit
    static const volumeQubicDecimeter  = ConverterUnit("Qubic Decimeter", "dm³", "1E+3");
    static const volumeQubicCentimeter = ConverterUnit("Qubic Centimeter", "cm³", "1E+6");
    static const volumeQubicMillimeter = ConverterUnit("Qubic Millimeter", "mm³", "1E+9");
    static const volumeQubicMicrometer = ConverterUnit("Qubic Micrometer", "μm³", "1E+18");
    static const volumeQubicNanometer  = ConverterUnit("Qubic Nanometer", "nm³", "1E+27");
    static const volumeQubicMile       = ConverterUnit("Qubic Mile", "mi³", "3.53147E-7");
    static const volumeQubicInch       = ConverterUnit("Qubic Inch", "in³", "61023.7");
    static const volumeQubicYard       = ConverterUnit("Qubic Yard", "yd³", "1.30795");
    static const volumeQubicFeet       = ConverterUnit("Qubic Feet", "ft³", "35.3147");
    static const volumeLiter           = ConverterUnit("Liter", "L", "1E+3");
    static const volumeMilliliter      = ConverterUnit("Milliliter", "mL", "1E+6");

    static const temperature = [
        temperatureKelvin    , temperatureCelsius, temperatureReamur ,
        temperatureFahrenheit, temperatureRomer  , temperatureRankine,
        temperatureDelisle
    ];
    static const temperatureKelvin     = ConverterUnit("Kelvin", "K", "274.15");
    static const temperatureCelsius    = ConverterUnit("Celsius", "°C", "1"); // standard unit (value not used)
    static const temperatureReamur     = ConverterUnit("Réamur", "°Ré", "0.8");
    static const temperatureFahrenheit = ConverterUnit("Fahrenheit", "°F", "33.8");
    static const temperatureRomer      = ConverterUnit("Rømer", "°Rø", "7.875");
    static const temperatureRankine    = ConverterUnit("Rankine", "°R", "491.67");
    static const temperatureDelisle    = ConverterUnit("Delisle", "°De", "148.5");

    static const time = [
        timeCentury    , timeDecade     , timeYear  ,
        timeMonth      , timeWeek       , timeDay   ,
        timeHour       , timeMinute     , timeSecond,
        timeMillisecond, timeMicrosecond, timeNanosecond
    ];
    static const timeCentury     = ConverterUnit("Century", "century", "2.73786E-5");
    static const timeDecade      = ConverterUnit("Decade", "decade", "2.7397E-4");
    static const timeYear        = ConverterUnit("Year", "y", "2.73973E-3");
    static const timeMonth       = ConverterUnit("Month", "m", "3.28767E-2");
    static const timeWeek        = ConverterUnit("Week", "w", "1.42857E-1");
    static const timeDay         = ConverterUnit("Day", "d", "1"); // standard unit
    static const timeHour        = ConverterUnit("Hour", "h", "24");
    static const timeMinute      = ConverterUnit("Minute", "min", "144E+1");
    static const timeSecond      = ConverterUnit("Second", "s", "864E+2");
    static const timeMillisecond = ConverterUnit("Millisecond", "ms", "864E+5");
    static const timeMicrosecond = ConverterUnit("Microsecond", "μs", "864E+9");
    static const timeNanosecond  = ConverterUnit("Nanosecond", "ns", "864E+12");

    static const weight = [
        weightKilogram , weightHectogram, weightDekagram ,
        weightGram     , weightDecigram , weightCentigram,
        weightMilligram, weightMicroGram, weightNanoGram ,
        weightTonne    , weightOunce    , weightPound    ,
        weightGrain
    ];
    static const weightKilogram  = ConverterUnit("Kilogram", "kg", "1E-3");
    static const weightHectogram = ConverterUnit("Hectogram", "hg", "1E-2");
    static const weightDekagram  = ConverterUnit("Dekagram", "dag", "1E-1");
    static const weightGram      = ConverterUnit("Gram", "g", "1"); // standard unit
    static const weightDecigram  = ConverterUnit("Decigram", "dg", "1E+1");
    static const weightCentigram = ConverterUnit("Centigram", "cg", "1E+2");
    static const weightMilligram = ConverterUnit("Milligram", "mg", "1E+3");
    static const weightMicroGram = ConverterUnit("Microgram", "μg", "1E+6");
    static const weightNanoGram  = ConverterUnit("Nanogram", "ng", "1E+9");
    static const weightTonne     = ConverterUnit("Tonne", "t", "1E-6");
    static const weightOunce     = ConverterUnit("Ounce", "oz", "3.5274E-2");
    static const weightPound     = ConverterUnit("Pound", "lbs", "2.20462E-3");
    static const weightGrain     = ConverterUnit("Grain", "gr", "15.4324");

    static const frequency = [
        frequencyHertz    , frequencyKilohertz, frequencyMegahertz,
        frequencyGigahertz, frequencyTerahertz
    ];
    static const frequencyHertz     = ConverterUnit("Hertz", "Hz", "1"); // standard unit
    static const frequencyKilohertz = ConverterUnit("Kilohertz", "kHz", "10E-3");
    static const frequencyMegahertz = ConverterUnit("Megahertz", "MHz", "10E-6");
    static const frequencyGigahertz = ConverterUnit("Gigahertz", "GHz", "10E-9");
    static const frequencyTerahertz = ConverterUnit("Terahertz", "THz", "10E-12");

    static const pressure = [
        pressureAtmosphere, pressureTorr, pressureBar,
        pressurePascal    , pressurePsi
    ];
    static const pressureAtmosphere = ConverterUnit("Atmosphere", "atm", "1"); // standard unit
    static const pressureTorr       = ConverterUnit("Torr", "torr", "76E+1");
    static const pressureBar        = ConverterUnit("Bar", "bar", "1.01325");
    static const pressurePascal     = ConverterUnit("Pascal", "Pa", "101325");
    static const pressurePsi        = ConverterUnit("Psi", "psi", "14.6959");

    static const angle = [angleGradian, angleRadian, angleDegree];
    static const angleGradian = ConverterUnit("Gradian", "ᵍ", "63.662");
    static const angleRadian  = ConverterUnit("Radian", "rad", "1"); // standard unit (value not used)
    static const angleDegree  = ConverterUnit("Degree", "°", "57.2958");

    static const number = [
        numberInteger, numberHexadecimal, numberOctal  ,
        numberBinary , numberFloat32    , numberFloat64
    ];
    static const numberInteger     = ConverterUnit("Integer", "int", "1"); // standard unit (value not used)
    static const numberHexadecimal = ConverterUnit("Hexadecimal", "hex", "1");
    static const numberOctal       = ConverterUnit("Octal", "oct", "1");
    static const numberBinary      = ConverterUnit("Binary", "bin", "1");
    static const numberFloat32     = ConverterUnit("Float32", "float", "1");
    static const numberFloat64     = ConverterUnit("Float64", "double", "1");
}