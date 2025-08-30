import 'dart:typed_data';
import 'package:flutter/foundation.dart';
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
      // 웹 환경에서는 모델 파일을 메모리에서 직접 처리
      if (kIsWeb) {
        await _initializeForWeb();
      } else {
        // 모바일/데스크톱에서는 파일 시스템 사용
        await _initializeForNative();
      }
      _isInitialized = true;
      return true;
    } catch (e) {
      print('AI 서비스 초기화 실패: $e');
      return false;
    }
  }
  
  /// 웹 환경용 초기화
  Future<void> _initializeForWeb() async {
    try {
      // 모델 정보 확인
      _modelInfo = await GGUFLoader.getModelInfo();
      print('모델 정보: $_modelInfo');
      
      if (_modelInfo!['isValid']) {
        print('유효한 GGUF 모델 파일 발견: ${_modelInfo!['fileSize']} bytes');
        _modelPath = 'assets://model/gemma3-270m-it-q4_k_m.gguf';
      } else {
        print('모델 파일 검증 실패, 시뮬레이션 모드로 전환');
        _modelPath = 'simulation_mode';
      }
      
      // 시뮬레이션 추론 엔진 초기화
      _inferenceEngine = SimulationInferenceEngine();
      await _inferenceEngine!.loadModel(_modelPath!);
      
    } catch (e) {
      print('웹 환경에서 모델 파일 로드 실패: $e');
      _modelPath = 'simulation_mode';
      _inferenceEngine = SimulationInferenceEngine();
      await _inferenceEngine!.loadModel(_modelPath!);
    }
  }
  
  /// 네이티브 환경용 초기화 (향후 구현)
  Future<void> _initializeForNative() async {
    // 향후 모바일/데스크톱 환경에서 실제 파일 시스템 사용
    _modelPath = 'native_mode';
    _inferenceEngine = SimulationInferenceEngine();
    await _inferenceEngine!.loadModel(_modelPath!);
    print('네이티브 환경 초기화 완료');
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
        return await _simulateAIResponse(prompt);
      }
    } catch (e) {
      print('AI 응답 생성 실패: $e');
      return _getFallbackResponse(prompt);
    }
  }
  
  /// 모델 정보 조회
  Map<String, dynamic>? get modelInfo => _modelInfo;
  
  /// AI 응답 시뮬레이션 (실제 모델 통합 전까지 사용)
  Future<String> _simulateAIResponse(String prompt) async {
    // 실제 AI 처리 시간을 시뮬레이션
    await Future.delayed(Duration(milliseconds: 500 + (prompt.length * 10)));
    
    final lowerPrompt = prompt.toLowerCase();
    
    // 한국어 패턴 매칭
    if (lowerPrompt.contains('안녕') || lowerPrompt.contains('하이') || lowerPrompt.contains('hello')) {
      return "안녕하세요! 저는 지키미예요! 😊 오늘 하루는 어떠셨나요?";
    }
    
    if (lowerPrompt.contains('이름') || lowerPrompt.contains('누구')) {
      return "저는 지키미라고 해요! 여러분의 아지트를 지키는 AI 친구랍니다! ✨\n무엇이든 편하게 물어보세요!";
    }
    
    if (lowerPrompt.contains('뭐해') || lowerPrompt.contains('뭐하고') || lowerPrompt.contains('뭐하는')) {
      return "지금 여러분과 즐거운 대화를 나누고 있어요! 🎉\n다른 궁금한 것이 있으면 언제든 말씀해주세요!";
    }
    
    if (lowerPrompt.contains('고마워') || lowerPrompt.contains('감사')) {
      return "천만에요! 도움이 되어서 기뻐요! 😄\n또 다른 도움이 필요하면 언제든 말씀해주세요!";
    }
    
    if (lowerPrompt.contains('날씨')) {
      return "죄송해요, 저는 아직 실시간 날씨 정보에 접근할 수 없어요. 😅\n하지만 다른 것들은 도와드릴 수 있어요!";
    }
    
    if (lowerPrompt.contains('게임') || lowerPrompt.contains('놀이')) {
      return "재미있는 게임 이야기네요! 🎮\n어떤 종류의 게임을 좋아하시나요? 저도 게임 이야기 듣는 걸 좋아해요!";
    }
    
    if (lowerPrompt.contains('음식') || lowerPrompt.contains('먹을')) {
      return "음식 이야기라니 맛있겠어요! 🍽️\n어떤 음식을 좋아하시나요? 저는 데이터로 이루어져 있어서 먹을 수는 없지만, 음식 이야기는 정말 좋아해요!";
    }
    
    if (lowerPrompt.contains('공부') || lowerPrompt.contains('학습')) {
      return "공부하시는군요! 정말 멋져요! 📚\n어떤 분야를 공부하고 계신가요? 제가 도울 수 있는 것이 있다면 언제든 말씀해주세요!";
    }
    
    // 기본 응답들
    final responses = [
      "정말 흥미로운 이야기네요! 더 자세히 말씀해주실 수 있나요? 🤔",
      "그렇군요! 저도 그런 생각을 해본 적이 있어요. 어떻게 생각하시나요? 💭",
      "와, 그건 정말 재미있는 주제예요! 더 많은 이야기를 들려주세요! ✨",
      "흠... 그것에 대해 더 생각해볼 필요가 있겠네요. 다른 관점은 어떠신가요? 🌟",
      "정말 좋은 질문이에요! 저도 함께 생각해보고 싶어요! 🎯"
    ];
    
    return responses[prompt.hashCode.abs() % responses.length];
  }
  
  /// 폴백 응답 (에러 발생 시)
  String _getFallbackResponse(String prompt) {
    return "미안해요, 지금은 생각이 잘 안 나네요... 😅\n다시 한번 말씀해주실 수 있나요?";
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