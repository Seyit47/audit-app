/// An IMEI is 15 digits whose last digit is a Luhn check digit, so most typos are caught before registering.
bool isValidImei(String imei) {
  if (!RegExp(r'^\d{15}$').hasMatch(imei)) return false;
  var sum = 0;
  for (var i = 0; i < 15; i++) {
    var d = imei.codeUnitAt(i) - 48;
    if (i.isOdd) {
      d *= 2;
      if (d > 9) d -= 9;
    }
    sum += d;
  }
  return sum % 10 == 0;
}

/// "356938035643809" → "35 693803 564380 9", grouped as phones show it (TAC, serial, check digit).
String formatImei(String imei) {
  if (imei.length != 15) return imei;
  return '${imei.substring(0, 2)} ${imei.substring(2, 8)} ${imei.substring(8, 14)} ${imei.substring(14)}';
}
