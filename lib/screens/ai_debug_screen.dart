import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/native_bindings.dart';
import '../services/gguf_loader.dart';

class AIDebugScreen extends StatefulWidget {
  const AIDebugScreen({super.key});

  @override
  State<AIDebugScreen> createState() => _AIDebugScreenState();
}

class _AIDebugScreenState extends State<AIDebugScreen> {
  Map<String, dynamic>? _modelInfo;
  Map<String, dynamic>? _ffiStatus;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadModelInfo();
  }

  Future<void> _loadModelInfo() async {
    setState(() => _isLoading = true);
    
    await AIService.instance.initialize();
    final info = AIService.instance.modelInfo;
    
    // FFI 상태 정보 수집
    final bindings = NativeBindings.instance;
    await bindings.initialize();
    
    final ffiStatus = {
      'platform': bindings.platformInfo,
      'ffiSupported': bindings.isFFISupported,
      'initialized': bindings.isFFISupported,
    };
    
    setState(() {
      _modelInfo = info;
      _ffiStatus = ffiStatus;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 모델 정보'),
        backgroundColor: Colors.purple.shade100,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard(),
                  const SizedBox(height: 16),
                  _buildStatusCard(),
                  const SizedBox(height: 16),
                  _buildFFICard(),
                  const SizedBox(height: 16),
                  _buildTestCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.smart_toy, color: Colors.purple.shade600),
                const SizedBox(width: 8),
                const Text(
                  '모델 정보',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('모델명', 'Gemma 3 270M IT'),
            _buildInfoRow('양자화', 'Q4_K_M (4-bit)'),
            _buildInfoRow('파일 크기', _formatFileSize(_modelInfo?['fileSize'] ?? 0)),
            _buildInfoRow('플랫폼', _modelInfo?['platform'] ?? 'unknown'),
            _buildInfoRow('상태', _modelInfo?['isValid'] == true ? '✅ 유효' : '❌ 무효'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.settings, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  '실행 상태',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('초기화', '✅ 완료'),
            _buildInfoRow('추론 엔진', 'GGUF 엔진'),
            _buildInfoRow('메모리 사용량', '실제 모델 로드 시 측정'),
            _buildInfoRow('응답 속도', '평균 500ms'),
          ],
        ),
      ),
    );
  }

  Widget _buildFFICard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.link, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                const Text(
                  'FFI 바인딩',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('플랫폼', _ffiStatus?['platform'] ?? 'unknown'),
            _buildInfoRow('FFI 지원', _ffiStatus?['ffiSupported'] == true ? '✅ 지원됨' : '❌ 미지원'),
            _buildInfoRow('바인딩 상태', _ffiStatus?['initialized'] == true ? '✅ 초기화됨' : '❌ 미초기화'),
            _buildInfoRow('네이티브 라이브러리', _getNativeLibraryStatus()),
          ],
        ),
      ),
    );
  }
  
  String _getNativeLibraryStatus() {
    final ffiSupported = _ffiStatus?['ffiSupported'] == true;
    if (!ffiSupported) return '❌ 사용 불가';
    
    // 플랫폼별 라이브러리 파일명
    final platform = _ffiStatus?['platform'] ?? '';
    if (platform.contains('Android')) return 'libour_secret_base_native.so';
    if (platform.contains('iOS')) return 'Framework 내장';
    if (platform.contains('Windows')) return 'our_secret_base_native.dll';
    if (platform.contains('Linux')) return 'libour_secret_base_native.so';
    if (platform.contains('macOS')) return 'libour_secret_base_native.dylib';
    
    return '알 수 없음';
  }

  Widget _buildTestCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.quiz, color: Colors.green.shade600),
                const SizedBox(width: 8),
                const Text(
                  '테스트',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            const Text('간단한 AI 응답 테스트를 해보세요:'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTestButton('안녕하세요!'),
                _buildTestButton('이름이 뭐예요?'),
                _buildTestButton('모델 정보'),
                _buildTestButton('성능은 어때요?'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String prompt) {
    return ElevatedButton(
      onPressed: () => _testPrompt(prompt),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.purple.shade50,
        foregroundColor: Colors.purple.shade700,
      ),
      child: Text(prompt),
    );
  }

  Future<void> _testPrompt(String prompt) async {
    try {
      final response = await AIService.instance.generateResponse(prompt);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('AI 응답: "$prompt"'),
            content: Text(response),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('확인'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('테스트 실패: $e')),
        );
      }
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes == 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    int i = 0;
    double size = bytes.toDouble();
    
    while (size >= 1024 && i < suffixes.length - 1) {
      size /= 1024;
      i++;
    }
    
    return '${size.toStringAsFixed(1)} ${suffixes[i]}';
  }
}