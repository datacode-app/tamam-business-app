// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/features/notification/domain/models/notification_body_model.dart';
import 'package:tamam_business/features/rental_module/chat/domain/models/taxi_conversation_model.dart';
import 'package:tamam_business/features/rental_module/chat/domain/models/taxi_message_model.dart';

abstract class TaxiChatServiceInterface {
  Future<TaxiConversationsModel?> getConversationList(int offset);
  Future<TaxiConversationsModel?> searchConversationList(String name);
  Future<TaxiMessageModel?> getMessages(int offset, int? userId, String userType, int? conversationID);
  Future<TaxiMessageModel?> sendMessage(String message, List<MultipartBody> images, int? conversationId, int? userId, String userType);
  List<MultipartBody> processMultipartBody(List<XFile> chatImage);
  Future<TaxiMessageModel?> processSendMessage(NotificationBodyModel? notificationBody, List<MultipartBody> chatImage, String message, int? conversationId);
  Future<TaxiMessageModel?> processGetMessage(int offset, NotificationBodyModel notificationBody, int? conversationID);
}
