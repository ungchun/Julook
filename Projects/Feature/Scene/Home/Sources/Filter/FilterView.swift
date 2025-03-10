//
//  FilterView.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/9/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import DesignSystem
import Core

import ComposableArchitecture

public struct FilterView: View {
  let store: StoreOf<FilterCore>
  
  public init(store: StoreOf<FilterCore>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()
      
      VStack {
        ScrollView(.horizontal, showsIndicators: false) {
          // TODO: 특징
          HStack(spacing: 8) {
            ForEach(FilterType.allCases, id: \.self) { option in
              Button {
                store.send(.toggleFilter(option))
              } label: {
                Text(option.description)
                  .foregroundColor(.w)
                  .font(.SF15R)
              }
              .cornerRadius(10)
              .buttonStyle(.borderedProminent)
              .tint(store.selectedFilters.contains(option) ? Color.lilac : Color.w10)
            }
          }
        }
        .padding(.vertical, 10)
        
        ScrollView {
          VStack {
            // TODO: sort
            HStack {
              HStack(spacing: 4) {
                Text("어떤 순서로 정렬되나요")
                  .foregroundColor(.w50)
                  .font(.SF12R)
                
                Image(systemName: "questionmark.circle.fill")
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(width: 12, height: 12)
                  .foregroundColor(.w50)
              }
              
              Spacer()
              
              Menu {
                Picker("", selection: Binding(
                  get: { self.store.selectedSort },
                  set: { self.store.send(.selectSort($0)) }
                )) {
                  ForEach(SortOption.allCases) { option in
                    Text(option.description)
                      .foregroundColor(.white)
                      .font(.SF14R)
                      .tag(option)
                  }
                }
                .labelsHidden()
              } label: {
                HStack(spacing: 4) {
                  Group {
                    Text(self.store.selectedSort.description)
                    Image(systemName: "chevron.up.chevron.down")
                  }
                  .font(.SF12B)
                  .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
                }
              }            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
          }
          
          // TODO: Data
          HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.darkgray)
              .frame(height: 320)
            RoundedRectangle(cornerRadius: 16)
              .fill(Color.darkgray)
              .frame(height: 320)
          }
          .padding(.horizontal, 16)
          .padding(.vertical, 10)
        }
      }
    }
    .addNavigationBar(title: "특징으로 찾기")
    .onAppear { store.send(.onAppear) }
  }
}
