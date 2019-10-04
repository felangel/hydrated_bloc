class MockedPlatform {
  MockedPlatform({
    this.operatingSystem,
    this.environment,
  });

  final String environment;
  final String operatingSystem;

  static String get platform => 'none';
}
