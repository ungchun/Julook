//
//  MainCoordinatorView.swift
//  Feature
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import FeatureTabs
import FeatureHome

import ComposableArchitecture
import TCACoordinators

public struct MainCoordinatorView: View {
  let store: StoreOf<MainCoordinatorCore>
  
  public init(store: StoreOf<MainCoordinatorCore>) {
    self.store = store
  }
  
  public var body: some View {
    TCARouter(store.scope(state: \.routes, action: \.router)) { screen in
      Group {
        switch screen.case {
        case let .tabs(store):
          TabsView(store: store)
        case let .filter(store):
          FilterView(store: store)
        case let .information(store):
          InformationView(store: store)
        case let .commentList(store):
          CommentListView(store: store)
        }
      }
    }
  }
}
