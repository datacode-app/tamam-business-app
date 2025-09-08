// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:tamam_business/features/store/domain/models/attr.dart';

class AttributeModel {
  Attr attribute;
  bool active;
  TextEditingController controller;
  List<String> variants;

  AttributeModel({required this.attribute, required this.active, required this.controller, required this.variants});
}
