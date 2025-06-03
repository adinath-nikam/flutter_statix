/// Represents the complexity metrics for a single function or method
class FunctionComplexity {
  final String name;
  final int complexity;
  final int nestingLevel;
  final int lineCount;
  final int returnCount;
  final int booleanExprCount;
  final int switchCaseCount;
  final double maintainabilityIndex;
  final String? codeSnippet;

  const FunctionComplexity({
    required this.name,
    required this.complexity,
    required this.nestingLevel,
    required this.lineCount,
    required this.returnCount,
    required this.booleanExprCount,
    required this.switchCaseCount,
    required this.maintainabilityIndex,
    this.codeSnippet,
  });

  @override
  String toString() {
    return 'FunctionComplexity(name: $name, complexity: $complexity, '
        'maintainabilityIndex: ${maintainabilityIndex.toStringAsFixed(1)})';
  }
}