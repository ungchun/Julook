//
//  SupabaseManager.swift
//  Core
//
//  Created by Kim SungHun on 3/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Supabase

public class SupabaseManager: @unchecked Sendable {
  public static let shared = SupabaseManager()
  
  public private(set) var client: SupabaseClient?
  
  private init() { }
  
  public func initialize(supabaseURL: URL, supabaseKey: String) {
    self.client = SupabaseClient(
      supabaseURL: supabaseURL,
      supabaseKey: supabaseKey
    )
  }
}
