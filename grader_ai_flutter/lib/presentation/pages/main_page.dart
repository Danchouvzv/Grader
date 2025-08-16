import 'package:flutter/material.dart';

class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: const TextSpan(
            children: [
              TextSpan(
                text: 'grader',
                style: TextStyle(
                  color: Color(0xFFE53935),
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
              TextSpan(
                text: '.ai',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                ),
              ),
            ],
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
                  tabs: const [
          Tab(
            icon: Icon(Icons.lightbulb_outline),
            text: 'Career Guidance',
          ),
        ],
        ),
      ),
      body: const CareerPagePlaceholder(),
    );
  }
}



class CareerPagePlaceholder extends StatelessWidget {
  const CareerPagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lightbulb_outline,
            size: 64,
            color: Color(0xFFE53935),
          ),
          SizedBox(height: 16),
          Text(
            'Career Guidance',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE53935),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Get personalized career guidance based on your profile and goals',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
