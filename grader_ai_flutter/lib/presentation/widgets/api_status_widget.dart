import 'package:flutter/material.dart';
import '../../core/config/api_config.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';

class ApiStatusWidget extends StatelessWidget {
  const ApiStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: AppColors.cardShadow,
        border: Border.all(
          color: ApiConfig.isOpenAiConfigured 
              ? AppColors.success.withOpacity(0.3)
              : AppColors.error.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ApiConfig.isOpenAiConfigured 
                    ? Icons.check_circle_rounded 
                    : Icons.error_rounded,
                color: ApiConfig.isOpenAiConfigured 
                    ? AppColors.success 
                    : AppColors.error,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'API Status',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatusRow(
            'OpenAI API',
            ApiConfig.isOpenAiConfigured,
            ApiConfig.isOpenAiConfigured 
                ? 'Key: ${ApiConfig.openAiApiKey.substring(0, 8)}...'
                : 'Not configured',
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'Google Cloud',
            ApiConfig.isGoogleCloudConfigured,
            ApiConfig.isGoogleCloudConfigured 
                ? 'Project: ${ApiConfig.googleCloudProjectId}'
                : 'Not configured (optional)',
          ),
          const SizedBox(height: 8),
          _buildStatusRow(
            'Backend API',
            ApiConfig.isBackendConfigured,
            ApiConfig.backendApiUrl,
          ),
          
          if (!ApiConfig.isOpenAiConfigured) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.warning.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Setup Required',
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add your OpenAI API key to env.dev file:\nOPENAI_API_KEY=your_key_here',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isConfigured, String detail) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isConfigured ? Icons.check : Icons.close,
          color: isConfigured ? AppColors.success : AppColors.error,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                detail,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontFamily: 'monospace',
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
