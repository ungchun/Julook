//
//  MyMakgeolliView.swift
//  FeatureMyMakgeolli
//
//  Created by Kim SungHun on 7/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import DesignSystem

import SwiftUI
import ComposableArchitecture

public struct MyMakgeolliView: View {
  let store: StoreOf<MyMakgeolliCore>
  
  public init(store: StoreOf<MyMakgeolliCore>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      Color.yellow
        .ignoresSafeArea()
      
      VStack {
        Text("내 막걸리")
          .foregroundColor(.black)
          .padding(.top, 50)
        
        Spacer()
        
        Text("내가 좋아하는 막걸리를 관리하세요")
          .foregroundColor(.black.opacity(0.6))
        
        Spacer()
      }
      .padding(.horizontal, 20)
    }
    .onAppear {
      store.send(.viewAppeared)
    }
  }
}
