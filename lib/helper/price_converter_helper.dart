import 'package:get/get.dart';

// Project imports:
import 'package:tamam_business/features/splash/controllers/splash_controller.dart';
import 'package:tamam_business/helper/locale_helper.dart';

class PriceConverterHelper {
  static String convertPrice(double? price, {double? discount, String? discountType, int? asFixed}) {
    if(discount != null && discountType != null){
      if(discountType == 'amount') {
        price = price! - discount;
      }else if(discountType == 'percent') {
        price = price! - ((discount / 100) * price);
      }
    }
    
    final symbol = Get.find<SplashController>().configModel!.currencySymbol!;
    final decimals = asFixed ?? Get.find<SplashController>().configModel!.digitAfterDecimalPoint!;
    
    return LocaleHelper.formatCurrency(price, symbol, decimals);
  }

  static double? convertWithDiscount(double? price, double? discount, String? discountType) {
    if(discountType == 'amount') {
      price = price! - discount!;
    }else if(discountType == 'percent') {
      price = price! - ((discount! / 100) * price);
    }
    return price;
  }

  static double calculation(double amount, double? discount, String type, int quantity) {
    double calculatedAmount = 0;
    if(type == 'amount') {
      calculatedAmount = discount! * quantity;
    }else if(type == 'percent') {
      calculatedAmount = (discount! / 100) * (amount * quantity);
    }
    return calculatedAmount;
  }

  static String percentageCalculation(String price, String discount, String discountType) {
    return '$discount${discountType == 'percent' ? '%' : Get.find<SplashController>().configModel!.currencySymbol} OFF';
  }

  static double getStartingPrice(dynamic item) {
    double startingPrice = 0;
    if(item.choiceOptions != null && item.choiceOptions!.isNotEmpty) {
      List<double> priceList = [];
      for(var variation in item.variations!) {
        priceList.add(variation.price!);
      }
      priceList.sort((a, b) => a.compareTo(b));
      startingPrice = priceList[0];
    }else {
      startingPrice = item.price!;
    }
    return startingPrice;
  }
}
