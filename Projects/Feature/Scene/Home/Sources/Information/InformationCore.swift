//
//  InformationCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/11/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core
import DesignSystem

import ComposableArchitecture

@Reducer
public struct InformationCore: Sendable {
  @ObservableState
  public struct State: Equatable {
    public var makgeolli: Makgeolli
    public var makgeolliImage: URL?
    public var likeButtonState: ReactionButtonState = .active
    public var dislikeButtonState: ReactionButtonState = .active
    public var isFavorite: Bool = false
    
    public init(makgeolli: Makgeolli, makgeolliImage: URL? = nil) {
      self.makgeolli = makgeolli
      self.makgeolliImage = makgeolliImage
    }
  }
  
  public enum Action {
    case onAppear
    
    case dismiss
    case likeButtonTapped
    case dislikeButtonTapped
    case favoriteButtonTapped
    case updateFavoriteStatus(Bool)
    
    case logError(InformationCoreError)
  }
  
  public init() { }
  
  @Dependency(\.myMakgeolliClient) var myMakgeolliClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .run { [makgeolli = state.makgeolli] send in
          do {
            let isFavorite = try await myMakgeolliClient.isFavorite(makgeolli.id)
            await send(.updateFavoriteStatus(isFavorite))
          } catch {
            await send(.updateFavoriteStatus(false))
            await send(.logError(InformationCoreError(
              code: .failToCheckFavoriteStatus,
              underlying: error
            )))
          }
        }
        
      case .dismiss:
        return .none
        
      case .likeButtonTapped:
        return .none
        
      case .dislikeButtonTapped:
        return .none
        
      case .favoriteButtonTapped:
        return .run { [makgeolli = state.makgeolli] send in
          await myMakgeolliClient.toggleFavorite(makgeolli)
          do {
            let newFavoriteStatus = try await myMakgeolliClient.isFavorite(makgeolli.id)
            await send(.updateFavoriteStatus(newFavoriteStatus))
          } catch {
            await send(.logError(InformationCoreError(
              code: .failToUpdateFavoriteStatus,
              underlying: error
            )))
          }
        }
        
      case let .updateFavoriteStatus(isFavorite):
        state.isFavorite = isFavorite
        return .none
        
      case let .logError(error):
        return .run { _ in
          Log.error(error)
        }
      }
    }
  }
}

public struct InformationCoreError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any] = [:]
  public var code: Code
  public var underlying: Error?
  
  public init(
    code: Code,
    underlying: Error? = nil
  ) {
    self.code = code
    self.underlying = underlying
  }
  
  public enum Code: Int, Sendable {
    case failToCheckFavoriteStatus
    case failToUpdateFavoriteStatus
  }
}
