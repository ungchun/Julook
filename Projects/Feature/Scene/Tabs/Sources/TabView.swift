//
//  TabView.swift
//  FeatureTabs
//
//  Created by Kim SungHun on 3/5/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import FeatureHome
import FeatureSearch

import ComposableArchitecture

public struct TabsView: View {
  @Bindable var store: StoreOf<TabCore>
  
  public init(store: StoreOf<TabCore>) {
    self.store = store
  }
  
  public var body: some View {
    TabView(selection: $store.selectedTab.sending(\.tabSeoected)) {
      HomeView(store: store.scope(
        state: \.homeTab,
        action: \.homeTab))
      .tabItem {
        Image(systemName: "house")
        Text("Home")
      }
      .tag(Tab.home)
      
      SearchView(store: store.scope(
        state: \.searchTab,
        action: \.searchTab))
      .tabItem {
        Image(systemName: "gear")
        Text("Search")
      }
      .tag(Tab.search)
    }
  }
}
