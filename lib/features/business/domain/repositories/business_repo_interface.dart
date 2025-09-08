// Package imports:
import 'package:get/get_connect/connect.dart';

// Project imports:
import 'package:tamam_business/features/business/domain/models/business_plan_body.dart';
import 'package:tamam_business/interface/repository_interface.dart';

abstract class BusinessRepoInterface<T> implements RepositoryInterface<T> {
  Future<Response> setUpBusinessPlan(BusinessPlanBody businessPlanBody);
}
