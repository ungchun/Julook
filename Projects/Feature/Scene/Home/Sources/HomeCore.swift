//
//  HomeCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core

import ComposableArchitecture
import Supabase

@Reducer
public struct HomeCore {
  @ObservableState
  public struct State: Equatable {
    // 신상 막걸리
    public var isLoadingNewReleases: Bool = false
    public var newReleases: [Makgeolli] = []
    public var newReleasesImages: [UUID: URL] = [:]
    
    // 수상
    public var isLoadingAwards: Bool = false
    public var awards: [Award] = []
    
    public init() { }
  }
  
  public enum Action {
    // 라이프사이클
    case onAppear
    
    // 사용자 액션
    case filterButtonTapped
    case filterItemTapped(FilterType)
    case newReleaseItemTapped(Makgeolli)
    case topicItemTapped(Award)
    
    // 신상 막걸리
    case fetchNewReleases
    case newReleasesResponse(TaskResult<[Makgeolli]>)
    case fetchNewReleasesImage(Makgeolli)
    case newReleasesImageResponse(id: UUID, TaskResult<URL>)
    
    // 수상
    case fetchAwards
    case awardsResponse(TaskResult<[Award]>)
    
    // 네비게이션
    case moveToFilter
    case moveToFilterWithSelection(FilterType)
    case moveToFilterWithTopic(String)
    case moveToInformation(Makgeolli, URL?)
    
    case logError(HomeCoreError)
  }
  
  public init() { }
  
  @Dependency(\.supabaseClient) var supabaseClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        if !state.isLoadingNewReleases && !state.isLoadingAwards {
          return .merge(
            .send(.fetchNewReleases),
            .send(.fetchAwards)
          )
        } else {
          return .none
        }
        
      case .filterButtonTapped:
        return .send(.moveToFilter)
        
      case let .filterItemTapped(filterName):
        return .send(.moveToFilterWithSelection(filterName))
        
      case let .newReleaseItemTapped(makgeolli):
        let imageURL = state.newReleasesImages[makgeolli.id]
        return .send(.moveToInformation(makgeolli, imageURL))
        
      case let .topicItemTapped(award):
        return .send(.moveToFilterWithTopic(award.name))
        
      case .fetchNewReleases:
        state.isLoadingNewReleases = true
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let makgeollis = try await supabaseClient.fetchNewReleases()
            await send(.newReleasesResponse(.success(makgeollis)))
          } catch {
            await send(.newReleasesResponse(.failure(error)))
          }
        }
        
      case let .newReleasesResponse(.success(makgeollis)):
        state.isLoadingNewReleases = false
        state.newReleases = makgeollis
        return .merge(
          makgeollis.compactMap { makgeolli in
            return .send(.fetchNewReleasesImage(makgeolli))
          }
        )
        
      case let .newReleasesResponse(.failure(error)):
        state.isLoadingNewReleases = false
        return .send(.logError(HomeCoreError(
          code: .failToFetchNewReleases,
          underlying: error
        )))
        
      case let .fetchNewReleasesImage(makgeolli):
        guard let imageName = makgeolli.imageName else {
          return .none
        }
        
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
            let publicURL = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)
            await send(.newReleasesImageResponse(id: makgeolli.id, .success(publicURL)))
          } catch {
            await send(.newReleasesImageResponse(id: makgeolli.id, .failure(error)))
          }
        }
        
      case let .newReleasesImageResponse(id, .success(url)):
        state.newReleasesImages[id] = url
        return .none
        
      case let .newReleasesImageResponse(_, .failure(error)):
        return .send(.logError(HomeCoreError(
          code: .failToFetchImage,
          underlying: error
        )))
        
      case .fetchAwards:
        state.isLoadingAwards = true
        let supabaseClient = self.supabaseClient
        
        return .run { send in
          do {
            let awards = try await supabaseClient.fetchAwards()
            await send(.awardsResponse(.success(awards)))
          } catch {
            await send(.awardsResponse(.failure(error)))
          }
        }
        
      case let .awardsResponse(.success(awards)):
        state.isLoadingAwards = false
        state.awards = awards
        return .none
        
      case let .awardsResponse(.failure(error)):
        state.isLoadingAwards = false
        return .send(.logError(HomeCoreError(
          code: .failToFetchAwards,
          underlying: error
        )))
        
      case .moveToFilter:
        return .none
        
      case .moveToFilterWithSelection:
        return .none
        
      case .moveToFilterWithTopic:
        return .none
        
      case .moveToInformation:
        return .none
        
      case let .logError(error):
        return .run { _ in
          Log.error(error)
        }
      }
    }
  }
}

public struct HomeCoreError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any] = [:]
  public var code: Code
  public var underlying: Error?
  
  public enum Code: Int, Sendable {
    case failToSupabaseClientInitialized
    case failToFetchNewReleases
    case failToGetImageUrl
    case failToFetchImage
    case failToFetchAwards
  }
}
