class AnalysisConfig {
  final String dartAnalysisOutputTextFile;
  final String dartAnalysisParsedJsonFile;
  final String dartAnalysisOutputDirectory;
  final String dartAnalysisReportFile;

  const AnalysisConfig({
    this.dartAnalysisOutputTextFile = 'flutter_statix/dart_analysis.txt',
    this.dartAnalysisParsedJsonFile = 'flutter_statix/dart_analysis_report.json',
    this.dartAnalysisReportFile = 'flutter_statix/dart_analysis_report.html',
    this.dartAnalysisOutputDirectory = 'flutter_statix',
  });
}