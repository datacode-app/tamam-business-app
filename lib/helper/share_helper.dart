import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class ShareHelper {
  /// Share content with iOS/iPad compatibility
  /// Handles sharePositionOrigin for iPad requirements and ensures responsiveness
  static Future<void> shareContent({
    required String content,
    String? subject,
    BuildContext? context,
  }) async {
    try {
      if (Platform.isIOS && context != null) {
        // Wait for widget to be fully rendered before sharing
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Get the render box for position origin (critical for iPad)
        final box = context.findRenderObject() as RenderBox?;
        Rect sharePositionOrigin;
        
        if (box != null && box.hasSize) {
          final position = box.localToGlobal(Offset.zero);
          sharePositionOrigin = Rect.fromLTWH(
            position.dx,
            position.dy,
            box.size.width,
            box.size.height,
          );
        } else {
          // Fallback position for iPad - center of screen
          final mediaQuery = MediaQuery.of(context);
          final screenWidth = mediaQuery.size.width;
          final screenHeight = mediaQuery.size.height;
          sharePositionOrigin = Rect.fromLTWH(
            screenWidth * 0.4,
            screenHeight * 0.4,
            screenWidth * 0.2,
            screenHeight * 0.2,
          );
        }

        debugPrint('🍎 iOS Share - Position: $sharePositionOrigin');
        
        await Share.share(
          content,
          subject: subject,
          sharePositionOrigin: sharePositionOrigin,
        );
      } else {
        // Android and other platforms
        await Share.share(
          content,
          subject: subject,
        );
      }
    } catch (e) {
      debugPrint('❌ Share error: $e');
      
      // Enhanced fallback for iPad compatibility
      try {
        if (Platform.isIOS && context != null) {
          // Try without position origin as last resort
          await Share.share(content, subject: subject);
        } else {
          await Share.share(content, subject: subject);
        }
      } catch (fallbackError) {
        debugPrint('❌ Fallback share error: $fallbackError');
        
        // Show user-friendly error on iPad
        if (context != null && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unable to share content. Please try again.'),
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }
  
  /// Enhanced share method with explicit widget context for iPad
  static Future<void> shareFromWidget({
    required String content,
    String? subject,
    required GlobalKey widgetKey,
    BuildContext? context,
  }) async {
    try {
      if (Platform.isIOS) {
        // Wait for any animations to complete
        await Future.delayed(const Duration(milliseconds: 200));
        
        final renderObject = widgetKey.currentContext?.findRenderObject() as RenderBox?;
        
        if (renderObject != null && renderObject.hasSize) {
          final position = renderObject.localToGlobal(Offset.zero);
          final sharePositionOrigin = Rect.fromLTWH(
            position.dx,
            position.dy,
            renderObject.size.width,
            renderObject.size.height,
          );
          
          await Share.share(
            content,
            subject: subject,
            sharePositionOrigin: sharePositionOrigin,
          );
        } else {
          // Fallback to context-based sharing
          await shareContent(
            content: content,
            subject: subject,
            context: context,
          );
        }
      } else {
        await Share.share(content, subject: subject);
      }
    } catch (e) {
      debugPrint('❌ Enhanced share error: $e');
      await shareContent(
        content: content,
        subject: subject,
        context: context,
      );
    }
  }
}
