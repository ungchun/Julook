import Foundation

public struct LabelAnalysisDebug: Codable, Equatable, Sendable {
  public let rawResponse: String?
  public let parsedJson: String?
}

public struct LabelAnalysisResult: Codable, Equatable, Sendable {
  public let primaryName: String?
  public let name: String?
  public let brewery: String?
  public let region: String?
  public let debug: LabelAnalysisDebug?

  public init(
    primaryName: String? = nil,
    name: String?,
    brewery: String?,
    region: String? = nil,
    debug: LabelAnalysisDebug? = nil
  ) {
    self.primaryName = primaryName
    self.name = name
    self.brewery = brewery
    self.region = region
    self.debug = debug
  }
}
