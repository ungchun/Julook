//
//  SupportedLocale.swift
//  Core
//
//  Created for English localization.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

public enum SupportedLocale: String, Equatable, Sendable, CaseIterable {
  case ko
  case en

  /// 주어진 language code에 해당하는 SupportedLocale 반환.
  /// 지원하지 않는 코드(또는 nil)는 `.ko`로 fallback.
  public static func from(languageCode: String?) -> SupportedLocale {
    guard let code = languageCode, let locale = SupportedLocale(rawValue: code) else {
      return .ko
    }
    return locale
  }

  /// 현재 시스템 locale 기반 SupportedLocale 반환.
  public static var current: SupportedLocale {
    return from(languageCode: Locale.current.language.languageCode?.identifier)
  }
}
