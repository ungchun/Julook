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
import FeatureMyMakgeolli
import DesignSystem

import ComposableArchitecture

public struct TabsView: View {
  let store: StoreOf<TabCore>
  
  public init(store: StoreOf<TabCore>) {
    self.store = store
    
    UITabBar.appearance().backgroundColor = DesignSystemAsset.Colors.darkbase.color
  }
  
  public var body: some View {
    TabView {
      HomeView(store: store.scope(
        state: \.homeTab,
        action: \.homeTab))
      .tabItem {
        DesignSystemAsset.Images.homeTab.swiftUIImage
        Text("모아보기")
          .font(.style(.SF10B))
      }
      .tag(Tab.home)
      
      SearchView(store: store.scope(
        state: \.searchTab,
        action: \.searchTab))
      .tabItem {
        DesignSystemAsset.Images.searchTab.swiftUIImage
        Text("검색")
          .font(.style(.SF10B))
      }
      .tag(Tab.search)
      
      MyMakgeolliView(store: store.scope(
        state: \.myMakgeolliTab,
        action: \.myMakgeolliTab))
      .tabItem {
        Image(systemName: "heart.fill")
        Text("내 막걸리")
          .font(.style(.SF10B))
      }
      .tag(Tab.myMakgeolli)
    }
    .accentColor(DesignSystemAsset.Colors.primary.swiftUIColor)
  }
}
