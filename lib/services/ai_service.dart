import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'gguf_loader.dart';
import 'model_manager.dart';

class AIService {
  static AIService? _instance;
  static AIService get instance => _instance ??= AIService._();
  
  AIService._();
  
  bool _isInitialized = false;
  String? _modelPath;
  InferenceEngine? _inferenceEngine;
  Map<String, dynamic>? _modelInfo;
  
  /// AI 서비스 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;
    
    try {
      // 모바일 환경에서만 동작
      await _initializeForMobile();
      _isInitialized = true;
      return true;
    } catch (e) {
      print('AI 서비스 초기화 실패: $e');
      return false;
    }
  }
  
  /// 모바일 환경용 초기화
  Future<void> _initializeForMobile() async {
    // 현재 선택된 모델 또는 최적의 모델 선택
    final currentModelPath = await ModelManager.getCurrentModelPath();
    if (currentModelPath != null && await File(currentModelPath).exists()) {
      _modelPath = currentModelPath;
    } else {
      _modelPath = await ModelManager.getBestAvailableModel();
    }
    
    print('선택된 모델: $_modelPath');
    
    // 모델 정보 확인
    if (_modelPath!.startsWith('assets://')) {
      _modelInfo = await GGUFLoader.getModelInfo();
    } else {
      _modelInfo = await GGUFLoader.getModelInfoFromPath(_modelPath!);
    }
    
    print('모델 정보: $_modelInfo');
    
    if (_modelInfo!['isValid']) {
      final fileSize = await ModelManager.getModelFileSize(_modelPath!);
      final formattedSize = ModelManager.formatFileSize(fileSize);
      print('유효한 GGUF 모델 파일 발견: $formattedSize');
      
      // 실제 GGUF 엔진 로드
      _inferenceEngine = GGUFInferenceEngine();
      await _inferenceEngine!.loadModel(_modelPath!);
      print('모바일 환경에서 실제 GGUF 엔진 로드 성공');
    } else {
      throw Exception('모델 파일 검증 실패: ${_modelInfo!['error']}');
    }
    
    print('모바일 환경 초기화 완료');
  }
  
  /// 사용 가능한 모델들 정보 조회
  Future<Map<String, dynamic>> getAvailableModelsInfo() async {
    final models = await ModelManager.getAvailableModels();
    final result = <String, dynamic>{};
    
    for (final entry in models.entries) {
      if (entry.value != null) {
        final size = await ModelManager.getModelFileSize(entry.value!);
        result[entry.key] = {
          'path': entry.value,
          'size': size,
          'formattedSize': ModelManager.formatFileSize(size),
          'exists': true,
        };
      } else {
        result[entry.key] = {
          'path': null,
          'size': 0,
          'formattedSize': '0B',
          'exists': false,
        };
      }
    }
    
    return result;
  }
  
  /// 모델 설치 가이드 가져오기
  String getModelInstallationGuide() {
    return ModelManager.getInstallationGuide();
  }
  
  /// AI 모델에게 질문하고 응답 받기
  Future<String> generateResponse(String prompt) async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      if (_inferenceEngine != null) {
        return await _inferenceEngine!.generate(prompt);
      } else {
        throw Exception('추론 엔진이 초기화되지 않았습니다');
      }
    } catch (e) {
      print('AI 응답 생성 실패: $e');
      rethrow;
    }
  }
  
  /// 모델 정보 조회
  Map<String, dynamic>? get modelInfo => _modelInfo;
  
  /// AI 서비스 재초기화 (모델 변경 시 사용)
  Future<bool> reinitialize() async {
    dispose();
    return await initialize();
  }
  
  /// 리소스 정리
  void dispose() {
    _inferenceEngine?.dispose();
    _isInitialized = false;
    _modelPath = null;
    _inferenceEngine = null;
    _modelInfo = null;
  }
}