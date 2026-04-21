//
//  SupabaseClient+Translation.swift
//  Core
//
//  Created for English localization.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

extension SupabaseClient {
  /// 주어진 locale에 대한 막걸리 번역을 가져온다.
  /// `.ko`는 원본 데이터가 이미 한국어이므로 호출을 스킵하고 빈 배열 반환.
  public func fetchTranslationsIfNeeded(
    for locale: SupportedLocale
  ) async throws -> [MakgeolliTranslation] {
    guard locale != .ko else { return [] }
    return try await fetchMakgeolliTranslations(locale)
  }
}
