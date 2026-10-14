import '../../../core/format/phone.dart';

/// How the user signs in on the login form: a Turkmen phone number or an email.
enum LoginMethod { phone, email }

final _email = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// The `login` sent to the API (`+993XXXXXXXX`, or the email in lower case), or null while [text] is not
/// a valid phone or email yet.
String? loginOf(LoginMethod method, String text) => switch (method) {
  LoginMethod.phone => tmPhone(text),
  LoginMethod.email => _email.hasMatch(text.trim()) ? text.trim().toLowerCase() : null,
};
