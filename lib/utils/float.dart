import 'dart:typed_data';

String floatToBinary(double number, int bits) {
    if (bits != 32 && bits != 64) {
        throw Exception("Invalid number of bits. Only 32 or 64 bits are supported.");
    }

    // Create a ByteData buffer with the specified number of bits
    var buffer = ByteData(bits ~/ 8);

    // Put the float number in the buffer
    if (bits == 32) {
        buffer.setFloat32(0, number);
    } else {
        buffer.setFloat64(0, number);
    }

    // Convert the buffer to a list of integers
    var bytes = buffer.buffer.asUint8List();

    // Convert each byte to a binary string and concatenate them
    var binary = '';
    for (var i = 0; i < bytes.length; i++) {
        var byte = bytes[i];
        var binaryByte = byte.toRadixString(2).padLeft(8, '0');
        binary += binaryByte;
    }

    return binary;
}

String binaryToFloat(String binary) {
    if (binary.length != 32 && binary.length != 64) {
        throw Exception("Invalid binary string length. Only 32 or 64 bits are supported.");
    }

    // Convert the binary string to a list of bytes
    var bytes = <int>[];
    for (var i = 0; i < binary.length; i += 8) {
        var byte = binary.substring(i, i + 8);
        bytes.add(int.parse(byte, radix: 2));
    }

    // Create a ByteData buffer with the bytes
    var buffer = ByteData.view(Uint8List.fromList(bytes).buffer);

    // Get the float value from the buffer
    if (binary.length == 32) {
        return buffer.getFloat32(0).toString();
    } else {
        return buffer.getFloat64(0).toString();
    }
}
