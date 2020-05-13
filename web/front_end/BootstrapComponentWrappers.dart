import 'dart:html';

///class BootstrapComponentWrappers
///This class contains methods that build certain common Bootstrap components such as rows, cards or containers.
class BootstrapComponentWrappers {
  
  ///buildCentered3ElementsRow()
  ///Builds a row with 3 cols of equal size (col-4) with the contents centered.
  ///@param List<Element> with only 3 of length
  ///@throws Exception if list doesnt have 3 elements.
  static Element buildCentered3ElementsRow(List<Element> elements) {
    if (elements.length > 3) {
      throw Exception('Element list for row has more than 3 elements!');
    }
    Element row = Element.div()..classes.addAll(['row','justify-content-center','align-items-center']);
    for (Element el in elements) {
      Element col = Element.div()..classes.add('col-4');
      col.children.add(el);
      row.children.add(col);
    }
    return row;
  }

}