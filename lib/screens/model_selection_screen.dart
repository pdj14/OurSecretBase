import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../services/model_manager.dart';
import '../services/ai_service.dart';

class ModelSelectionScreen extends StatefulWidget {
  const ModelSelectionScreen({super.key});

  @override
  State<ModelSelectionScreen> createState() => _ModelSelectionScreenState();
}

class _ModelSelectionScreenState extends State<ModelSelectionScreen> {
  List<ModelInfo> _availableModels = [];
  String? _selectedModelPath;
  String? _currentModelPath;
  bool _isLoading = true;
  bool _isChangingModel = false;
  bool _hasStoragePermission = false;

  @override
  void initState() {
    super.initState();
    _loadModels();
  }

  Future<void> _loadModels() async {
    setState(() => _isLoading = true);
    
    try {
      // 권한 확인
      final hasPermission = await ModelManager.requestStoragePermission();
      
      // 모든 경로에서 모델 찾기
      final availableModelsMap = await ModelManager.getAvailableModels();
      final models = <ModelInfo>[];
      
      // 각 경로의 모델을 ModelInfo로 변환
      for (final entry in availableModelsMap.entries) {
        final path = entry.value;
        if (path != null) {
          try {
            if (path.startsWith('assets://')) {
              // Assets 모델
              models.add(ModelInfo(
                name: 'Gemma 3 270M IT (기본 모델)',
                path: path,
                size: 0, // Assets 파일 크기는 런타임에 확인 어려움
                formattedSize: '270MB (추정)',
                architecture: 'Gemma',
                quantization: 'Q4_K_M',
              ));
            } else {
              // 파일 시스템 모델
              final file = File(path);
              if (await file.exists()) {
                final stat = await file.stat();
                final name = path.split('/').last;
                
                models.add(ModelInfo(
                  name: name,
                  path: path,
                  size: stat.size,
                  formattedSize: ModelManager.formatFileSize(stat.size),
                  architecture: ModelManager.guessArchitecture(name),
                  quantization: ModelManager.guessQuantization(name),
                ));
              }
            }
          } catch (e) {
            print('모델 정보 읽기 실패: $path - $e');
          }
        }
      }
      
      // AiModels 폴더의 추가 모델들도 스캔
      final aiModels = await ModelManager.scanForModels();
      for (final model in aiModels) {
        // 중복 제거 (같은 경로가 이미 있으면 제외)
        if (!models.any((m) => m.path == model.path)) {
          models.add(model);
        }
      }
      
      final currentModel = await ModelManager.getCurrentModel();
      
      setState(() {
        _hasStoragePermission = hasPermission;
        _availableModels = models;
        _currentModelPath = currentModel?.path;
        _selectedModelPath = currentModel?.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모델 스캔 실패: $e')),
        );
      }
    }
  }

  Future<void> _selectModel(String modelPath) async {
    if (_isChangingModel) return;
    
    setState(() => _isChangingModel = true);
    
    try {
      await ModelManager.setCurrentModel(modelPath);
      await AIService.instance.reinitialize();
      
      setState(() {
        _currentModelPath = modelPath;
        _selectedModelPath = modelPath;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('모델이 성공적으로 변경되었습니다!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('모델 변경 실패: $e')),
        );
      }
    } finally {
      setState(() => _isChangingModel = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 모델 선택'),
        backgroundColor: Colors.purple.shade100,
        actions: [
          IconButton(
            onPressed: _loadModels,
            icon: const Icon(Icons.refresh),
            tooltip: '새로고침',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildInfoCard(),
                Expanded(child: _buildModelList()),
                _buildActionButtons(),
              ],
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                const Text(
                  '모델 폴더 위치',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              ModelManager.getModelsDirectory(),
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontFamily: 'monospace',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '위 폴더에 .gguf 파일을 넣으면 자동으로 감지됩니다.',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 8),
            // 권한 상태 표시
            Row(
              children: [
                Icon(
                  _hasStoragePermission ? Icons.check_circle : Icons.warning,
                  color: _hasStoragePermission ? Colors.green : Colors.orange,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _hasStoragePermission ? '저장소 권한: 허용됨' : '저장소 권한: 필요함',
                  style: TextStyle(
                    fontSize: 12,
                    color: _hasStoragePermission ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModelList() {
    if (_availableModels.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_open,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '사용 가능한 모델이 없습니다',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '모델 폴더에 .gguf 파일을 추가해주세요',
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _availableModels.length,
      itemBuilder: (context, index) {
        final model = _availableModels[index];
        final isSelected = model.path == _selectedModelPath;
        final isCurrent = model.path == _currentModelPath;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: isSelected ? Colors.purple.shade50 : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isCurrent 
                  ? Colors.green.shade100 
                  : Colors.grey.shade100,
              child: Icon(
                isCurrent ? Icons.check_circle : Icons.smart_toy,
                color: isCurrent ? Colors.green : Colors.grey.shade600,
              ),
            ),
            title: Text(
              model.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('크기: ${model.formattedSize}'),
                if (model.architecture != null)
                  Text('아키텍처: ${model.architecture}'),
                if (isCurrent)
                  Text(
                    '현재 사용 중',
                    style: TextStyle(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            trailing: isSelected && !isCurrent
                ? Icon(Icons.radio_button_checked, color: Colors.purple.shade600)
                : const Icon(Icons.radio_button_unchecked),
            onTap: () {
              setState(() => _selectedModelPath = model.path);
            },
          ),
        );
      },
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _selectedModelPath != null && 
                         _selectedModelPath != _currentModelPath &&
                         !_isChangingModel
                  ? () => _selectModel(_selectedModelPath!)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: _isChangingModel
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('선택한 모델 사용하기'),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: _showHelpDialog,
                  icon: const Icon(Icons.help_outline),
                  label: const Text('모델 추가 방법'),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: _showPermissionGuide,
                  icon: const Icon(Icons.settings),
                  label: const Text('권한 설정'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('모델 추가 방법'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '1. 모델 파일 준비',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('• GGUF 형식의 모델 파일 (.gguf)'),
              const Text('• Gemma, Llama, Qwen 등 지원'),
              const SizedBox(height: 12),
              const Text(
                '2. 파일 복사',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('다음 폴더에 모델 파일을 복사하세요:'),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  ModelManager.getModelsDirectory(),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '3. 새로고침',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text('파일 복사 후 새로고침 버튼을 눌러주세요.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showPermissionGuide() {
    final guide = ModelManager.getPermissionGuide();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('권한 설정 가이드'),
        content: SingleChildScrollView(
          child: Text(guide),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

class ModelInfo {
  final String name;
  final String path;
  final int size;
  final String formattedSize;
  final String? architecture;
  final String? quantization;

  ModelInfo({
    required this.name,
    required this.path,
    required this.size,
    required this.formattedSize,
    this.architecture,
    this.quantization,
  });
}