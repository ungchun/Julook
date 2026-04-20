import Foundation

enum LabelMatching {
  static func cleanKeyword(_ text: String) -> String {
    let removeWords = [
      "막걸리", "생막걸리", "탁주", "생탁주", "프리미엄",
      "명품", "전통", "우리", "순", "참", "특선", "명가",
      "본가", "원조", "청정", "손"
    ]
    var result = text
    for word in removeWords {
      result = result.replacingOccurrences(of: word, with: "")
    }
    return result.trimmingCharacters(in: .whitespaces)
  }

  static func isNameMatched(searchQuery: String, makgeolliName: String) -> Bool {
    let query = searchQuery.replacingOccurrences(of: " ", with: "").lowercased()
    let name = makgeolliName.replacingOccurrences(of: " ", with: "").lowercased()
    return name.contains(query) || query.contains(name)
  }

  static func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
    let s1Array = Array(s1)
    let s2Array = Array(s2)
    let s1Count = s1Array.count
    let s2Count = s2Array.count

    if s1Count == 0 { return s2Count }
    if s2Count == 0 { return s1Count }

    var matrix = [[Int]](repeating: [Int](repeating: 0, count: s2Count + 1),
                         count: s1Count + 1)

    for i in 0...s1Count { matrix[i][0] = i }
    for j in 0...s2Count { matrix[0][j] = j }

    for i in 1...s1Count {
      for j in 1...s2Count {
        let cost = s1Array[i - 1] == s2Array[j - 1] ? 0 : 1
        matrix[i][j] = min(
          matrix[i - 1][j] + 1,       // 삭제
          matrix[i][j - 1] + 1,       // 삽입
          matrix[i - 1][j - 1] + cost // 교체
        )
      }
    }
    return matrix[s1Count][s2Count]
  }

  static func calculateSimilarity(searchQuery: String, makgeolliName: String) -> Double {
    let query = searchQuery.replacingOccurrences(of: " ", with: "").lowercased()
    let name = makgeolliName.replacingOccurrences(of: " ", with: "").lowercased()

    if query == name { return 1.0 }

    if name.contains(query) {
      return 0.9 + (Double(query.count) / Double(name.count)) * 0.1
    }
    if query.contains(name) {
      return 0.85 + (Double(name.count) / Double(query.count)) * 0.1
    }

    let distance = levenshteinDistance(query, name)
    let maxLen = max(query.count, name.count)

    if distance <= 2 {
      let similarity = 1.0 - (Double(distance) / Double(maxLen))
      if similarity >= 0.7 {
        return similarity
      }
    }

    return 0.0
  }
}
