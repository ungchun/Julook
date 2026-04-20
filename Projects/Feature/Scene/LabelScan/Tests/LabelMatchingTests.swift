import XCTest

@testable import FeatureLabelScan

final class LabelMatchingTests: XCTestCase {

  // MARK: - cleanKeyword

  func test_cleanKeyword_removesTrailingMakgeolliAndTrims() {
    XCTAssertEqual(LabelMatching.cleanKeyword("장수 막걸리"), "장수")
  }

  func test_cleanKeyword_removesAllListedWords() {
    XCTAssertEqual(LabelMatching.cleanKeyword("우리 막걸리"), "")
  }

  func test_cleanKeyword_keepsBrandWithoutRemovables() {
    XCTAssertEqual(LabelMatching.cleanKeyword("느린마을 막걸리"), "느린마을")
  }

  func test_cleanKeyword_trimsLeadingAndTrailingWhitespace() {
    XCTAssertEqual(LabelMatching.cleanKeyword("  장수  "), "장수")
  }

  func test_cleanKeyword_emptyReturnsEmpty() {
    XCTAssertEqual(LabelMatching.cleanKeyword(""), "")
  }

  func test_cleanKeyword_unrelatedWordIsUntouched() {
    XCTAssertEqual(LabelMatching.cleanKeyword("지평"), "지평")
  }

  // MARK: - isNameMatched

  func test_isNameMatched_nameContainsQuery() {
    XCTAssertTrue(LabelMatching.isNameMatched(searchQuery: "장수", makgeolliName: "장수막걸리"))
  }

  func test_isNameMatched_queryContainsName() {
    XCTAssertTrue(LabelMatching.isNameMatched(searchQuery: "장수막걸리", makgeolliName: "장수"))
  }

  func test_isNameMatched_ignoresWhitespace() {
    XCTAssertTrue(LabelMatching.isNameMatched(searchQuery: "장수 막걸리", makgeolliName: "장수막걸리"))
  }

  func test_isNameMatched_ignoresCase() {
    XCTAssertTrue(LabelMatching.isNameMatched(searchQuery: "JANGSU", makgeolliName: "jangsu"))
  }

  func test_isNameMatched_unrelatedReturnsFalse() {
    XCTAssertFalse(LabelMatching.isNameMatched(searchQuery: "복순", makgeolliName: "장수"))
  }

  // MARK: - levenshteinDistance

  func test_levenshteinDistance_bothEmptyIsZero() {
    XCTAssertEqual(LabelMatching.levenshteinDistance("", ""), 0)
  }

  func test_levenshteinDistance_firstEmptyReturnsSecondLength() {
    XCTAssertEqual(LabelMatching.levenshteinDistance("", "abc"), 3)
  }

  func test_levenshteinDistance_secondEmptyReturnsFirstLength() {
    XCTAssertEqual(LabelMatching.levenshteinDistance("abc", ""), 3)
  }

  func test_levenshteinDistance_identicalIsZero() {
    XCTAssertEqual(LabelMatching.levenshteinDistance("abc", "abc"), 0)
  }

  func test_levenshteinDistance_oneSubstitutionIsOne() {
    XCTAssertEqual(LabelMatching.levenshteinDistance("abc", "abd"), 1)
  }

  func test_levenshteinDistance_oneInsertionIsOne() {
    XCTAssertEqual(LabelMatching.levenshteinDistance("abc", "abcd"), 1)
  }

  func test_levenshteinDistance_oneDeletionIsOne() {
    XCTAssertEqual(LabelMatching.levenshteinDistance("abcd", "abc"), 1)
  }

  func test_levenshteinDistance_completeMismatch() {
    XCTAssertEqual(LabelMatching.levenshteinDistance("abc", "xyz"), 3)
  }

  func test_levenshteinDistance_koreanOneCharDiff() {
    XCTAssertEqual(LabelMatching.levenshteinDistance("장수", "장쑤"), 1)
  }

  // MARK: - calculateSimilarity

  func test_calculateSimilarity_identicalReturnsOne() {
    XCTAssertEqual(
      LabelMatching.calculateSimilarity(searchQuery: "막걸리", makgeolliName: "막걸리"),
      1.0,
      accuracy: 0.0001
    )
  }

  func test_calculateSimilarity_normalizesWhitespaceAndCase() {
    XCTAssertEqual(
      LabelMatching.calculateSimilarity(searchQuery: " 장수 막걸리 ", makgeolliName: "장수막걸리"),
      1.0,
      accuracy: 0.0001
    )
  }

  func test_calculateSimilarity_nameContainsQueryReturnsAbove0_9() {
    // query="장수" (2), name="장수막걸리" (5) → 0.9 + (2/5)*0.1 = 0.94
    XCTAssertEqual(
      LabelMatching.calculateSimilarity(searchQuery: "장수", makgeolliName: "장수막걸리"),
      0.94,
      accuracy: 0.0001
    )
  }

  func test_calculateSimilarity_queryContainsNameReturnsAbove0_85() {
    // after normalize: query="장수막걸리" (5), name="장수" (2) → 0.85 + (2/5)*0.1 = 0.89
    XCTAssertEqual(
      LabelMatching.calculateSimilarity(searchQuery: "장수 막걸리", makgeolliName: "장수"),
      0.89,
      accuracy: 0.0001
    )
  }

  func test_calculateSimilarity_levenshteinAboveThresholdReturnsSimilarity() {
    // "abcd" vs "abxd": distance 1, len 4, sim = 0.75 ≥ 0.7
    XCTAssertEqual(
      LabelMatching.calculateSimilarity(searchQuery: "abcd", makgeolliName: "abxd"),
      0.75,
      accuracy: 0.0001
    )
  }

  func test_calculateSimilarity_levenshteinBelowThresholdReturnsZero() {
    // "abc" vs "xbc": distance 1, len 3, sim = 0.6667 < 0.7 → 0.0
    XCTAssertEqual(
      LabelMatching.calculateSimilarity(searchQuery: "abc", makgeolliName: "xbc"),
      0.0,
      accuracy: 0.0001
    )
  }

  func test_calculateSimilarity_levenshteinExceedsTwoReturnsZero() {
    // "abcdef" vs "uvwxyz": distance 6, > 2 → 0.0
    XCTAssertEqual(
      LabelMatching.calculateSimilarity(searchQuery: "abcdef", makgeolliName: "uvwxyz"),
      0.0,
      accuracy: 0.0001
    )
  }

  func test_calculateSimilarity_distanceTwoWithHighEnoughLengthReturnsSimilarity() {
    // "abcdefg" vs "abxyefg": distance 2, len 7, sim ≈ 0.7143 ≥ 0.7
    XCTAssertEqual(
      LabelMatching.calculateSimilarity(searchQuery: "abcdefg", makgeolliName: "abxyefg"),
      1.0 - 2.0 / 7.0,
      accuracy: 0.0001
    )
  }
}
