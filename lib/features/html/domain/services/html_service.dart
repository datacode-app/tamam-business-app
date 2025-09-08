// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/html/domain/repositories/html_repository_interface.dart';
import 'package:tamam_business/features/html/domain/services/html_service_interface.dart';

class HtmlService implements HtmlServiceInterface {
  final HtmlRepositoryInterface htmlRepositoryInterface;
  HtmlService({required this.htmlRepositoryInterface});

  @override
  Future<Response> getHtmlText(bool isPrivacyPolicy) async {
    return await htmlRepositoryInterface.getHtmlText(isPrivacyPolicy);
  }

}
