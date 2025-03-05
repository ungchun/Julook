//
//  HomeRootView.swift
//  Packages
//
//  Created by Kim SungHun on 1/5/25.
//

import SwiftUI

import ComposableArchitecture

public struct ContentView: View {
  @Bindable var store: StoreOf<HomeCore>
  
  public init(store: StoreOf<HomeCore>) {
    self.store = store
  }
  
  public var body: some View {
    VStack {
      Text("테스트")
    }
    .background(.yellow)
  }
}
