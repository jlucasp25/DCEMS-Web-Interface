import 'dart:convert';
import 'dart:html';

class LoginPanel {
  InputElement usernameInput;
  PasswordInputElement passwordInput;
  SubmitButtonInputElement submitButton;
  Element panel;

  LoginPanel() {
    _buildLoginPanel();
    submitButton.onClick.listen(loginRequest);
  }

  Element getLoginPanel() {
    return panel;
  }

  void _buildLoginPanel() {
    Element wrapperRow = Element.div()..classes.addAll(['row','justify-content-center','align-items-center','text-center']);
    Element card = Element.div()..classes.addAll(['card','w-25']);
    Element header = Element.div()..classes.add('card-header');
    Element body = _buildLoginBody();
    header.innerText = 'Entrada';
    card.children.addAll([header,body]);
    wrapperRow.children.add(card);
    panel = wrapperRow;
  }

  Element _buildLoginBody() {
    Element form = Element.tag('form')..attributes.addAll({'action':'http://localhost:8500/login/','method':'POST'});
    form.classes.addAll(['form']);
    Element unameLabel = Element.tag('label')..classes.add('m-2')..innerText = 'Utilizador';
    usernameInput = Element.tag('input')..classes.add('m-2')..attributes.addAll({'type':'text'});
    usernameInput.id = 'uname_input';
    Element pswLabel = Element.tag('label')..classes.add('m-2')..innerText = 'Senha de acesso';
    passwordInput = Element.tag('input')..classes.add('m-2')..attributes.addAll({'type':'password'});
    passwordInput.id = 'psw_input';
    submitButton = Element.tag('input')..classes.addAll(['m-2','btn','btn-dark'])..attributes.addAll({'type':'submit'});
    form.children.addAll([unameLabel,usernameInput,Element.br(),pswLabel,passwordInput,Element.br(),submitButton]);
    return form;
  }

  Map<String,String> _parseForm() {
    var jsonObj = {
      'username': usernameInput.value,
      'password': passwordInput.value
    };
    return jsonObj;
  }

  Future<void> loginRequest(Event _) async {
    Map<String,String> jsonString = _parseForm();
    const path = './login/';
    try {
      final response = await HttpRequest.postFormData(path,jsonString);
      parseResponse(response);
    }
    catch (e) {
      throw Exception('Exception: Error on login request!');
    }
  }

  void parseResponse(HttpRequest response) {

  }

}