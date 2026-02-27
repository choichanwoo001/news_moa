/// API 서버 base URL 설정.
///
/// - 웹 배포: 빌드 시 --dart-define=API_BASE=/api 사용 (같은 오리진 프록시)
/// - 로컬/모바일: 기본값 http://localhost:8000 또는 런타임에 baseUrl 설정
class ApiConfig {
  ApiConfig._();

  static String? _override;

  /// 런타임에 설정된 값이 있으면 사용, 없으면 빌드 시 API_BASE (웹 배포용 /api)
  static String get baseUrl =>
      _override ?? const String.fromEnvironment(
        'API_BASE',
        defaultValue: 'http://localhost:8000',
      );

  static set baseUrl(String v) => _override = v;

  static const String _defaultBaseUrl = 'http://localhost:8000';

  /// Android 에뮬레이터용
  static const String androidEmulator = 'http://10.0.2.2:8000';

  /// 실기기에서 PC 로컬 서버 접속 시 (예: 172.16.35.54)
  static String realDevice(String host) => 'http://$host:8000';

  /// 기본값으로 초기화 (테스트 등에서 복원용)
  static void reset() {
    _override = _defaultBaseUrl;
  }
}
