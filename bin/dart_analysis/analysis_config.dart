class AnalysisConfig {
  final String analysisOutputFile;
  final String dartAnalysisReport;
  final String outputDirectory;

  const AnalysisConfig({
    this.analysisOutputFile = 'flutter_statix/dart_analysis.txt',
    this.dartAnalysisReport = 'flutter_statix/dart_analysis_report.json',
    this.outputDirectory = 'flutter_statix',
  });
}