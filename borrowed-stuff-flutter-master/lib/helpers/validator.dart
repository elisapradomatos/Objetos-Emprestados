

class Validator {
  static String isEmptyText(String text) {
    if (text.isEmpty) return 'Campo obrigatório';

    return null;
  }

  static String isEmptyDate(DateTime dateTime) {
    var data = DateTime.now();
    if (dateTime == null) {
      return 'Campo obrigatório';
    }
    else if (dateTime.isBefore(data)){
        return 'Data inválida';
    }
      return null;
    }

 static String validateMobile(String value) {
    if (value.length > 15) {
      return 'Digite um número válido';
    }
    else if (value.length == 0) {
      return 'Campo obrigatório';
    }
    return null;
  }

}
