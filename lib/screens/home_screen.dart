import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/hideout_card.dart';
import 'chat_screen.dart';
import 'ai_debug_screen.dart';

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
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 10),
            // 메인 이미지 - 모바일에 최적화된 크기
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orange.shade200.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/우리들의아지트.png',
                    height: 200,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      // 이미지가 없을 경우 대체 위젯
                      return Container(
                        width: 250,
                        height: 200,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.orange.shade100,
                              Colors.pink.shade50,
                              Colors.purple.shade50,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.home_work,
                                size: 60,
                                color: Colors.orange,
                              ),
                              SizedBox(height: 12),
                              Text(
                                '우리들의 비밀기지',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.brown,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                '이미지를 추가해주세요',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // 환영 메시지
            Text(
              '어서와! 🌟',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.orange.shade400,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '어렸을 적 친구들과 함께 만들었던\n그 특별한 공간을 기억하나요?',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            
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
            const SizedBox(height: 12),
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
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ChatScreen(),
                        ),
                      );
                    },
                    child: _buildFeatureCard(
                      context,
                      Icons.chat_bubble,
                      '지키미와 대화하기',
                      '친근한 AI와 채팅하기',
                      Colors.purple.shade100,
                      Colors.purple.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: bgColor.withOpacity(0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: iconColor),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: iconColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: iconColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '설정',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 20),
          
          // AI 디버그 정보 카드
          Card(
            child: ListTile(
              leading: Icon(Icons.smart_toy, color: Colors.purple.shade600),
              title: const Text('AI 모델 정보'),
              subtitle: const Text('Gemma 모델 상태 및 디버그 정보'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AIDebugScreen(),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 채팅 바로가기 카드
          Card(
            child: ListTile(
              leading: Icon(Icons.chat, color: Colors.blue.shade600),
              title: const Text('지키미와 채팅'),
              subtitle: const Text('AI 어시스턴트와 대화하기'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ChatScreen(),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 앱 정보 카드
          Card(
            child: ListTile(
              leading: Icon(Icons.info, color: Colors.green.shade600),
              title: const Text('앱 정보'),
              subtitle: const Text('버전 1.0.0 - OnDevice AI 지원'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: '우리들의아지트',
                  applicationVersion: '1.0.0',
                  applicationIcon: Icon(
                    Icons.home_work,
                    size: 48,
                    color: Colors.orange.shade400,
                  ),
                  children: [
                    const Text('친구들과 함께하는 특별한 공간'),
                    const SizedBox(height: 8),
                    const Text('• OnDevice AI (Gemma 3 270M)'),
                    const Text('• 완전한 오프라인 동작'),
                    const Text('• 개인정보 보호 보장'),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}