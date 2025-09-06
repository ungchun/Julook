//
//  SearchView.swift
//  FeatureTabs
//
//  Created by Kim SungHun on 3/5/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import DesignSystem
import Core

import ComposableArchitecture

public struct SearchView: View {
  @Bindable var store: StoreOf<SearchCore>
  @FocusState private var focused: Bool
  
  public init(store: StoreOf<SearchCore>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea()
        .onTapGesture {
          if store.isSearchBarFocused {
            focused = false
            store.send(.setSearchBarFocus(false))
          }
        }
      
      VStack(spacing: 0) {
        SearchBar()
          .padding(.bottom, 16)
        
        if store.recentSearches.isEmpty
            && store.searchText.isEmpty
            && !store.isSearchBarFocused {
          Spacer()
          EmptyStateView()
          Spacer()
        } else {
          ScrollView(showsIndicators: false) {
            if store.searchText.isEmpty && (store.isSearchBarFocused || !store.recentSearches.isEmpty) {
              RecentSearchesView()
            }
            
            if !store.searchText.isEmpty {
              SearchResultsView(store: store)
            }
          }
          .simultaneousGesture(
            DragGesture().onChanged { _ in
              if store.isSearchBarFocused {
                focused = false
                store.send(.setSearchBarFocus(false))
              }
            }
          )
        }
      }
      .padding(.horizontal, 16)
    }
    .onAppear {
      store.send(.onAppear)
      focused = false
    }
  }
}

private extension SearchView {
  @ViewBuilder
  func SearchBar() -> some View {
    HStack {
      HStack {
        Image(systemName: "magnifyingglass")
          .foregroundColor(.w50)
          .padding(.leading, 8)
        
        TextField("막걸리 이름, 양조장 ...", text: $store.searchText)
          .foregroundColor(.w)
          .accentColor(DesignSystemAsset.Colors.primary.swiftUIColor)
          .focused($focused)
          .submitLabel(.search)
          .onSubmit {
            Amp.track(event: "search_submitted", properties: [
              "search_query": store.searchText
            ])
            store.send(.searchSubmitted)
          }
          .onChange(of: store.searchText) { _, newValue in
            store.send(.searchTextChanged(newValue))
          }
          .onChange(of: focused) { _, newValue in
            store.send(.setSearchBarFocus(newValue))
          }
        
        if !store.searchText.isEmpty {
          Button {
            store.searchText = ""
          } label: {
            Image(systemName: "xmark.circle.fill")
              .foregroundColor(.w50)
          }
          .padding(.trailing, 8)
        }
      }
      .padding(.vertical, 10)
      .background(DesignSystemAsset.Colors.w10.swiftUIColor)
      .cornerRadius(10)
      
      if focused {
        Button("취소") {
          focused = false
          UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
        .padding(.leading, 8)
        .transition(.move(edge: .trailing).combined(with: .opacity))
        .animation(.easeInOut(duration: 0.2), value: focused)
      }
    }
  }
  
  @ViewBuilder
  func EmptyStateView() -> some View {
    VStack(spacing: 20) {
      Text("막걸리 이름으로 검색해보세요!")
        .foregroundColor(.w50)
        .font(.SF17R)
      
      DesignSystemAsset.Images.searchJulook.swiftUIImage
        .resizable()
        .scaledToFit()
        .frame(height: 140)
    }
  }
  
  @ViewBuilder
  func RecentSearchesView() -> some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Text("최근 검색어")
          .foregroundColor(.w)
          .font(.SF14R)
        Spacer()
        Button {
          if !store.recentSearches.isEmpty {
            store.send(.showClearConfirmAlert(true))
          }
        } label: {
          Text("지우기")
            .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
            .font(.SF14R)
        }
      }
      .padding(.bottom, 20)
      .alert("최근 검색어 지우기", isPresented: $store.isShowingClearConfirmAlert) {
        Button("취소", role: .cancel) {
          store.send(.showClearConfirmAlert(false))
        }
        Button("지우기", role: .destructive) {
          store.send(.clearRecentSearches)
          store.send(.showClearConfirmAlert(false))
        }
      } message: {
        Text("검색한 기록을 모두 지울까요?")
      }
      
      ForEach(store.recentSearches, id: \.self) { search in
        VStack(spacing: 12) {
          HStack {
            Text(search)
              .foregroundColor(.w)
              .font(.SF17R)
            
            Spacer()
            
            Button {
              store.send(.removeRecentSearchTapped(search))
            } label: {
              Image(systemName: "xmark")
                .font(.system(size: 16))
                .foregroundColor(.w50)
            }
            .buttonStyle(BorderlessButtonStyle())
          }
          .contentShape(Rectangle())
          .onTapGesture {
            Amp.track(event: "recent_search_clicked", properties: [
              "search_query": search
            ])
            if store.isSearchBarFocused {
              focused = false
              store.send(.setSearchBarFocus(false))
            }
            store.searchText = search
            store.send(.searchSubmitted)
          }
          
          if search != store.recentSearches.last {
            Divider()
              .background(Color.w10)
              .padding(.bottom, 12)
          }
        }
      }
    }
    .padding(.top, 16)
  }
}

private struct SearchResultsView: View {
  @Bindable var store: StoreOf<SearchCore>
  
  fileprivate init(
    store: StoreOf<SearchCore>
  ) {
    self.store = store
  }
  
  fileprivate var body: some View {
    if store.isSearching {
      ProgressView()
        .progressViewStyle(CircularProgressViewStyle(tint: .w))
        .padding(.top, 32)
    } else if store.searchResults.isEmpty {
      VStack(spacing: 16) {
        HStack(spacing: 4) {
          Spacer()
          Text("'\(store.searchText)'")
            .foregroundColor(.w85)
            .font(.SF17R)
          Text("검색 결과가 없어요.")
            .foregroundColor(.w50)
            .font(.SF17R)
          Spacer()
        }
        .lineLimit(1)
        
        Button {
          store.send(.requestRegisterMakgeolli(store.searchText))
        } label: {
          Text("등록 요청하기")
            .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
            .font(.SF17R)
        }
        .alert("등록 요청 완료", isPresented: $store.isShowingRequestAlert) {
          Button("확인", role: .cancel) {
            store.send(.showRequestAlert(false))
          }
        } message: {
          Text("빠른 시일내에 추가할게요!")
        }
      }
      .padding(.top, 32)
    } else {
      VStack(spacing: 16) {
        ForEach(store.searchResults, id: \.id) { makgeolli in
          MakgeolliSearchResultRow(makgeolli: makgeolli, store: store)
          
          if makgeolli.id != store.searchResults.last?.id {
            Divider()
              .background(Color.w10)
          }
        }
      }
      .padding(.top, 16)
    }
  }
}

private struct MakgeolliSearchResultRow: View {
  let makgeolli: Makgeolli
  let store: StoreOf<SearchCore>
  
  fileprivate init(
    makgeolli: Makgeolli,
    store: StoreOf<SearchCore>
  ) {
    self.makgeolli = makgeolli
    self.store = store
  }
  
  fileprivate var body: some View {
    Button {
      store.send(.makgeolliTapped(makgeolli))
    } label: {
      HStack(spacing: 0) {
        Group {
          if let imageURL = store.makgeolliImages[makgeolli.id] {
            AsyncImage(url: imageURL) { phase in
              makeImageView(for: phase)
            }
          } else {
            DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 60)
          }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 16)
        .background(DesignSystemAsset.Colors.darkgray.swiftUIColor)
        .cornerRadius(12)
        
        VStack(alignment: .leading, spacing: 4) {
          Text(makgeolli.name)
            .foregroundColor(.w)
            .font(.SF14R)
            .lineLimit(1)
          
          Text("\(formatValue(makgeolli.alcoholPercentage))도 ･ \(formatValue(makgeolli.volume))ml ･ \(formatValue(makgeolli.price))원")
            .foregroundColor(.w50)
            .font(.SF10B)
            .lineLimit(1)
        }
        .padding(.horizontal, 16)
        
        Spacer()
        
        HStack(spacing: 6) {
          ScoreItem(
            score: makgeolli.sweetness,
            label: "단맛",
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
          ScoreItem(
            score: makgeolli.sourness,
            label: "신맛",
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
          ScoreItem(
            score: makgeolli.thickness,
            label: "걸쭉",
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
          ScoreItem(
            score: makgeolli.carbonation,
            label: "탄산",
            color: DesignSystemAsset.Colors.primary.swiftUIColor
          )
        }
      }
    }
    .padding(.vertical, 8)
  }
}

private extension MakgeolliSearchResultRow {
  @ViewBuilder
  func ScoreItem(score: Int?, label: String, color: Color) -> some View {
    VStack(spacing: 4) {
      if let score = score {
        switch score {
        case 0:
          DesignSystemAsset.Images._0Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        case 1:
          DesignSystemAsset.Images._1Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        case 2:
          DesignSystemAsset.Images._2Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        case 3:
          DesignSystemAsset.Images._3Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        case 4:
          DesignSystemAsset.Images._4Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        case 5:
          DesignSystemAsset.Images._5Score.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        default:
          DesignSystemAsset.Images.nillScore.swiftUIImage
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 24, height: 24)
        }
      } else {
        DesignSystemAsset.Images.nillScore.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 24, height: 24)
      }
      
      Text(label)
        .foregroundColor(.w50)
        .font(.SF10B)
    }
  }
  
  @ViewBuilder
  func makeImageView(for phase: AsyncImagePhase) -> some View {
    switch phase {
    case .empty:
      AnyView(
        ProgressView()
          .frame(width: 30, height: 60)
      )
    case .success(let image):
      AnyView(
        image
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      )
    case .failure:
      AnyView(
        DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      )
      
    @unknown default:
      AnyView(
        DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
          .resizable()
          .aspectRatio(contentMode: .fit)
          .frame(width: 30, height: 60)
      )
    }
  }
  
  func formatValue<T>(_ value: T?) -> String {
    guard let value = value else { return "-" }
    return "\(value)"
  }
}
