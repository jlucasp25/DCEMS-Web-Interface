import 'dart:html';

///class SearchPanel
///Contains methods to build the search panel on the device listing.
class SearchPanel {
  
  ///buildSearchPanel()
  ///Builds the search panel as a DOM element.
  static Element buildSearchPanel() {
    //Builds trigger button
    Element trigger = Element.a()..classes.addAll(['btn','btn-dark','mt-2','mb-2']);
    trigger.attributes.addAll({'data-toggle':'collapse','href':'#search-collapse','role':'button','aria-expanded':'false','aria-controls':'search-collapse'});
    trigger.innerText = 'Pesquisa de dispositivos';
    //Builds collapse div wrapper
    Element collapseWrapper = Element.div()..classes.add('collapse');
    collapseWrapper.id = 'search-collapse';
    //Builds div for content
    Element div = Element.div()..classes.addAll(['w-25']);
    Element searchBox = Element.tag('input')..classes.addAll(['form-control','mt-2','mb-2','w-100']);
    searchBox.attributes.addAll({'type':'text','aria-describedby':"device-search",'placeholder':"Introduza o nome ou endereço IP do dispositivo..."});
    //Nests elements
    div.children.addAll([searchBox]);
    collapseWrapper.children.add(div);
    //Returns invisible wrapper with all the elements.
    return Element.div()..children.addAll([trigger,collapseWrapper]);
  }

}