import 'dart:html';

class Footer {



  static Element getFooter() {
    Element footer = Element.footer();
    Element content = Element.div();
    Element text = Element.span();
    footer.classes.addAll(['footer','mt-4','py-3','fixed-bottom']);
    content.classes.add('container');
    text.classes.add('text-muted');
    text.innerText = 'Departamento de Ciências de Computadores - FCUP | Grupo de SE: F J M';
    content.children.add(text);
    footer.children.add(content);
    return footer;
  }
}