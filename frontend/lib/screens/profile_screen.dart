import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/user.dart';
import '../providers/progress_providers.dart';
import '../services/supabase_service.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supabaseService = ref.watch(supabaseServiceProvider);
    final user = supabaseService.currentUser;
    final userProgressAsync = ref.watch(userProgressProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.blue,
                          child: Text(
                            (user?.email?.substring(0, 1).toUpperCase() ?? 'U'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back!',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                user?.email ?? 'No email',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              const SizedBox(height: 8),
                              const Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  SizedBox(width: 4),
                                  Text('Free Plan'),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Progress Overview
            userProgressAsync.when(
              loading: () => const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              error: (error, stack) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 48),
                      const SizedBox(height: 8),
                      Text('Failed to load progress: $error'),
                    ],
                  ),
                ),
              ),
              data: (progress) => _buildProgressCard(context, progress),
            ),

            const SizedBox(height: 16),

            // Quick Actions
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.list, color: Colors.blue),
                    title: const Text('View Challenges'),
                    subtitle: const Text('Browse and solve coding challenges'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => context.go('/challenges'),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.history, color: Colors.green),
                    title: const Text('Submission History'),
                    subtitle: const Text('View your past submissions'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Submission history coming soon!'),
                        ),
                      );
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.upgrade, color: Colors.purple),
                    title: const Text('Upgrade to Pro'),
                    subtitle: const Text('Unlock premium features'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Upgrade feature coming soon!'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Sign Out Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await supabaseService.signOut();
                  if (context.mounted) {
                    context.go('/auth');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Sign Out'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, UserProgress progress) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Progress Overview',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            // Progress Stats Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Solved',
                    progress.totalChallengesSolved.toString(),
                    Icons.check_circle,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    context,
                    'Streak',
                    '${progress.streakDays} days',
                    Icons.local_fire_department,
                    Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Difficulty Breakdown
            Text(
              'By Difficulty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            _buildDifficultyRow(
              'Easy',
              progress.easyChallengesSolved,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildDifficultyRow(
              'Medium',
              progress.mediumChallengesSolved,
              Colors.orange,
            ),
            const SizedBox(height: 8),
            _buildDifficultyRow(
              'Hard',
              progress.hardChallengesSolved,
              Colors.red,
            ),

            if (progress.lastSubmissionAt != null) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    'Last active: ${_formatDateTime(progress.lastSubmissionAt!)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }

  Widget _buildDifficultyRow(String difficulty, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(difficulty),
        const Spacer(),
        Text(
          count.toString(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
