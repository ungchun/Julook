//
//  AmplitudeClient.swift
//  Core
//
//  Created by Kim SungHun on 1/22/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import AmplitudeSwift

public let Amp = AmplitudeClient.shared

public final class AmplitudeClient: @unchecked Sendable {
  public static let shared = AmplitudeClient()
  
  private var amplitude: Amplitude?
  
  private init() {}
  
  public func configure(apiKey: String) {
    let cleanApiKey = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
      .replacingOccurrences(of: "\"", with: "")
      .replacingOccurrences(of: "'", with: "")
    
    amplitude = Amplitude(configuration: Configuration(
      apiKey: cleanApiKey,
      logLevel: .LOG,
      autocapture: [.sessions, .appLifecycles]
    ))
  }
  
  public func track(event: String, properties: [String: Any]? = nil) {
    guard let amplitude = amplitude else {
      return
    }
    
    amplitude.track(
      eventType: event,
      eventProperties: properties
    )
  }
}
