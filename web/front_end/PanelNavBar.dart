import 'dart:html';

///class PanelNavBar
///This class aggregates all the functions that build the main navbar of the webapp.
class PanelNavBar {

  //Properties
  //The navbar links and labels are stored as static final because they are immutable.
  static final Map<String,String> _links = {
      'Entrada': 'dashboard.html',
      'Dispositivos': 'devices.html',
      'Regras': 'rules.html'
    };
  
  ///getPanelNavBar()
  ///Returns a DOM element of the main navbar.
  static Element getPanelNavBar() {
    Element nav = Element.nav();
    nav.classes.addAll(['navbar','navbar-expand-lg','navbar-light','bg-light','border']);
    nav.children.add(_buildLeftNavBarContents());
    nav.children.add(_buildCenterNavBarContents());
    nav.children.add(_buildRightNavBarContents());
    return nav;
  }

  ///_buildLeftNavBarContents()
  ///Builds the contents of the left side of the navbar.
  static Element _buildLeftNavBarContents() {
    Element div = Element.div();
    div.classes.addAll(['navbar-collapse','collapse','w-100','order-1','order-md-0','dual-collapse2']);
    Element ul = Element.ul()..classes.addAll(['navbar-nav','mr-auto']);
    _links.forEach( (key,val) {
      Element li = Element.li()..classes.add('nav-item');
      Element a = Element.a()..classes.add('nav-link');
      a.attributes.addAll({'href':val});
      a.innerHtml = key;
      li.children.add(a);
      ul.children.add(li);
    });
    div.children.add(ul);
    return div;
  }

  ///_buildCenterNavBarContents()
  ///Builds the contents of the center side of the navbar.
  static Element _buildCenterNavBarContents() {
    Element div = Element.div();
    div.classes.addAll(['mx-auto','order-0']);
    Element a = Element.a()..classes.addAll(['navbar-brand','mx-auto']);
    a.attributes.addAll({'href':'#'});
    a.innerHtml = 'Painel de controlo';
    div.children.add(a);
    return div;
  }

  ///_buildRightNavBarContents()
  ///Builds the contents of the right side of the navbar.
  static Element _buildRightNavBarContents() {
    Element div = Element.div();
    div.classes.addAll(['navbar-collapse','collapse','w-100','order-3','dual-collapse2']);
    Element ul = Element.ul()..classes.addAll(['navbar-nav','ml-auto']);
    Map<String,String> rightLinks = {
      'LogOut': 'logout.html',
    };
    rightLinks.forEach( (key,val) {
      Element li = Element.li()..classes.add('nav-item');
      Element a = Element.a()..classes.add('nav-link');
      a.attributes.addAll({'href':val});
      a.innerHtml = key;
      li.children.add(a);
      ul.children.add(li);
    });
    div.children.add(ul);
    return div;
  }

}