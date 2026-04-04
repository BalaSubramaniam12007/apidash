import 'package:apidash_design_system/apidash_design_system.dart';
import 'package:flutter/material.dart';
import 'package:json_explorer/json_explorer.dart';

class JsonPreviewerColor {
  const JsonPreviewerColor._();

  static const Color lightRootInfoBox = Color(0x80E1E1E1);
  static const Color lightRootKeyText = Colors.black;
  static const Color lightPropertyKeyText = Colors.black;
  static const Color lightKeySearchHighlightText = Colors.black;
  static const Color lightKeySearchHighlightBackground = Color(0xFFFFEDAD);
  static const Color lightFocusedKeySearchHighlightText = Colors.black;
  static const Color lightFocusedKeySearchHighlightBackground = Color(
    0xFFF29D0B,
  );
  static const Color lightValueText = Color(0xffc41a16);
  static const Color lightValueSearchHighlightText = Color(0xffc41a16);
  static const Color lightValueNum = Color(0xff3F6E74);
  static const Color lightValueBool = Color(0xff1c00cf);
  static const Color lightValueSearchHighlightBackground = Color(0xFFFFEDAD);
  static const Color lightFocusedValueSearchHighlightText = Colors.black;
  static const Color lightFocusedValueSearchHighlightBackground = Color(
    0xFFF29D0B,
  );
  static const Color lightIndentationLineColor = Color.fromARGB(
    255,
    213,
    213,
    213,
  );
  static const Color lightHighlightColor = Color(0xFFF1F1F1);

  static const Color darkRootInfoBox = Color.fromARGB(255, 83, 13, 19);
  static const Color darkRootKeyText = Color(0xffd6deeb);
  static const Color darkPropertyKeyText = Color(0xffd6deeb);
  static const Color darkKeySearchHighlightText = Color(0xffd6deeb);
  static const Color darkKeySearchHighlightBackground = Color(0xff9b703f);
  static const Color darkFocusedKeySearchHighlightText = Color(0xffd6deeb);
  static const Color darkFocusedKeySearchHighlightBackground = Color(
    0xffc41a16,
  );
  static const Color darkValueText = Color(0xffecc48d);
  static const Color darkValueSearchHighlightText = Color(0xffecc48d);
  static const Color darkValueNum = Color(0xffaddb67);
  static const Color darkValueBool = Color(0xff82aaff);
  static const Color darkValueSearchHighlightBackground = Color(0xff9b703f);
  static const Color darkFocusedValueSearchHighlightText = Color(0xffd6deeb);
  static const Color darkFocusedValueSearchHighlightBackground = Color(
    0xffc41a16,
  );
  static const Color darkIndentationLineColor = Color.fromARGB(
    255,
    119,
    119,
    119,
  );
  static const Color darkHighlightColor = Color.fromARGB(255, 55, 55, 55);
}

final JsonExplorerTheme jsonExplorerThemeLight = JsonExplorerTheme(
  rootKeyTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.lightRootKeyText,
    fontWeight: FontWeight.bold,
  ),
  propertyKeyTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.lightPropertyKeyText,
    fontWeight: FontWeight.bold,
  ),
  keySearchHighlightTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.lightKeySearchHighlightText,
    backgroundColor: JsonPreviewerColor.lightKeySearchHighlightBackground,
    fontWeight: FontWeight.bold,
  ),
  focusedKeySearchHighlightTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.lightFocusedKeySearchHighlightText,
    backgroundColor:
        JsonPreviewerColor.lightFocusedKeySearchHighlightBackground,
    fontWeight: FontWeight.bold,
  ),
  valueTextStyle: kCodeStyle.copyWith(color: JsonPreviewerColor.lightValueText),
  valueSearchHighlightTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.lightValueSearchHighlightText,
    backgroundColor: JsonPreviewerColor.lightValueSearchHighlightBackground,
    fontWeight: FontWeight.bold,
  ),
  focusedValueSearchHighlightTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.lightFocusedValueSearchHighlightText,
    backgroundColor:
        JsonPreviewerColor.lightFocusedValueSearchHighlightBackground,
    fontWeight: FontWeight.bold,
  ),
  indentationLineColor: JsonPreviewerColor.lightIndentationLineColor,
  highlightColor: JsonPreviewerColor.lightHighlightColor,
);

final JsonExplorerTheme jsonExplorerThemeDark = JsonExplorerTheme(
  rootKeyTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.darkRootKeyText,
    fontWeight: FontWeight.bold,
  ),
  propertyKeyTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.darkPropertyKeyText,
    fontWeight: FontWeight.bold,
  ),
  keySearchHighlightTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.darkKeySearchHighlightText,
    backgroundColor: JsonPreviewerColor.darkKeySearchHighlightBackground,
    fontWeight: FontWeight.bold,
  ),
  focusedKeySearchHighlightTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.darkFocusedKeySearchHighlightText,
    backgroundColor: JsonPreviewerColor.darkFocusedKeySearchHighlightBackground,
    fontWeight: FontWeight.bold,
  ),
  valueTextStyle: kCodeStyle.copyWith(color: JsonPreviewerColor.darkValueText),
  valueSearchHighlightTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.darkValueSearchHighlightText,
    backgroundColor: JsonPreviewerColor.darkValueSearchHighlightBackground,
    fontWeight: FontWeight.bold,
  ),
  focusedValueSearchHighlightTextStyle: kCodeStyle.copyWith(
    color: JsonPreviewerColor.darkFocusedValueSearchHighlightText,
    backgroundColor:
        JsonPreviewerColor.darkFocusedValueSearchHighlightBackground,
    fontWeight: FontWeight.bold,
  ),
  indentationLineColor: JsonPreviewerColor.darkIndentationLineColor,
  highlightColor: JsonPreviewerColor.darkHighlightColor,
);
