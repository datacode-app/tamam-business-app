// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_esc_pos_utils/flutter_esc_pos_utils.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:screenshot/screenshot.dart';

// Project imports:
import 'package:tamam_business/common/widgets/custom_button_widget.dart';
import 'package:tamam_business/common/widgets/custom_snackbar_widget.dart';
import 'package:tamam_business/features/language/controllers/language_controller.dart';
import 'package:tamam_business/features/order/controllers/order_controller.dart';
import 'package:tamam_business/features/order/domain/models/order_details_model.dart';
import 'package:tamam_business/features/order/domain/models/order_model.dart';
import 'package:tamam_business/features/order/widgets/invoice_dialog_widget.dart';
import 'package:tamam_business/features/profile/controllers/profile_controller.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class InVoicePrintScreen extends StatefulWidget {
  final OrderModel? order;
  final List<OrderDetailsModel>? orderDetails;
  final bool? isPrescriptionOrder;
  final double dmTips;
  const InVoicePrintScreen({super.key, required this.order, required this.orderDetails, this.isPrescriptionOrder = false, required this.dmTips});

  @override
  State<InVoicePrintScreen> createState() => _InVoicePrintScreenState();
}

class _InVoicePrintScreenState extends State<InVoicePrintScreen> {
  bool connected = false;
  List<BluetoothInfo>? availableBluetoothDevices;
  bool _isLoading = false;
  final List<int> _paperSizeList = [80, 58];
  int _selectedSize = 58;
  ScreenshotController screenshotController = ScreenshotController();
  String? _warningMessage;
  
  // Print mode configuration - change this to switch between text and image printing
  static const bool USE_TEXT_BASED_PRINTING = true; // Set to false to use original screenshot method

  Future<void> getBluetooth() async {
    setState(() {
      _isLoading = true;
    });

    final List<BluetoothInfo> bluetoothDevices = await PrintBluetoothThermal.pairedBluetooths;
    if (kDebugMode) {
      print("Bluetooth list: $bluetoothDevices");
    }
    connected = await PrintBluetoothThermal.connectionStatus;

    if(!connected) {
      _warningMessage = null;
      Get.find<OrderController>().setBluetoothMacAddress('');
    } else {
      _warningMessage = 'please_enable_your_location_and_bluetooth_in_your_system'.tr;
    }

    setState(() {
      availableBluetoothDevices = bluetoothDevices;
      _isLoading = false;
    });

  }

  Future<void> setConnect(String mac) async {
    final bool result = await PrintBluetoothThermal.connect(macPrinterAddress: mac);

    if (result) {
      setState(() {
        connected = true;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    getBluetooth();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future _printReceipt(Uint8List screenshot) async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      List<int> ticket = await testTicket(screenshot);
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      if (kDebugMode) {
        print("print result: $result");
      }
    } else {
      showCustomSnackBar('no_thermal_printer_connected'.tr);
    }
  }

  // TEXT-BASED PRINTING METHOD
  Future _printReceiptTextMode() async {
    bool connectionStatus = await PrintBluetoothThermal.connectionStatus;
    if (connectionStatus) {
      List<int> ticket = await _generateTextBasedTicket();
      final result = await PrintBluetoothThermal.writeBytes(ticket);
      if (kDebugMode) {
        print("text-based print result: $result");
      }
    } else {
      showCustomSnackBar('no_thermal_printer_connected'.tr);
    }
  }

  // TEXT-BASED PRINTING - Matching original invoice design
  Future<List<int>> _generateTextBasedTicket() async {
    List<int> bytes = [];
    final profile = await CapabilityProfile.load();
    final generator = Generator(_selectedSize == 80 ? PaperSize.mm80 : PaperSize.mm58, profile);

    try {
      // Get store info (like original invoice)
      String storeName = 'Store';
      String storeAddress = '';
      String storePhone = '';
      String storeEmail = '';
      
      try {
        var store = Get.find<ProfileController>().profileModel?.stores?.first;
        if (store != null) {
          storeName = store.name ?? 'Store';
          storeAddress = store.address ?? '';
          storePhone = store.phone ?? '';
          storeEmail = store.email ?? '';
        }
      } catch (e) {
        if (kDebugMode) print('Store info not available: $e');
      }

      // Store Header (matching original design)
      bytes += generator.text(storeName, styles: const PosStyles(align: PosAlign.center, bold: true, height: PosTextSize.size2));
      if (storeAddress.isNotEmpty) {
        bytes += generator.text(storeAddress, styles: const PosStyles(align: PosAlign.center));
      }
      if (storePhone.isNotEmpty) {
        bytes += generator.text(storePhone, styles: const PosStyles(align: PosAlign.center));
      }
      if (storeEmail.isNotEmpty) {
        bytes += generator.text(storeEmail, styles: const PosStyles(align: PosAlign.center));
      }
      
      bytes += generator.feed(1);
      
      // Order Info (matching original layout)
      bytes += generator.row([
        PosColumn(text: 'Order ID:', width: 4, styles: const PosStyles(bold: false)),
        PosColumn(text: '${widget.order?.id ?? 'N/A'}', width: 4, styles: const PosStyles(bold: true)),
        PosColumn(text: _formatDate(widget.order?.createdAt), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      if (widget.order?.scheduled == 1 && widget.order?.scheduleAt != null) {
        bytes += generator.text('Scheduled: ${_formatDate(widget.order!.scheduleAt!)}', styles: const PosStyles(align: PosAlign.left));
      }
      
      bytes += generator.row([
        PosColumn(text: widget.order?.orderType?.toUpperCase() ?? 'DELIVERY', width: 6),
        PosColumn(text: widget.order?.paymentMethod?.toUpperCase() ?? 'CASH', width: 6, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      // Dotted line separator
      bytes += generator.text('-' * (_selectedSize == 80 ? 48 : 32), styles: const PosStyles(align: PosAlign.center));
      
      // Customer Info (if available)
      if (widget.order?.deliveryAddress?.contactPersonName != null) {
        bytes += generator.text(widget.order!.deliveryAddress!.contactPersonName!, styles: const PosStyles(bold: true));
        if (widget.order!.deliveryAddress!.address != null) {
          String address = widget.order!.deliveryAddress!.address!;
          bytes += generator.text(address, styles: const PosStyles());
        }
      }
      
      bytes += generator.text('-' * (_selectedSize == 80 ? 48 : 32), styles: const PosStyles(align: PosAlign.center));
      
      // Items
      for (var detail in widget.orderDetails ?? []) {
        String itemName = detail.itemDetails?.name ?? 'Item';
        if (itemName.length > 24) itemName = '${itemName.substring(0, 21)}...';
        
        double itemTotal = (detail.price ?? 0) * (detail.quantity ?? 1);
        
        bytes += generator.row([
          PosColumn(text: itemName, width: 8, styles: const PosStyles(bold: true)),
          PosColumn(text: 'x${detail.quantity}', width: 2, styles: const PosStyles(align: PosAlign.center)),
          PosColumn(text: _formatPrice(itemTotal), width: 2, styles: const PosStyles(align: PosAlign.right)),
        ]);
        
        // Add-ons (matching original indentation)
        for (var addon in detail.addOns ?? []) {
          bytes += generator.row([
            PosColumn(text: '  +${addon.name ?? 'Add-on'}', width: 8),
            PosColumn(text: 'x${addon.quantity}', width: 2, styles: const PosStyles(align: PosAlign.center)),
            PosColumn(text: _formatPrice((addon.price ?? 0) * (addon.quantity ?? 1)), width: 2, styles: const PosStyles(align: PosAlign.right)),
          ]);
        }
      }
      
      bytes += generator.text('-' * (_selectedSize == 80 ? 48 : 32), styles: const PosStyles(align: PosAlign.center));
      
      // Totals (matching original calculation)
      double itemsPrice = 0;
      double addOns = 0;
      
      if (widget.isPrescriptionOrder == true) {
        double orderAmount = widget.order?.orderAmount ?? 0;
        double discount = widget.order?.storeDiscountAmount ?? 0;
        double tax = widget.order?.totalTaxAmount ?? 0;
        double deliveryCharge = widget.order?.deliveryCharge ?? 0;
        itemsPrice = (orderAmount + discount) - (tax + deliveryCharge);
      } else {
        for (var detail in widget.orderDetails ?? []) {
          for (var addon in detail.addOns ?? []) {
            addOns += (addon.price ?? 0) * (addon.quantity ?? 1);
          }
          itemsPrice += (detail.price ?? 0) * (detail.quantity ?? 1);
        }
      }
      
      bytes += generator.row([
        PosColumn(text: 'Item Price', width: 8),
        PosColumn(text: _formatPrice(itemsPrice), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      if (addOns > 0) {
        bytes += generator.row([
          PosColumn(text: 'Addons', width: 8),
          PosColumn(text: _formatPrice(addOns), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      bytes += generator.row([
        PosColumn(text: 'Subtotal', width: 8),
        PosColumn(text: _formatPrice(itemsPrice + addOns), width: 4, styles: const PosStyles(align: PosAlign.right)),
      ]);
      
      if ((widget.order?.storeDiscountAmount ?? 0) > 0) {
        bytes += generator.row([
          PosColumn(text: 'Store Discount(-)', width: 8),
          PosColumn(text: _formatPrice(widget.order!.storeDiscountAmount!), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      if ((widget.order?.couponDiscountAmount ?? 0) > 0) {
        bytes += generator.row([
          PosColumn(text: 'Coupon Discount(-)', width: 8),
          PosColumn(text: _formatPrice(widget.order!.couponDiscountAmount!), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      if ((widget.order?.totalTaxAmount ?? 0) > 0) {
        bytes += generator.row([
          PosColumn(text: 'Tax(+)', width: 8),
          PosColumn(text: _formatPrice(widget.order!.totalTaxAmount!), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      if ((widget.order?.deliveryCharge ?? 0) > 0) {
        bytes += generator.row([
          PosColumn(text: 'Delivery Fee', width: 8),
          PosColumn(text: _formatPrice(widget.order!.deliveryCharge!), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      if (widget.dmTips > 0) {
        bytes += generator.row([
          PosColumn(text: 'DM Tips', width: 8),
          PosColumn(text: _formatPrice(widget.dmTips), width: 4, styles: const PosStyles(align: PosAlign.right)),
        ]);
      }
      
      bytes += generator.text('=' * (_selectedSize == 80 ? 48 : 32), styles: const PosStyles(align: PosAlign.center));
      
      // Total (matching original calculation)
      double total = (widget.order?.orderAmount ?? 0) + widget.dmTips;
      bytes += generator.row([
        PosColumn(text: 'TOTAL', width: 8, styles: const PosStyles(bold: true, height: PosTextSize.size2)),
        PosColumn(text: _formatPrice(total), width: 4, styles: const PosStyles(bold: true, align: PosAlign.right, height: PosTextSize.size2)),
      ]);
      
      bytes += generator.feed(2);
      bytes += generator.text('Thank you!', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.feed(3);
      
    } catch (e) {
      if (kDebugMode) {
        print('Error generating text-based ticket: $e');
      }
      // Fallback to basic receipt
      bytes += generator.text('Receipt', styles: const PosStyles(align: PosAlign.center, bold: true));
      bytes += generator.text('Order #${widget.order?.id ?? 'N/A'}');
      bytes += generator.text('Total: ${_formatPrice((widget.order?.orderAmount ?? 0) + widget.dmTips)}');
      bytes += generator.feed(3);
    }
    
    return bytes;
  }
  
  String _formatDate(String? dateTime) {
    if (dateTime == null) return '';
    try {
      DateTime dt = DateTime.parse(dateTime);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTime;
    }
  }
  
  String _formatPrice(double price) {
    return price.toStringAsFixed(2);
  }

  Future<List<int>> testTicket(Uint8List screenshot) async {
    List<int> bytes = [];
    final img.Image? image = img.decodeImage(screenshot);
    
    // Try different widths for better quality
    int targetWidth = _selectedSize == 80 ? 640 : 420; // Slightly higher resolution
    img.Image resized = img.copyResize(image!, width: targetWidth);
    
    final profile = await CapabilityProfile.load();
    final generator = Generator(_selectedSize == 80 ? PaperSize.mm80 : PaperSize.mm58, profile);

    // Using `ESC *`
    bytes += generator.image(resized);

    bytes += generator.feed(2);
    // bytes += generator.cut();
    return bytes;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeDefault, vertical: Dimensions.paddingSizeDefault),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(children: [
                Text('paired_bluetooth'.tr, style: robotoMedium.copyWith(fontSize: Dimensions.fontSizeLarge)),
                const SizedBox(width: Dimensions.paddingSizeSmall),

                SizedBox(height: 20, width: 20,
                  child: _isLoading ?  CircularProgressIndicator(
                    color: Theme.of(context).primaryColor,
                  ) : InkWell(
                    onTap: () => getBluetooth(),
                    child: Icon(Icons.refresh, color: Theme.of(context).primaryColor),
                  ),
                ),
              ]),

              SizedBox(width: 100, child: DropdownButton<int>(
                hint: Text('select'.tr),
                value: _selectedSize,
                items: _paperSizeList.map((int? value) {
                  return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value''mm'));
                }).toList(),
                onChanged: (int? value) {
                  setState(() {
                    _selectedSize = value!;
                  });
                },
                isExpanded: true, underline: const SizedBox(),
              )),

            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            child: Column(children: [
              availableBluetoothDevices != null && (availableBluetoothDevices?.length ?? 0) > 0 ? ListView.builder(
                itemCount: availableBluetoothDevices?.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return GetBuilder<OrderController>(
                      builder: (orderController) {
                        bool isConnected = connected &&  availableBluetoothDevices![index].macAdress == orderController.getBluetoothMacAddress();

                        return Stack(children: [

                          ListTile(
                            selected: isConnected,
                            onTap: () {
                              if(availableBluetoothDevices?[index].macAdress.isNotEmpty ?? false) {
                                if(!connected) {
                                  orderController.setBluetoothMacAddress(availableBluetoothDevices?[index].macAdress);
                                }
                                setConnect(availableBluetoothDevices?[index].macAdress ?? '');
                              }
                            },
                            title: Text(availableBluetoothDevices?[index].name ?? ''),
                            subtitle: Text(
                              isConnected ? 'connected'.tr : "click_to_connect".tr,
                              style: robotoRegular.copyWith(color: isConnected ? null : Theme.of(context).primaryColor),
                            ),
                          ),

                          if(availableBluetoothDevices?[index].macAdress == orderController.getBluetoothMacAddress())
                            Positioned.fill(
                              child: Align(alignment: Get.find<LocalizationController>().isLtr ? Alignment.centerRight : Alignment.centerLeft, child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: Dimensions.paddingSizeExtraSmall,
                                  horizontal: Dimensions.paddingSizeLarge,
                                ),
                                child: Icon(Icons.check_circle_outline_outlined, color: Theme.of(context).primaryColor,),
                              )),
                            ),
                        ],
                        );
                      }
                  );
                }) : Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall),
                child: Text(
                  _warningMessage?? '',
                  style: robotoRegular.copyWith(color: Colors.redAccent),
                ),
              ),

              InvoiceDialogWidget(
                order: widget.order, orderDetails: widget.orderDetails, isPrescriptionOrder: widget.isPrescriptionOrder,
                paper80MM: _selectedSize == 80, dmTips: widget.dmTips,
                screenshotController: screenshotController,
              ),
            ]),
          ),
        ),

        CustomButtonWidget(
          buttonText: 'print_invoice'.tr, 
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: Dimensions.paddingSizeSmall, vertical: Dimensions.paddingSizeExtraSmall),
          onPressed: () {
            if (USE_TEXT_BASED_PRINTING) {
              // Direct text-based printing - no screenshot needed
              _printReceiptTextMode();
            } else {
              // Original screenshot-based printing
              screenshotController.capture(
                delay: const Duration(milliseconds: 50),
                pixelRatio: 2.0,
              ).then((Uint8List? capturedImage) {
                if (kDebugMode) {
                  print('Captured Image:  $capturedImage');
                }
                _printReceipt(capturedImage!);
              }).catchError((onError) {
                if (kDebugMode) {
                  print(onError);
                }
              });
            }
          },
        ),

      ],
    );
    // return _searchingMode ? SingleChildScrollView(
    //   padding: const EdgeInsets.all(Dimensions.fontSizeLarge),
    //   child: Column(
    //     mainAxisSize: MainAxisSize.min,
    //     children: [
    //
    //       Text('paper_size'.tr, style: robotoMedium),
    //       Row(children: [
    //         Expanded(child: RadioListTile(
    //           title: Text('80_mm'.tr),
    //           groupValue: _paper80MM,
    //           dense: true,
    //           contentPadding: EdgeInsets.zero,
    //           value: true,
    //           onChanged: (bool? value) {
    //             _paper80MM = true;
    //             setState(() {});
    //           },
    //         )),
    //         Expanded(child: RadioListTile(
    //           title: Text('58_mm'.tr),
    //           groupValue: _paper80MM,
    //           contentPadding: EdgeInsets.zero,
    //           dense: true,
    //           value: false,
    //           onChanged: (bool? value) {
    //             _paper80MM = false;
    //             setState(() {});
    //           },
    //         )),
    //       ]),
    //       const SizedBox(height: Dimensions.paddingSizeSmall),
    //
    //       ListView.builder(
    //         itemCount: _devices.length,
    //         shrinkWrap: true,
    //         physics: const NeverScrollableScrollPhysics(),
    //         itemBuilder: (context, index) {
    //           return Padding(
    //             padding: const EdgeInsets.only(bottom: Dimensions.paddingSizeSmall),
    //             child: InkWell(
    //               onTap: () {
    //                 _selectDevice(_devices[index]);
    //                 setState(() {
    //                   _searchingMode = false;
    //                 });
    //               },
    //               child: Stack(children: [
    //
    //                 Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    //
    //                   Text(_devices[index].name),
    //
    //                   Visibility(
    //                     visible: !Platform.isWindows,
    //                     child: Text(_devices[index].macAdress),
    //                   ),
    //
    //                   index != _devices.length-1 ? Divider(color: Theme.of(context).disabledColor) : const SizedBox(),
    //
    //                 ]),
    //
    //                 (_selectedPrinter != null && _selectedPrinter!.macAdress == _devices[index].macAdress) ? const Positioned(
    //                   top: 5, right: 5,
    //                   child: Icon(Icons.check, color: Colors.green),
    //                 ) : const SizedBox(),
    //
    //               ]),
    //             ),
    //           );
    //         },
    //       ),
    //     ],
    //   ),
    // ) : InvoiceDialogWidget(
    //   order: widget.order, orderDetails: widget.orderDetails, isPrescriptionOrder: widget.isPrescriptionOrder,
    //   onPrint: (i.Image? image) => _printReceipt(image!), paper80MM: _paper80MM, dmTips: widget.dmTips,
    // );
  }
}
