// Package imports:
import 'package:image_picker/image_picker.dart';

// Project imports:
import 'package:tamam_business/api/api_client.dart';
import 'package:tamam_business/features/chat/domain/models/conversation_model.dart';
import 'package:tamam_business/features/chat/domain/models/message_model.dart';
import 'package:tamam_business/features/notification/domain/models/notification_body_model.dart';

abstract class ChatServiceInterface {
  Future<ConversationsModel?> getConversationList(int offset);
  Future<ConversationsModel?> searchConversationList(String name);
  Future<MessageModel?> getMessages(int offset, int? userId, String userType, int? conversationID);
  Future<MessageModel?> sendMessage(String message, List<MultipartBody> images, int? conversationId, int? userId, String userType);
  List<MultipartBody> processMultipartBody(List<XFile> chatImage);
  Future<MessageModel?> processSendMessage(NotificationBodyModel? notificationBody, List<MultipartBody> chatImage, String message, int? conversationId);
  Future<MessageModel?> processGetMessage(int offset, NotificationBodyModel notificationBody, int? conversationID);
}
