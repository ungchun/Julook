//
//  FilterCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/9/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core

import ComposableArchitecture
import Supabase

@Reducer
public struct FilterCore {
  public init() {}
  
  @ObservableState
  public struct State: Equatable {
    public var selectedFilters: Set<FilterType> = []
    public var initSelectedFilters: FilterType?
    public var showSortOptions: Bool = false
    public var selectedSort: SortOption = .recommended
    public var isLoadingMakgeollis: Bool = false
    public var makgeollis: [Makgeolli] = []
    public var makgeolliImages: [UUID: URL] = [:]
    public var errorMessage: String? = nil
    public var currentPage: Int = 0
    public var hasMoreData: Bool = true
    public var pageSize: Int = 10
    public var isTopicMode: Bool = false
    public var topicTitle: String = ""
    
    public init(
      initSelectedFilters: FilterType? = nil
    ) {
      self.initSelectedFilters = initSelectedFilters
      self.isTopicMode = false
      self.topicTitle = ""
    }
    
    public init(
      topicTitle: String
    ) {
      self.isTopicMode = true
      self.topicTitle = topicTitle
    }
  }
  
  public enum Action {
    case onAppear
    
    case toggleFilter(FilterType)
    case toggleSortOptions
    case selectSort(SortOption)
    case applySorting
    case dismissSortOptions
    case fetchMakgeollis
    case loadMoreMakgeollis
    case makgeollisResponse(TaskResult<[Makgeolli]>, Bool)
    case fetchMakgeolliImage(Makgeolli)
    case makgeolliImageResponse(id: UUID, TaskResult<URL>)
    case applyFilters
    case fetchMakgeollisByTopic
    
    case moveToInformation(Makgeolli, URL?)
    
    case logError(FilterCoreError)
  }
  
  @Dependency(\.supabaseClient) var supabaseClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        if let filter = state.initSelectedFilters {
          state.selectedFilters.insert(filter)
        }
        
        if state.isTopicMode {
          if !state.isLoadingMakgeollis && state.makgeollis.isEmpty {
            return .send(.fetchMakgeollisByTopic)
          }
        } else {
          if !state.isLoadingMakgeollis && state.makgeollis.isEmpty {
            return .send(.fetchMakgeollis)
          }
        }
        return .none
        
      case let .toggleFilter(filter):
        if state.selectedFilters.contains(filter) {
          state.selectedFilters.remove(filter)
        } else {
          state.selectedFilters.insert(filter)
        }
        return .none
        
      case .toggleSortOptions:
        state.showSortOptions.toggle()
        return .none
        
      case let .selectSort(sort):
        state.selectedSort = sort
        state.showSortOptions = false
        return .none
        
      case .applySorting:
        switch state.selectedSort {
        case .recommended:
          state.makgeollis.sort { (a, b) -> Bool in
            guard let aDate = a.createdAt, let bDate = b.createdAt else {
              return a.id.uuidString > b.id.uuidString
            }
            return aDate > bDate
          }
        case .highAlcohol:
          state.makgeollis.sort { (a, b) -> Bool in
            let aAlcohol = a.alcoholPercentage ?? 0
            let bAlcohol = b.alcoholPercentage ?? 0
            return aAlcohol > bAlcohol
          }
        case .lowAlcohol:
          state.makgeollis.sort { (a, b) -> Bool in
            let aAlcohol = a.alcoholPercentage ?? 0
            let bAlcohol = b.alcoholPercentage ?? 0
            return aAlcohol < bAlcohol
          }
        }
        return .none
        
      case .dismissSortOptions:
        state.showSortOptions = false
        return .none
        
      case .fetchMakgeollis:
        if state.isLoadingMakgeollis {
          return .none
        }
        
        state.isLoadingMakgeollis = true
        let pageSize = state.pageSize
        let selectedFilters = state.selectedFilters
        let supabaseClient = self.supabaseClient
        
        return .run { send in
          do {
            let makgeollis = try await supabaseClient.fetchFilteredMakgeollis(
              pageSize,
              0,
              selectedFilters
            )
            await send(.makgeollisResponse(.success(makgeollis), false))
          } catch {
            await send(.makgeollisResponse(.failure(error), false))
          }
        }
        
      case .loadMoreMakgeollis:
        if state.isLoadingMakgeollis || !state.hasMoreData {
          return .none
        }
        
        state.isLoadingMakgeollis = true
        let nextPage = state.currentPage + 1
        let offset = nextPage * state.pageSize
        let pageSize = state.pageSize
        let selectedFilters = state.selectedFilters
        
        let supabaseClient = self.supabaseClient
        
        if state.isTopicMode {
          let topicTitle = state.topicTitle
          return .run { send in
            do {
              let makgeollis = try await supabaseClient.fetchMakgeollisByAward(
                topicTitle,
                pageSize,
                offset
              )
              await send(.makgeollisResponse(.success(makgeollis), true))
            } catch {
              await send(.makgeollisResponse(.failure(error), true))
            }
          }
        } else {
          return .run { send in
            do {
              let makgeollis = try await supabaseClient.fetchFilteredMakgeollis(
                pageSize,
                offset,
                selectedFilters
              )
              await send(.makgeollisResponse(.success(makgeollis), true))
            } catch {
              await send(.makgeollisResponse(.failure(error), true))
            }
          }
        }
        
      case let .makgeollisResponse(.success(makgeollis), isLoadMore):
        state.isLoadingMakgeollis = false
        state.hasMoreData = makgeollis.count >= state.pageSize
        
        if isLoadMore {
          state.currentPage += 1
          
          let uniqueMakgeollis = removeDuplicates(from: makgeollis)
          let existingIds = Set(state.makgeollis.map { $0.id })
          let newMakgeollis = uniqueMakgeollis.filter { !existingIds.contains($0.id) }
          state.makgeollis.append(contentsOf: newMakgeollis)
        } else {
          state.makgeollis = makgeollis
        }
        
        return .merge(
          makgeollis.compactMap { makgeolli in
            return .send(.fetchMakgeolliImage(makgeolli))
          }
        )
        
      case let .makgeollisResponse(.failure(error), _):
        state.isLoadingMakgeollis = false
        state.errorMessage = "막걸리 데이터를 불러오는데 실패했습니다."
        return .send(.logError(FilterCoreError(
          code: .failToFetchMakgeollis,
          underlying: error
        )))
        
      case let .fetchMakgeolliImage(makgeolli):
        guard let imageName = makgeolli.imageName else {
          return .none
        }
        
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
            let publicURL = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)
            await send(.makgeolliImageResponse(id: makgeolli.id, .success(publicURL)))
          } catch {
            await send(.makgeolliImageResponse(id: makgeolli.id, .failure(error)))
          }
        }
        
      case let .makgeolliImageResponse(id, .success(url)):
        state.makgeolliImages[id] = url
        return .none
        
      case let .makgeolliImageResponse(_, .failure(error)):
        return .send(.logError(FilterCoreError(
          code: .failToFetchImage,
          underlying: error
        )))
        
      case .applyFilters:
        state.currentPage = 0
        state.makgeollis = []
        state.makgeolliImages = [:]
        state.hasMoreData = true
        return .send(.fetchMakgeollis)
        
      case .fetchMakgeollisByTopic:
        if state.isLoadingMakgeollis {
          return .none
        }
        
        state.isLoadingMakgeollis = true
        let topicTitle = state.topicTitle
        let pageSize = state.pageSize
        
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let makgeollis = try await supabaseClient.fetchMakgeollisByAward(
              topicTitle,
              pageSize,
              0
            )
            await send(.makgeollisResponse(.success(makgeollis), false))
          } catch {
            await send(.makgeollisResponse(.failure(error), false))
          }
        }
        
      case .moveToInformation(_, _):
        return .none
        
      case let .logError(error):
        return .run { _ in
          Log.error(error)
        }
      }
    }
  }
  
  private func removeDuplicates(from makgeollis: [Makgeolli]) -> [Makgeolli] {
    var uniqueIds = Set<UUID>()
    var result = [Makgeolli]()
    
    for makgeolli in makgeollis {
      if !uniqueIds.contains(makgeolli.id) {
        uniqueIds.insert(makgeolli.id)
        result.append(makgeolli)
      }
    }
    
    return result
  }
}

public struct FilterCoreError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any] = [:]
  public var code: Code
  public var underlying: Error?
  
  public init(
    userInfo: [String: Any] = [:],
    code: Code,
    underlying: Error? = nil
  ) {
    self.userInfo = userInfo
    self.code = code
    self.underlying = underlying
  }
  
  public enum Code: Int, Sendable {
    case failToFetchMakgeollis
    case failToFetchImage
  }
}
