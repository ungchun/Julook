//
//  SupabaseClientLive+Translation.swift
//  Core
//
//  Created for English localization.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Supabase

extension SupabaseClientLive {
  static func fetchMakgeolliTranslations(
    _ ref: RawClientRef, locale: SupportedLocale
  ) async throws -> [MakgeolliTranslation] {
    let client = try requireClient(ref)
    do {
      let result: [MakgeolliTranslation] = try await client
        .from("makgeolli_translations")
        .select()
        .eq("locale", value: locale.rawValue)
        .execute()
        .value
      return result
    } catch {
      throw SupabaseClientError(code: .failToFetch, underlying: error)
    }
  }
}
