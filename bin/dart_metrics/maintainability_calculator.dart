import 'dart:math';

/// Utility class for calculating Code Maintainability Index (CMI)
class MaintainabilityCalculator {
  /// Calculates the maintainability index for a function
  ///
  /// Returns a score from 0-100 where:
  /// - 85-100: Excellent maintainability
  /// - 70-84: Good maintainability
  /// - 50-69: Moderate maintainability
  /// - 25-49: Poor maintainability
  /// - 0-24: Legacy code requiring immediate attention
  static double calculate({
    required int linesOfCode,
    required int cyclomaticComplexity,
    required int nestingLevel,
    required int returnCount,
    required int booleanExpressions,
  }) {
    // Start with base score
    double cmi = 100.0;

    // Lines of Code penalty (logarithmic to avoid over-penalizing)
    if (linesOfCode > 1) {
      cmi -= min(30.0, 15.0 * log(linesOfCode / 5.0 + 1));
    }

    // Cyclomatic Complexity penalty (more aggressive for high complexity)
    cmi -= cyclomaticComplexity * (cyclomaticComplexity > 10 ? 3.0 : 2.0);

    // Nesting penalty (exponential to strongly discourage deep nesting)
    if (nestingLevel > 0) {
      cmi -= pow(nestingLevel, 1.5) * 3.0;
    }

    // Multiple returns penalty
    if (returnCount > 1) {
      cmi -= (returnCount - 1) * 2.0;
    }

    // Boolean expressions penalty
    cmi -= booleanExpressions * 1.0;

    // Bonus for very simple functions
    if (cyclomaticComplexity == 1 && linesOfCode <= 5 && nestingLevel == 0) {
      cmi += 10.0;
    }

    // Bonus for single-purpose functions
    if (returnCount <= 1 && cyclomaticComplexity <= 3) {
      cmi += 5.0;
    }

    // Ensure CMI is within bounds
    return max(0.0, min(100.0, cmi));
  }

  /// Returns the CMI category as a string
  static String getCMICategory(double cmi) {
    if (cmi >= 85) return 'Excellent';
    if (cmi >= 70) return 'Good';
    if (cmi >= 50) return 'Moderate';
    if (cmi >= 25) return 'Poor';
    return 'Legacy';
  }

  /// Returns the CSS class for the CMI score
  static String getCMIClass(double cmi) {
    if (cmi >= 85) return 'cmi-excellent';
    if (cmi >= 70) return 'cmi-good';
    if (cmi >= 50) return 'cmi-moderate';
    if (cmi >= 25) return 'cmi-poor';
    return 'cmi-legacy';
  }
}