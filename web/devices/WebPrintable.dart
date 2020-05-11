import 'dart:html';

///Abstract Class/Interface WebPrintable
///Classes implementing WebPrintable need to implements a method to display their information as HTML elements.
abstract class WebPrintable {
  Element printToHTML();
}