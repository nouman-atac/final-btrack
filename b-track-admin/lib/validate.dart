// ignore_for_file: unused_local_variable

abstract class Validator {
  static String? validateEmail(String? value) {
    var emailRegEx = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    if (value == null || value.isEmpty) {
      return "Please Enter Something";
    } else if (!emailRegEx.hasMatch(value)) {
      return "Please Enter Valid Email";
    } else {
      return null;
    }
  }

  static bool isInteger(String value) {
    try {
      int x = int.parse(value);
    } on FormatException {
      return false;
    } finally {
      return true;
    }
  }
}
