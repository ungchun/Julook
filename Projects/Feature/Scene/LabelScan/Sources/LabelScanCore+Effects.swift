import Foundation
import UIKit

import Core

import ComposableArchitecture

extension LabelScanCore {
  func analyzeImageEffect(image: UIImage) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      do {
        try await LabelScanAnalyzer.run(
          image: image, client: supabaseClient, send: send
        )
      } catch {
        await send(.showError(L10n.LabelScan.Error.analysisErrorRetry))
        await send(.resetCamera)
      }
    }
  }

  func showCandidatesEffect(candidates: [Makgeolli]) -> Effect<Action> {
    let supabaseClient = self.supabaseClient
    return .run { send in
      var images: [UUID: URL] = [:]
      for makgeolli in candidates {
        if let imageName = makgeolli.imageName {
          do {
            let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
            let url = try await supabaseClient.getPublicURL(
              Bucket.MAKGEOLLIIMAGE, fileName
            )
            images[makgeolli.id] = url
          } catch { }
        }
      }
      await send(.candidateImagesLoaded(images))
    }
  }

  func selectCandidateEffect(makgeolli: Makgeolli, imageURL: URL?) -> Effect<Action> {
    .run { send in
      try await Task.sleep(for: .milliseconds(300))
      await send(.moveToInformation(makgeolli, imageURL))
    }
  }
}

enum LabelScanSearch {
  static func searchByPrimaryAndFullName(
    client: Core.SupabaseClient,
    primaryName: String?,
    fullName: String?
  ) async throws -> [Makgeolli] {
    var results: [Makgeolli] = []

    if let primary = primaryName, !primary.isEmpty {
      let fetched = try await client.searchMakgeollis(primary)
      results = fetched.filter {
        LabelMatching.isNameMatched(searchQuery: primary, makgeolliName: $0.name)
      }
    }

    guard results.isEmpty, let full = fullName, !full.isEmpty else { return results }

    let cleaned = LabelMatching.cleanKeyword(full)
    if !cleaned.isEmpty {
      let fetched = try await client.searchMakgeollis(cleaned)
      results = fetched.filter {
        LabelMatching.isNameMatched(searchQuery: cleaned, makgeolliName: $0.name)
      }
    }

    guard results.isEmpty else { return results }

    let words = cleaned.split(separator: " ").map(String.init).filter { $0.count >= 2 }
    for word in words {
      let fetched = try await client.searchMakgeollis(word)
      let matched = fetched.filter {
        LabelMatching.isNameMatched(searchQuery: word, makgeolliName: $0.name)
      }
      results.append(contentsOf: matched)
    }

    var seen = Set<UUID>()
    return results.filter { seen.insert($0.id).inserted }
  }

  static func fetchImageURL(
    client: Core.SupabaseClient, imageName: String?
  ) async throws -> URL? {
    guard let imageName = imageName else { return nil }
    let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
    return try await client.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)
  }
}

// MARK: - Analyzer pipeline

enum LabelScanAnalyzer {
  static func run(
    image: UIImage,
    client: Core.SupabaseClient,
    send: Send<LabelScanCore.Action>
  ) async throws {
    guard let imageData = image.jpegData(compressionQuality: 0.8) else {
      await send(.showError(L10n.LabelScan.Error.imageConversionFailed))
      await send(.resetCamera)
      return
    }

    let result = try await client.analyzeLabelImage(imageData)
    let primary = result.primaryName
    let full = result.name

    guard !(primary ?? "").isEmpty || !(full ?? "").isEmpty else {
      await send(.showError(L10n.LabelScan.Error.labelNotRecognized))
      await send(.resetCamera)
      return
    }

    let searchResults = try await collectSearchResults(
      client: client, analysis: result
    )

    let displayName = primary ?? full ?? L10n.LabelScan.Error.unknownLabel
    guard !searchResults.isEmpty else {
      await send(.showError(L10n.LabelScan.Error.notFoundFormat(displayName)))
      await send(.resetCamera)
      return
    }

    try await dispatchMatch(
      results: searchResults,
      similarityKeyword: primary ?? full ?? "",
      client: client,
      send: send
    )
  }

  private static func collectSearchResults(
    client: Core.SupabaseClient, analysis: LabelAnalysisResult
  ) async throws -> [Makgeolli] {
    var results = try await LabelScanSearch.searchByPrimaryAndFullName(
      client: client, primaryName: analysis.primaryName, fullName: analysis.name
    )
    if results.isEmpty, let brewery = analysis.brewery, !brewery.isEmpty {
      results = try await client.searchMakgeollis(brewery)
    }
    if results.isEmpty, let region = analysis.region, !region.isEmpty {
      results = try await client.searchMakgeollis(region)
    }
    return results
  }

  private static func dispatchMatch(
    results: [Makgeolli],
    similarityKeyword: String,
    client: Core.SupabaseClient,
    send: Send<LabelScanCore.Action>
  ) async throws {
    let sorted = results.map { makgeolli in
      (makgeolli: makgeolli, similarity: LabelMatching.calculateSimilarity(
        searchQuery: similarityKeyword, makgeolliName: makgeolli.name
      ))
    }.sorted { $0.similarity > $1.similarity }

    let shouldDirectNavigate = results.count == 1
      || (sorted.first?.similarity ?? 0) >= 0.9

    if shouldDirectNavigate, let best = sorted.first {
      let imageURL = try? await LabelScanSearch.fetchImageURL(
        client: client, imageName: best.makgeolli.imageName
      )
      await send(.analysisCompleted(.success(best.makgeolli)))
      await send(.moveToInformation(best.makgeolli, imageURL))
      await send(.resetCamera)
    } else {
      await send(.showCandidates(results))
      await send(.resetCamera)
    }
  }
}
