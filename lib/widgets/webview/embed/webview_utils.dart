import 'package:flutter/cupertino.dart';
import 'package:sirc/utils/logger.dart';

/*
* @description: TODO
*
* @author: jixiaoyong
* @email: jixiaoyong1995@gmail.com
* @date: 2021/11/30
*/
class WebViewUtils {
  // The design draft is 375 px wide
  static const design_width = 375;

  // When the design draft is 375 px wide, the corresponding font size is calculated as follows:
  // 100vw / 375px = fontSizeVw / uiFontSizePx
  static const String font_size = "4.5vw";

  static const String KeyWebBackgroundColor = "{{webBackgroundColor}}";
  static const String KeyLineHeight = "{{lineHeight}}";

  static const String webContentPrefix =
      r"""<html><head><meta http-equiv="Content-Type" content="text/html; charset=utf-8" /> 
                
                <style> 
               p{font-size:45pt;font-weight:normal;color: #949098;line-height:120%; margin:0px 0  }
               span{font-size:45pt;}
               * {
                        margin: 0px;
                        padding: 0px;
                        border: 0px
                }

               body, div, dl, dt, dd, ul, ol, li, h1, h2, h3, h4, h5, h6, pre, code, form, fieldset, legend, input, textarea, p, blockquote, th, td, hr, button, article, aside, details, figcaption, figure, footer, header, hgroup, menu, nav,
                section {
                        margin: 0;
                        padding: 0;
                        background:{{webBackgroundColor}};
                }
               </style> 
                </head> 
                <body> 
               <table id="webContent" style="width:100%;height: min-content;overflow:hidden;border:none"><tr><td style="vertical-align:middle;">
               <span   style="color:#949098">""";
  static const String webContentSuffix = r"""</span>
               </td></tr></table>
               <script type="text/javascript">
     var tables = document.getElementsByTagName('table');
       for(var i = 0; i<tables.length; i++){
              tables[i].style.width = '100%';
         }

         var ps = document.getElementsByTagName('p');
       for(var i = 0; i<ps.length; i++){
              ps[i].style.lineHeight = '{{lineHeight}}';
              ps[i].style.wordBreak = 'break-all';
              ps[i].style.fontSize = '4.4vw';
         }
         
        <!--${EXPAND_IMG_WIDTH_JS}-->
         
             var spans = document.getElementsByTagName('span');
    console.log('span：', spans);
    for (var i = 0; i < spans.length; i++) {
      if (!spans[i].style.color) {

        if (spans[i].parentElement.nodeName == "SPAN") {
          console.log('span：', spans[i]);
          var parentColor = spans[i].parentElement.style.color;
          if (parentColor) {
            spans[i].style.color = parentColor;
          } else {
            spans[i].style.color = '#949098';
          }
        }
      }
    }
  </script>
               </body> 
               </html>""";

  static const String expandImageSize =
      """var imgTag = document.getElementsByTagName('img');
       for(var i = 0; i<imgTag.length; i++){
              imgTag[i].style.width = '100%';
              imgTag[i].style.height = 'auto';
         }""";

  static String getWebContent(String content, int targetWidthPx,
      {String? fontSize,
      String? backgroundColor,
      String? lineHeight,
      bool forceExpandImageWidget = false}) {
    String contentFormatted;
    try {
      contentFormatted = Uri.decodeFull(content);
    } catch (e) {
      contentFormatted = content;
      LogUtils.e(e);
    }

    var localFontSize = fontSize;
    if (fontSize == null || fontSize.isEmpty) {
      localFontSize = font_size;
    }

    String _webContentSuffix = webContentSuffix;
    if (forceExpandImageWidget) {
      _webContentSuffix =
          "".replaceAll(r"<!--${EXPAND_IMG_WIDTH_JS}-->", expandImageSize);
    }

    var webContentPrefixFormatted = webContentPrefix.replaceAll(
        KeyWebBackgroundColor, backgroundColor ?? "#ffffff");
    return (webContentPrefixFormatted +
            contentFormatted +
            _webContentSuffix.replaceAll(KeyLineHeight, lineHeight ?? "1.8em"))
        .replaceAll(
            RegExp("font-size:[ ]*[0-9]*px"), "font-size:$localFontSize ")
        .replaceAll(
            RegExp("font-size:[ ]*[0-9]*pt"), "font-size:$localFontSize ")
        .replaceAll(
            RegExp("fontSize[ ]*=[ ]*'[0-9]*px'"), "fontSize='$localFontSize' ")
        .replaceAll(RegExp("fontSize[ ]*=[ ]*'[0-9]*pt'"),
            "fontSize='$localFontSize' ");
  }

  static String delHtml(String content, double width, BuildContext context,
      {String? fontSize}) {
    var widthPx = width * MediaQuery.of(context).devicePixelRatio;
    return getWebContent(content, widthPx.toInt(), fontSize: fontSize);
  }
}
