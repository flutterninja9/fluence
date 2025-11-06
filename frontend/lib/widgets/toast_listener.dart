import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ToastType { success, error, warning, info }

class ToastMessage {
  final String message;
  final ToastType type;
  final Duration duration;
  final String? actionLabel;
  final VoidCallback? onAction;

  const ToastMessage({
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 4),
    this.actionLabel,
    this.onAction,
  });
}

// Toast notification provider
final toastProvider = StateNotifierProvider<ToastNotifier, ToastMessage?>((
  ref,
) {
  return ToastNotifier();
});

class ToastNotifier extends StateNotifier<ToastMessage?> {
  ToastNotifier() : super(null);

  void showSuccess(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    state = ToastMessage(
      message: message,
      type: ToastType.success,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showError(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    state = ToastMessage(
      message: message,
      type: ToastType.error,
      duration: const Duration(seconds: 6),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showWarning(
    String message, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    state = ToastMessage(
      message: message,
      type: ToastType.warning,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void showInfo(String message, {String? actionLabel, VoidCallback? onAction}) {
    state = ToastMessage(
      message: message,
      type: ToastType.info,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  void clearToast() {
    state = null;
  }
}

// Toast listener widget
class ToastListener extends ConsumerWidget {
  final Widget child;

  const ToastListener({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<ToastMessage?>(toastProvider, (previous, current) {
      if (current != null) {
        _showToast(context, current, ref);
      }
    });

    return child;
  }

  void _showToast(BuildContext context, ToastMessage toast, WidgetRef ref) {
    final messenger = ScaffoldMessenger.of(context);

    // Clear any existing snackbars
    messenger.clearSnackBars();

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(_getIconForType(toast.type), color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              toast.message,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: _getColorForType(toast.type),
      duration: toast.duration,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      action: toast.actionLabel != null && toast.onAction != null
          ? SnackBarAction(
              label: toast.actionLabel!,
              textColor: Colors.white,
              onPressed: toast.onAction!,
            )
          : null,
      onVisible: () {
        // Auto-clear the toast from state after showing
        Future.delayed(toast.duration, () {
          ref.read(toastProvider.notifier).clearToast();
        });
      },
    );

    messenger.showSnackBar(snackBar);
  }

  IconData _getIconForType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Icons.check_circle;
      case ToastType.error:
        return Icons.error;
      case ToastType.warning:
        return Icons.warning;
      case ToastType.info:
        return Icons.info;
    }
  }

  Color _getColorForType(ToastType type) {
    switch (type) {
      case ToastType.success:
        return Colors.green;
      case ToastType.error:
        return Colors.red;
      case ToastType.warning:
        return Colors.orange;
      case ToastType.info:
        return Colors.blue;
    }
  }
}
