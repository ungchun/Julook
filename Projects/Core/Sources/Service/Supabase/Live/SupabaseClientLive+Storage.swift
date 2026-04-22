import Foundation

import Supabase
import Functions

extension SupabaseClientLive {
  static func getPublicURL(
    _ ref: RawClientRef, bucket: String, path: String
  ) async throws -> URL {
    let client = try requireClient(ref)
    return try client.storage.from(bucket).getPublicURL(path: path)
  }

  static func analyzeLabelImage(
    _ ref: RawClientRef, imageData: Data
  ) async throws -> LabelAnalysisResult {
    let client = try requireClient(ref)
    let base64String = imageData.base64EncodedString()

    do {
      let result: LabelAnalysisResult = try await client.functions.invoke(
        "analyze-label",
        options: FunctionInvokeOptions(body: ["image": base64String])
      )
      return result
    } catch let error as FunctionsError {
      if case let .httpError(code, data) = error {
        let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
        Log.debug("[SupabaseClient] Edge Function error - code: \(code), message: \(errorMessage)")
      }
      throw SupabaseClientError(code: .failToAnalyzeLabel, underlying: error)
    } catch {
      throw SupabaseClientError(code: .failToAnalyzeLabel, underlying: error)
    }
  }
}
