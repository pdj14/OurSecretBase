import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hideout_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const WelcomeHomeView(),
    const FriendsView(),
    const HideoutListView(),
    const ProfileView(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: '우리들의아지트'),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '홈',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: '친구들',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fort),
            label: '비밀기지',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '프로필',
          ),
        ],
      ),
    );
  }
}

class HideoutListView extends StatelessWidget {
  const HideoutListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '나의 비밀기지',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 3,
              itemBuilder: (context, index) {
                return HideoutCard(
                  title: '비밀기지 ${index + 1}',
                  description: '친구들과 함께하는 특별한 공간',
                  memberCount: 5 + index,
                  onTap: () {
                    // 비밀기지 상세 화면으로 이동
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class FriendsView extends StatelessWidget {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('친구들 화면'),
    );
  }
}

class WelcomeHomeView extends StatelessWidget {
  const WelcomeHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            // 메인 일러스트레이션
            Container(
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.yellow.shade50,
                    Colors.orange.shade50,
                    Colors.pink.shade50,
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade100.withOpacity(0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // 배경 패턴
                  Positioned.fill(
                    child: CustomPaint(
                      painter: TreeHousePainter(),
                    ),
                  ),
                  // 중앙 텍스트
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.home_work,
                          size: 80,
                          color: Colors.orange.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '우리들의 비밀기지',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // 환영 메시지
            Text(
              '어서와! 🌟',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.orange.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '어렸을 적 친구들과 함께 만들었던\n그 특별한 공간을 기억하나요?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey.shade500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // 기능 카드들
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    context,
                    Icons.group,
                    '함께하기',
                    '친구들과 추억 만들기',
                    Colors.blue.shade100,
                    Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFeatureCard(
                    context,
                    Icons.favorite,
                    '소중한 순간',
                    '따뜻한 기억 간직하기',
                    Colors.pink.shade100,
                    Colors.pink.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildFeatureCard(
                    context,
                    Icons.games,
                    '재미있는 놀이',
                    '즐거운 시간 보내기',
                    Colors.green.shade100,
                    Colors.green.shade600,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildFeatureCard(
                    context,
                    Icons.auto_stories,
                    '이야기 나누기',
                    '소중한 대화하기',
                    Colors.purple.shade100,
                    Colors.purple.shade600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            
            // 시작하기 버튼
            Container(
              width: double.infinity,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.orange.shade300, Colors.yellow.shade300],
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.orange.shade200.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  // 비밀기지 탭으로 이동
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
                child: const Text(
                  '비밀기지 만들러 가기 🏠',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String title, 
      String subtitle, Color bgColor, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 32, color: iconColor),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: iconColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class TreeHousePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.orange.shade100.withOpacity(0.2)
      ..style = PaintingStyle.fill;

    // 간단한 나무집 모양 그리기
    final path = Path();
    
    // 집 지붕
    path.moveTo(size.width * 0.3, size.height * 0.3);
    path.lineTo(size.width * 0.5, size.height * 0.2);
    path.lineTo(size.width * 0.7, size.height * 0.3);
    
    // 집 몸체
    path.lineTo(size.width * 0.7, size.height * 0.5);
    path.lineTo(size.width * 0.3, size.height * 0.5);
    path.close();
    
    canvas.drawPath(path, paint);
    
    // 나무 줄기
    final trunkPaint = Paint()
      ..color = Colors.brown.shade200.withOpacity(0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.45, size.height * 0.5, size.width * 0.1, size.height * 0.3),
      trunkPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('프로필 화면'),
    );
  }
}