import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:tamam_business/helper/developer_config_helper.dart';
import 'package:tamam_business/helper/remote_config_helper.dart';
import 'package:tamam_business/util/dimensions.dart';
import 'package:tamam_business/util/styles.dart';

class DeveloperSettingsDialog extends StatefulWidget {
  const DeveloperSettingsDialog({super.key});

  @override
  State<DeveloperSettingsDialog> createState() => _DeveloperSettingsDialogState();
}

class _DeveloperSettingsDialogState extends State<DeveloperSettingsDialog> {
  bool _developerMode = false;
  String _currentUrl = '';
  Map<String, dynamic> _configValues = {};

  @override
  void initState() {
    super.initState();
    _loadDeveloperStatus();
  }

  Future<void> _loadDeveloperStatus() async {
    final status = await DeveloperConfigHelper.getDeveloperStatus();
    setState(() {
      _developerMode = status['developer_mode'] ?? false;
      _currentUrl = status['effective_url'] ?? '';
      _configValues = status['remote_config_values'] ?? {};
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Dimensions.radiusDefault)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(Dimensions.paddingSizeDefault),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Icon(Icons.developer_mode, color: Colors.orange, size: 24),
                const SizedBox(width: 8),
                Text('Developer Settings', style: robotoMedium.copyWith(
                  fontSize: Dimensions.fontSizeLarge,
                  color: Theme.of(context).primaryColor,
                )),
                const Spacer(),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(),
            
            // Developer Mode Toggle
            ListTile(
              leading: Icon(
                _developerMode ? Icons.toggle_on : Icons.toggle_off,
                color: _developerMode ? Colors.green : Colors.grey,
                size: 32,
              ),
              title: Text('Developer Mode', style: robotoMedium),
              subtitle: Text(_developerMode ? 'Using Development Server' : 'Using Production Server'),
              onTap: () async {
                await DeveloperConfigHelper.setDeveloperMode(!_developerMode);
                await _loadDeveloperStatus();
                HapticFeedback.lightImpact();
              },
            ),
            
            // Current URL Info
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Current Backend URL:', style: robotoMedium.copyWith(fontSize: 12)),
                  const SizedBox(height: 4),
                  SelectableText(
                    _currentUrl,
                    style: robotoRegular.copyWith(
                      fontSize: 11,
                      color: Theme.of(context).primaryColor,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Available URLs Section
            Text('Available URLs:', style: robotoMedium),
            const SizedBox(height: 8),
            
            ..._configValues.entries.where((entry) => entry.key.contains('backend_base_url')).map((entry) {
              final isActive = entry.value == _currentUrl;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isActive ? Theme.of(context).primaryColor.withOpacity(0.1) : null,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isActive ? Theme.of(context).primaryColor : Theme.of(context).dividerColor,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isActive ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                      color: isActive ? Theme.of(context).primaryColor : Colors.grey,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key.replaceAll('backend_base_url', '').replaceAll('_', ' ').trim().toUpperCase(),
                            style: robotoMedium.copyWith(fontSize: 11),
                          ),
                          SelectableText(
                            entry.value.toString(),
                            style: robotoRegular.copyWith(
                              fontSize: 10,
                              color: Colors.grey[600],
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            
            const SizedBox(height: 16),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await RemoteConfigHelper.forceRefresh();
                      await _loadDeveloperStatus();
                      HapticFeedback.lightImpact();
                    },
                    icon: const Icon(Icons.refresh, size: 16),
                    label: Text('Refresh Config', style: robotoMedium.copyWith(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).cardColor,
                      foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await DeveloperConfigHelper.resetDeveloperMode();
                      await _loadDeveloperStatus();
                      HapticFeedback.lightImpact();
                    },
                    icon: const Icon(Icons.clear, size: 16),
                    label: Text('Reset', style: robotoMedium.copyWith(fontSize: 12)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.withOpacity(0.1),
                      foregroundColor: Colors.red,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Close Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
                child: Text('Close', style: robotoMedium),
              ),
            ),
          ],
        ),
      ),
    );
  }
}