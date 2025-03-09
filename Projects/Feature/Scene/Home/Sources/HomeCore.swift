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
  public init() { }
  
  @ObservableState
  public struct State: Equatable {
    public init() { }
    
    var isLoadingNewReleases: Bool = false
    var newReleases: [Makgeolli] = []
    var newReleasesImages: [UUID: URL] = [:]
    
    var isLoadingAwards: Bool = false
    var awards: [Award] = []
  }
  
  public enum Action {
    case onAppear
    
    case fetchNewReleases
    case newReleasesResponse(TaskResult<[Makgeolli]>)
    
    case fetchNewReleasesImage(Makgeolli)
    case newReleasesImageResponse(id: UUID, TaskResult<URL>)
    
    case fetchAwards
    case awardsResponse(TaskResult<[Award]>)
    
    case logError(HomeCoreError)
  }
  
  private enum Constants {
    static let storageBucket = "makgeolli_image"
  }
  
  @Dependency(\.supabaseClient) var supabaseClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .merge(
          .send(.fetchNewReleases),
          .send(.fetchAwards)
        )
        
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
            let publicURL = try await supabaseClient.getPublicURL(Constants.storageBucket, fileName)
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
