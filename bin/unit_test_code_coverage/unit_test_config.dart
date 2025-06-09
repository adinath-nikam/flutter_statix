class UnitTestConfig {
  final String unitTestOutputDirectory;
  final String unitTestCoverageFilePath;

  const UnitTestConfig({
    this.unitTestOutputDirectory = 'flutter_statix',
    this.unitTestCoverageFilePath = 'flutter_statix/lcov.info'
  });
}