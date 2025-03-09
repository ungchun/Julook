//
//  SearchView.swift
//  FeatureTabs
//
//  Created by Kim SungHun on 3/5/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import ComposableArchitecture

public struct SearchView: View {
  @Bindable var store: StoreOf<SearchCore>
  
  public init(store: StoreOf<SearchCore>) {
    self.store = store
  }
  
  public var body: some View {
    VStack {
      Text("검색")
    }
  }
}
