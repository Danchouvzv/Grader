import 'package:flutter/material.dart';
import '../../features/ielts/data/ielts_topics_manager.dart';
import '../../features/ielts/models/ielts_speaking_test.dart';
import '../../shared/themes/app_colors.dart';
import '../../shared/themes/app_typography.dart';
import 'ielts_speaking_test_page.dart';

class IeltsTopicsPage extends StatefulWidget {
  const IeltsTopicsPage({super.key});

  @override
  State<IeltsTopicsPage> createState() => _IeltsTopicsPageState();
}

class _IeltsTopicsPageState extends State<IeltsTopicsPage> {
  String _selectedDifficulty = 'All';
  String _selectedCategory = 'All';
  final TextEditingController _searchController = TextEditingController();
  List<IeltsSpeakingTest> _filteredTopics = [];
  List<IeltsSpeakingTest> _allTopics = [];

  @override
  void initState() {
    super.initState();
    _loadTopics();
    _searchController.addListener(_filterTopics);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTopics() {
    _allTopics = IeltsTopicsManager.getAllTopics();
    _filteredTopics = List.from(_allTopics);
  }

  void _filterTopics() {
    setState(() {
      _filteredTopics = _allTopics.where((topic) {
        // Фильтр по поиску
        final searchQuery = _searchController.text.toLowerCase();
        final matchesSearch = searchQuery.isEmpty ||
            topic.title.toLowerCase().contains(searchQuery) ||
            topic.description.toLowerCase().contains(searchQuery) ||
            topic.tags.any((tag) => tag.toLowerCase().contains(searchQuery));

        // Фильтр по сложности
        final matchesDifficulty = _selectedDifficulty == 'All' ||
            topic.difficulty == _selectedDifficulty;

        // Фильтр по категории
        final matchesCategory = _selectedCategory == 'All' ||
            topic.tags.contains(_selectedCategory);

        return matchesSearch && matchesDifficulty && matchesCategory;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'IELTS Speaking Topics',
          style: AppTypography.headlineLarge.copyWith(color: AppColors.textPrimary),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Поиск и фильтры
          _buildSearchAndFilters(),
          
          // Статистика
          _buildStatistics(),
          
          // Список топиков
          Expanded(
            child: _filteredTopics.isEmpty
                ? _buildEmptyState()
                : _buildTopicsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Поиск
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search topics...',
              prefixIcon: Icon(Icons.search, color: AppColors.textSecondary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColors.primary, width: 2),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Фильтры
          Row(
            children: [
              Expanded(
                child: _buildFilterDropdown(
                  value: _selectedDifficulty,
                  items: ['All', 'Easy', 'Medium', 'Hard'],
                  label: 'Difficulty',
                  onChanged: (value) {
                    setState(() {
                      _selectedDifficulty = value!;
                      _filterTopics();
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildFilterDropdown(
                  value: _selectedCategory,
                  items: [
                    'All',
                    'family',
                    'technology',
                    'environment',
                    'education',
                    'travel',
                    'work',
                    'health',
                  ],
                  label: 'Category',
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                      _filterTopics();
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String value,
    required List<String> items,
    required String label,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(
          value: item,
          child: Text(item),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildStatistics() {
    final stats = IeltsTopicsManager.getTopicsStatistics();
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Total Topics',
            '${stats['totalTopics']}',
            Icons.topic,
          ),
          _buildStatItem(
            'Easy',
            '${stats['difficultyDistribution']['Easy'] ?? 0}',
            Icons.sentiment_satisfied,
            color: Colors.green,
          ),
          _buildStatItem(
            'Medium',
            '${stats['difficultyDistribution']['Medium'] ?? 0}',
            Icons.sentiment_neutral,
            color: Colors.orange,
          ),
          _buildStatItem(
            'Hard',
            '${stats['difficultyDistribution']['Hard'] ?? 0}',
            Icons.sentiment_dissatisfied,
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? AppColors.primary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.headlineMedium.copyWith(
            color: color ?? AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTopicsList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredTopics.length,
      itemBuilder: (context, index) {
        final topic = _filteredTopics[index];
        return _buildTopicCard(topic);
      },
    );
  }

  Widget _buildTopicCard(IeltsSpeakingTest topic) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _startTest(topic),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Заголовок и сложность
                Row(
                  children: [
                    Expanded(
                      child:                       Text(
                        topic.title,
                        style: AppTypography.headlineMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildDifficultyBadge(topic.difficulty),
                  ],
                ),
                
                const SizedBox(height: 8),
                
                // Описание
                Text(
                  topic.description,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Детали
                Row(
                  children: [
                    _buildDetailItem(
                      Icons.timer,
                      '${topic.totalDuration} min',
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      Icons.assignment,
                      '${topic.parts.length} parts',
                    ),
                    const SizedBox(width: 16),
                    _buildDetailItem(
                      Icons.question_answer,
                      '${topic.parts.fold(0, (sum, part) => sum + part.questions.length)} questions',
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Теги
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: topic.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 16),
                
                // Кнопка начала
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _startTest(topic),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.play_arrow),
                        const SizedBox(width: 8),
                        Text(
                          'Start Test',
                          style: AppTypography.labelLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty) {
    Color color;
    IconData icon;
    
    switch (difficulty) {
      case 'Easy':
        color = Colors.green;
        icon = Icons.sentiment_satisfied;
        break;
      case 'Medium':
        color = Colors.orange;
        icon = Icons.sentiment_neutral;
        break;
      case 'Hard':
        color = Colors.red;
        icon = Icons.sentiment_dissatisfied;
        break;
      default:
        color = AppColors.textSecondary;
        icon = Icons.help;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            difficulty,
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 16,
          color: AppColors.textSecondary,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No topics found',
            style: AppTypography.headlineMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
                      Text(
              'Try adjusting your search or filters',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
        ],
      ),
    );
  }

  void _startTest(IeltsSpeakingTest topic) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => IeltsSpeakingTestPage(test: topic),
      ),
    );
  }
}
