//
//  InformationCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/11/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import Security

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
    public var currentReaction: String? = nil
    
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
    case favoriteStatusChanged
    
    case loadReaction
    case updateReaction(String?)
    case updateReactionState(String?)
    case reactionSaved
    case reactionStatusChanged
    
    case logError(InformationCoreError)
    case showToast(String, ToastType)
  }
  
  public init() { }
  
  @Dependency(\.myMakgeolliClient) var myMakgeolliClient
  @Dependency(\.makgeolliReactionClient) var makgeolliReactionClient
  @Dependency(\.supabaseClient) var supabaseClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .merge(
          .run { [makgeolli = state.makgeolli] send in
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
          },
          .send(.loadReaction)
        )
        
      case .dismiss:
        return .none
        
      case .likeButtonTapped:
        let newReaction = state.currentReaction == "like" ? nil : "like"
        return .send(.updateReaction(newReaction))
        
      case .dislikeButtonTapped:
        let newReaction = state.currentReaction == "dislike" ? nil : "dislike"
        return .send(.updateReaction(newReaction))
        
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
        let previousStatus = state.isFavorite
        state.isFavorite = isFavorite
        
        if previousStatus != isFavorite {
          return .send(.favoriteStatusChanged)
        }
        return .none
        
      case .favoriteStatusChanged:
        return .none
        
      case .loadReaction:
        return .run { [makgeolliId = state.makgeolli.id] send in
          do {
            let reaction = try await makgeolliReactionClient.getReaction(makgeolliId)
            let reactionType: String? = reaction?.reactionType
            await send(.updateReactionState(reactionType))
          } catch {
            await send(.logError(InformationCoreError(
              code: .failToLoadReaction,
              underlying: error
            )))
          }
        }
        
      case let .updateReaction(reactionType):
        state.currentReaction = reactionType
        
        if reactionType == "like" {
          state.likeButtonState = .active
          state.dislikeButtonState = .disabled
        } else if reactionType == "dislike" {
          state.likeButtonState = .disabled
          state.dislikeButtonState = .active
        } else {
          state.likeButtonState = .disabled
          state.dislikeButtonState = .disabled
        }
        
        return .run { [makgeolliId = state.makgeolli.id] send in
          do {
            try await makgeolliReactionClient.saveReaction(makgeolliId, reactionType)
            
            let userId = getUserID()
            if let reactionType = reactionType {
              try await supabaseClient.saveReaction(userId, makgeolliId, reactionType)
            } else {
              try await supabaseClient.deleteReaction(userId, makgeolliId)
            }
            
            await send(.reactionSaved)
          } catch {
            await send(.logError(InformationCoreError(
              code: .failToSaveReaction,
              underlying: error
            )))
          }
        }
        
      case let .updateReactionState(reactionType):
        state.currentReaction = reactionType
        
        if reactionType == "like" {
          state.likeButtonState = .active
          state.dislikeButtonState = .disabled
        } else if reactionType == "dislike" {
          state.likeButtonState = .disabled
          state.dislikeButtonState = .active
        } else {
          state.likeButtonState = .disabled
          state.dislikeButtonState = .disabled
        }
        
        return .none
        
      case .reactionSaved:
        return .send(.reactionStatusChanged)
        
      case .reactionStatusChanged:
        return .none
        
      case let .logError(error):
        let message = getErrorMessage(for: error.code)
        return .merge(
          .run { _ in Log.error(error) },
          .send(.showToast(message, .error))
        )
        
      case .showToast(_, _):
        return .none
      }
    }
  }
}

private extension InformationCore {
  func getUserID() -> UUID {
    let service = "com.azhy.julook"
    let account = "user_id"
    
    if let existingID = getKeychainValue(service: service, account: account),
       let uuid = UUID(uuidString: existingID) {
      return uuid
    }
    
    let newId = UUID()
    setKeychainValue(service: service, account: account, value: newId.uuidString)
    return newId
  }
  
  func getKeychainValue(service: String, account: String) -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true
    ]
    
    var result: CFTypeRef?
    let status = SecItemCopyMatching(query as CFDictionary, &result)
    
    guard status == errSecSuccess,
          let data = result as? Data,
          let value = String(data: data, encoding: .utf8) else {
      return nil
    }
    
    return value
  }
  
  func setKeychainValue(service: String, account: String, value: String) {
    let data = value.data(using: .utf8)!
    
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecValueData as String: data
    ]
    
    SecItemDelete(query as CFDictionary)
    SecItemAdd(query as CFDictionary, nil)
  }
  
  func getErrorMessage(for code: InformationCoreError.Code) -> String {
    switch code {
    case .failToCheckFavoriteStatus:
      return "찜 상태를 확인하지 못했습니다."
    case .failToUpdateFavoriteStatus:
      return "찜 상태 변경에 실패했습니다."
    case .failToLoadReaction:
      return "반응 정보를 불러오지 못했습니다."
    case .failToSaveReaction:
      return "반응 저장에 실패했습니다."
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
    case failToLoadReaction
    case failToSaveReaction
  }
}
