import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/supabase_service.dart';
import '../widgets/toast_listener.dart';

class FeedbackDialog extends ConsumerStatefulWidget {
  final String challengeId;
  final String challengeTitle;

  const FeedbackDialog({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
  });

  @override
  ConsumerState<FeedbackDialog> createState() => _FeedbackDialogState();
}

class _FeedbackDialogState extends ConsumerState<FeedbackDialog> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  int _rating = 5;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 500,
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(
                    Icons.feedback_outlined,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Share Your Feedback',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Help us improve "${widget.challengeTitle}"',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Theme.of(context).disabledColor,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Rating Section
              Text(
                'How would you rate this challenge?',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              Row(
                children: List.generate(5, (index) {
                  final starIndex = index + 1;
                  return InkWell(
                    onTap: () => setState(() => _rating = starIndex),
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        starIndex <= _rating ? Icons.star : Icons.star_border,
                        color: starIndex <= _rating
                            ? Colors.amber
                            : Colors.grey,
                        size: 32,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                _getRatingDescription(_rating),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).disabledColor,
                ),
              ),
              const SizedBox(height: 24),

              // Message Section
              Text(
                'Tell us more (optional)',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText:
                      'What did you like or dislike about this challenge? Any suggestions for improvement?',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: Theme.of(context).primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value != null && value.length > 1000) {
                    return 'Feedback must be less than 1000 characters';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitFeedback,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Submit Feedback'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getRatingDescription(int rating) {
    switch (rating) {
      case 1:
        return 'Very poor - Needs major improvements';
      case 2:
        return 'Poor - Several issues to address';
      case 3:
        return 'Okay - Could be better';
      case 4:
        return 'Good - Minor improvements needed';
      case 5:
        return 'Excellent - Great challenge!';
      default:
        return '';
    }
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      final supabaseService = ref.read(supabaseServiceProvider);

      await supabaseService.submitFeedback(
        challengeId: widget.challengeId,
        rating: _rating,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
      );

      if (mounted) {
        Navigator.of(context).pop();
        ref
            .read(toastProvider.notifier)
            .showSuccess('Thank you for your feedback! 🎉');
      }
    } catch (e) {
      if (mounted) {
        ref
            .read(toastProvider.notifier)
            .showError(
              'Failed to submit feedback. Please try again.',
              actionLabel: 'Retry',
              onAction: _submitFeedback,
            );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

// Quick feedback widget for inline use
class QuickFeedbackWidget extends ConsumerWidget {
  final String challengeId;
  final String challengeTitle;

  const QuickFeedbackWidget({
    super.key,
    required this.challengeId,
    required this.challengeTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.feedback_outlined,
            color: Theme.of(context).primaryColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Was this challenge helpful?',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  'Your feedback helps us improve',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).disabledColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: [
              _buildQuickFeedbackButton(
                context,
                ref,
                icon: Icons.thumb_up_outlined,
                label: 'Yes',
                isPositive: true,
              ),
              const SizedBox(width: 8),
              _buildQuickFeedbackButton(
                context,
                ref,
                icon: Icons.thumb_down_outlined,
                label: 'No',
                isPositive: false,
              ),
            ],
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: () => _showFeedbackDialog(context),
            icon: const Icon(Icons.comment_outlined, size: 16),
            label: const Text('Details'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickFeedbackButton(
    BuildContext context,
    WidgetRef ref, {
    required IconData icon,
    required String label,
    required bool isPositive,
  }) {
    return OutlinedButton.icon(
      onPressed: () => _submitQuickFeedback(ref, isPositive),
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        foregroundColor: isPositive ? Colors.green : Colors.red,
        side: BorderSide(color: isPositive ? Colors.green : Colors.red),
      ),
    );
  }

  Future<void> _submitQuickFeedback(WidgetRef ref, bool isPositive) async {
    try {
      final supabaseService = ref.read(supabaseServiceProvider);

      await supabaseService.submitFeedback(
        challengeId: challengeId,
        rating: isPositive ? 5 : 2,
        message: isPositive
            ? 'Quick positive feedback'
            : 'Quick negative feedback',
      );

      ref
          .read(toastProvider.notifier)
          .showSuccess('Thank you for your feedback!');
    } catch (e) {
      ref
          .read(toastProvider.notifier)
          .showError('Failed to submit feedback. Please try again.');
    }
  }

  void _showFeedbackDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => FeedbackDialog(
        challengeId: challengeId,
        challengeTitle: challengeTitle,
      ),
    );
  }
}
