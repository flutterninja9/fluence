import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/challenge.dart';
import '../providers/challenge_providers.dart';

class ChallengeListScreen extends ConsumerStatefulWidget {
  const ChallengeListScreen({super.key});

  @override
  ConsumerState<ChallengeListScreen> createState() => _ChallengeListScreenState();
}

class _ChallengeListScreenState extends ConsumerState<ChallengeListScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    // Load challenges when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChallenges();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadChallenges() {
    final filters = ref.read(challengeFiltersProvider);
    ref.read(challengeListProvider.notifier).loadChallenges(filters);
  }

  @override
  Widget build(BuildContext context) {
    final challengeListAsync = ref.watch(challengeListProvider);
    final filters = ref.watch(challengeFiltersProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Challenges'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(120),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Search bar
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search challenges...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _updateFilters(filters.copyWith(search: ''));
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onChanged: (value) {
                    _updateFilters(filters.copyWith(search: value));
                  },
                ),
                const SizedBox(height: 12),
                
                // Filter chips
                Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildDifficultyFilter(filters),
                            const SizedBox(width: 8),
                            _buildCategoryFilter(filters),
                            const SizedBox(width: 8),
                            _buildPremiumFilter(filters),
                            const SizedBox(width: 8),
                            if (_hasActiveFilters(filters))
                              ActionChip(
                                label: const Text('Clear All'),
                                onPressed: () {
                                  _updateFilters(const ChallengeFilters());
                                  _searchController.clear();
                                },
                                backgroundColor: Colors.red.withAlpha(20),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      body: challengeListAsync.when(
        data: (challengeList) => _buildChallengeList(challengeList),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => _buildErrorState(error),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadChallenges,
        tooltip: 'Refresh',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildDifficultyFilter(ChallengeFilters filters) {
    return PopupMenuButton<DifficultyLevel?>(
      child: Chip(
        label: Text(filters.difficulty?.name.toUpperCase() ?? 'DIFFICULTY'),
        avatar: Icon(
          Icons.tune,
          size: 16,
          color: filters.difficulty != null 
            ? Theme.of(context).primaryColor 
            : null,
        ),
        backgroundColor: filters.difficulty != null 
          ? Theme.of(context).primaryColor.withAlpha(20)
          : null,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: null,
          child: Text('All Difficulties'),
        ),
        ...DifficultyLevel.values.map((difficulty) => PopupMenuItem(
          value: difficulty,
          child: Row(
            children: [
              Icon(
                Icons.circle,
                size: 12,
                color: _getDifficultyColor(difficulty),
              ),
              const SizedBox(width: 8),
              Text(difficulty.name.toUpperCase()),
            ],
          ),
        )),
      ],
      onSelected: (difficulty) {
        _updateFilters(filters.copyWith(difficulty: difficulty));
      },
    );
  }

  Widget _buildCategoryFilter(ChallengeFilters filters) {
    return PopupMenuButton<ChallengeCategory?>(
      child: Chip(
        label: Text(filters.category?.name.toUpperCase() ?? 'CATEGORY'),
        avatar: Icon(
          Icons.category,
          size: 16,
          color: filters.category != null 
            ? Theme.of(context).primaryColor 
            : null,
        ),
        backgroundColor: filters.category != null 
          ? Theme.of(context).primaryColor.withAlpha(20)
          : null,
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: null,
          child: Text('All Categories'),
        ),
        ...ChallengeCategory.values.map((category) => PopupMenuItem(
          value: category,
          child: Text(category.name.toUpperCase()),
        )),
      ],
      onSelected: (category) {
        _updateFilters(filters.copyWith(category: category));
      },
    );
  }

  Widget _buildPremiumFilter(ChallengeFilters filters) {
    return FilterChip(
      label: const Text('PREMIUM ONLY'),
      selected: filters.isPremium == true,
      onSelected: (selected) {
        _updateFilters(filters.copyWith(isPremium: selected ? true : null));
      },
      avatar: Icon(
        Icons.star,
        size: 16,
        color: filters.isPremium == true 
          ? Colors.amber 
          : null,
      ),
      selectedColor: Colors.amber.withAlpha(20),
    );
  }

  Widget _buildChallengeList(ChallengeList challengeList) {
    if (challengeList.challenges.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context).disabledColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No challenges found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters or search terms',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).disabledColor,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Results summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            border: Border(
              bottom: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: Row(
            children: [
              Text(
                '${challengeList.total} challenges found',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                'Page ${challengeList.page} of ${(challengeList.total / challengeList.perPage).ceil()}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),

        // Challenge list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: challengeList.challenges.length,
            itemBuilder: (context, index) {
              final challenge = challengeList.challenges[index];
              return _buildChallengeCard(challenge);
            },
          ),
        ),

        // Pagination
        if (challengeList.hasNext || challengeList.hasPrev)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: _buildPagination(challengeList),
          ),
      ],
    );
  }

  Widget _buildChallengeCard(Challenge challenge) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          context.push('/challenges/${challenge.id}');
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with badges
              Row(
                children: [
                  _buildDifficultyBadge(challenge.difficulty),
                  const SizedBox(width: 8),
                  _buildCategoryBadge(challenge.category),
                  const Spacer(),
                  if (challenge.isPremium)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PREMIUM',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title
              Text(
                challenge.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              // Description preview
              Text(
                challenge.description.length > 120 
                  ? '${challenge.description.substring(0, 120)}...'
                  : challenge.description,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),

              // Footer
              Row(
                children: [
                  Icon(
                    Icons.code,
                    size: 16,
                    color: Theme.of(context).disabledColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Dart',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      context.push('/challenges/${challenge.id}');
                    },
                    child: const Text('Solve Challenge'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(DifficultyLevel difficulty) {
    final color = _getDifficultyColor(difficulty);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        border: Border.all(color: color),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        difficulty.name.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildCategoryBadge(ChallengeCategory category) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withAlpha(20),
        border: Border.all(color: Theme.of(context).primaryColor),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.name.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildPagination(ChallengeList challengeList) {
    final filters = ref.read(challengeFiltersProvider);
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: challengeList.hasPrev 
            ? () => _changePage(filters.page - 1)
            : null,
          child: const Text('Previous'),
        ),
        const SizedBox(width: 16),
        Text(
          'Page ${challengeList.page}',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: challengeList.hasNext 
            ? () => _changePage(filters.page + 1)
            : null,
          child: const Text('Next'),
        ),
      ],
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load challenges',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).disabledColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadChallenges,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(DifficultyLevel difficulty) {
    switch (difficulty) {
      case DifficultyLevel.easy:
        return Colors.green;
      case DifficultyLevel.medium:
        return Colors.orange;
      case DifficultyLevel.hard:
        return Colors.red;
    }
  }

  bool _hasActiveFilters(ChallengeFilters filters) {
    return filters.difficulty != null ||
           filters.category != null ||
           filters.isPremium != null ||
           (filters.search != null && filters.search!.isNotEmpty);
  }

  void _updateFilters(ChallengeFilters newFilters) {
    ref.read(challengeFiltersProvider.notifier).state = newFilters;
    ref.read(challengeListProvider.notifier).loadChallenges(newFilters);
  }

  void _changePage(int page) {
    final currentFilters = ref.read(challengeFiltersProvider);
    final newFilters = currentFilters.copyWith(page: page);
    _updateFilters(newFilters);
  }
}