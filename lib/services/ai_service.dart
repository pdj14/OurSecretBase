import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'gguf_loader.dart';

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
    // 모바일 환경에서는 실제 파일 시스템의 모델 파일 사용
    _modelPath = 'assets://model/gemma3-270m-it-q4_k_m.gguf';
    
    // 모델 정보 확인
    _modelInfo = await GGUFLoader.getModelInfo();
    print('모델 정보: $_modelInfo');
    
    if (_modelInfo!['isValid']) {
      print('유효한 GGUF 모델 파일 발견: ${_modelInfo!['fileSize']} bytes');
      
      // 실제 GGUF 엔진 로드
      _inferenceEngine = GGUFInferenceEngine();
      await _inferenceEngine!.loadModel(_modelPath!);
      print('모바일 환경에서 실제 GGUF 엔진 로드 성공');
    } else {
      throw Exception('모델 파일 검증 실패: ${_modelInfo!['error']}');
    }
    
    print('모바일 환경 초기화 완료');
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
  

  
  /// 리소스 정리
  void dispose() {
    _inferenceEngine?.dispose();
    _isInitialized = false;
    _modelPath = null;
    _inferenceEngine = null;
    _modelInfo = null;
  }
}