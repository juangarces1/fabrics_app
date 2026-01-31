class ScannerHelper {
  /// Extracts the roll ID from a scanned string.
  ///
  /// Supports:
  /// - Legacy 9-digit barcodes (strips the first digit if length >= 9).
  /// - Standard QR codes (direct numeric value).
  ///
  /// Returns null if the code is invalid or non-numeric.
  static int? extractRollId(String? code) {
    if (code == null || code.isEmpty || code == '-1') return null;

    String clean = code.trim();

    // 1. Handle A/B wrapped barcodes (Codabar style start/stop)
    // These might be of any length, so we strip characters if they exist.
    bool hadWrappers = false;
    if (clean.toUpperCase().startsWith('A')) {
      clean = clean.substring(1);
      hadWrappers = true;
    }
    if (clean.toUpperCase().endsWith('B')) {
      clean = clean.substring(0, clean.length - 1);
      hadWrappers = true;
    }

    // 2. Legacy numeric-only format (9+ characters)
    // If it didn't have A/B wrappers but is 9+ chars, skip the first digit.
    if (!hadWrappers && clean.length >= 9) {
      clean = clean.substring(1, 9);
    }

    // 3. Final Parse (strips leading zeros automatically)
    return int.tryParse(clean);
  }
}
