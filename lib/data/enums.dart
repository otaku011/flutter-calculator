enum Routes {
    basic,
    scientific,
    converter,
    programmer,
    date,
    history,
    settings
}

enum NumberFormatDecimals {
    point,
    comma
}

enum NumberFormatGrouping {
    none,
    space,
    comma,
    point,
    underscore
}

enum SettingsKey {
    theme,
    color,
    lastPage,
    memoryButton,
    memoryValue,
    scientificNotation,
    numberFormatDecimal,
    numberFormatGrouping,

    // basic page
    basicPage,
    basicPageInput,

    // scientific page
    scientificPage,
    scientificPageInput,
    scientificPageAngleUnit,

    // converter page
    converterPage,
    converterPageInput,
    converterPageConverter,
    converterPageInputUnit,
    converterPageOutputUnit,

    // programmer page
    programmerPage,
    programmerPageInput,
    programmerPageInputRadix,
    programmerPageNumberType,

    // date page
    datePage,
    datePageOperation,
    datePageFromDate,
    datePageToDate,
    datePageYears,
    datePageMonths,
    datePageDays,
    datePageOutput
}

enum Converter {
    angle,
    area,
    frequency,
    length,
    number,
    pressure,
    temperature,
    time,
    volume,
    weight,
}

enum DateOperations {
    addition,
    subtraction,
    difference
}

enum DatabaseTables {
    basicHistory,
    scientificHistory,
    converterHistory,
    programmerHistory,
    dateHistory
}

enum Radix {
    dec,
    hex,
    oct,
    bin
}

enum NumberType {
    integer,
    float32,
    float64
}