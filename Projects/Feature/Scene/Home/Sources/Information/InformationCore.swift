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
    public var reactionCounts: MakgeolliReactionCount? = nil
    public var userComment: UserComment? = nil
    public var isShowingCommentSheet: Bool = false
    public var isShowingEditActionSheet: Bool = false
    public var isShowingDeleteAlert: Bool = false
    public var isShowingCommentsSheet: Bool = false
    public var publicComments: [UserComment] = []
    public var userReactions: [UUID: String] = [:]
    
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
    
    case loadReactionCounts
    case updateReactionCounts(MakgeolliReactionCount?)
    
    case commentSectionTapped
    case showCommentSheet(Bool)
    case showEditActionSheet(Bool)
    case showDeleteAlert(Bool)
    case showCommentsSheet(Bool)
    case confirmDelete
    case loadUserComment
    case updateUserComment(UserComment?)
    case saveComment(String, Bool)
    case commentSaved
    case deleteComment
    case commentDeleted
    
    case loadPublicComments
    case updatePublicComments([UserComment])
    case loadUserReactions([UUID])
    case updateUserReactions([UUID: String])
    
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
        Amp.track(event: "makgeolli_detail_viewed", properties: [
          "makgeolli_name": state.makgeolli.name
        ])
        
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
          .send(.loadReaction),
          .send(.loadReactionCounts),
          .send(.loadUserComment),
          .send(.loadPublicComments)
        )
        
      case .dismiss:
        return .none
        
      case .likeButtonTapped:
        let newReaction = state.currentReaction == "like" ? nil : "like"
        Amp.track(event: "like_button_clicked", properties: [
          "makgeolli_name": state.makgeolli.name,
          "reaction_type": newReaction ?? "removed"
        ])
        return .send(.updateReaction(newReaction))
        
      case .dislikeButtonTapped:
        let newReaction = state.currentReaction == "dislike" ? nil : "dislike"
        Amp.track(event: "dislike_button_clicked", properties: [
          "makgeolli_name": state.makgeolli.name,
          "reaction_type": newReaction ?? "removed"
        ])
        return .send(.updateReaction(newReaction))
        
      case .favoriteButtonTapped:
        let newFavoriteStatus = !state.isFavorite
        Amp.track(event: "favorite_button_clicked", properties: [
          "makgeolli_name": state.makgeolli.name,
          "favorite_status": newFavoriteStatus ? "added" : "removed"
        ])
        
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
            await send(.loadReactionCounts)
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
        
      case .loadReactionCounts:
        let supabaseClient = self.supabaseClient
        return .run { [makgeolliId = state.makgeolli.id] send in
          do {
            let reactionCounts = try await supabaseClient.getReactionCounts(makgeolliId)
            await send(.updateReactionCounts(reactionCounts))
          } catch {
            await send(.logError(InformationCoreError(
              code: .failToLoadReactionCounts,
              underlying: error
            )))
          }
        }
        
      case let .updateReactionCounts(reactionCounts):
        state.reactionCounts = reactionCounts
        return .none
        
      case .commentSectionTapped:
        Amp.track(event: "comment_section_tapped", properties: [
          "makgeolli_name": state.makgeolli.name
        ])
        
        if state.userComment != nil {
          return .send(.showEditActionSheet(true))
        } else {
          return .send(.showCommentSheet(true))
        }
        
      case let .showCommentSheet(isShowing):
        state.isShowingCommentSheet = isShowing
        return .none
        
      case let .showEditActionSheet(isShowing):
        state.isShowingEditActionSheet = isShowing
        return .none
        
      case let .showDeleteAlert(isShowing):
        state.isShowingDeleteAlert = isShowing
        return .none
        
      case let .showCommentsSheet(isShowing):
        state.isShowingCommentsSheet = isShowing
        return .none
        
      case .confirmDelete:
        return .send(.deleteComment)
        
      case .loadUserComment:
        let supabaseClient = self.supabaseClient
        return .run { [makgeolliId = state.makgeolli.id] send in
          do {
            let userId = getUserID()
            let userComment = try await supabaseClient.getUserComment(userId, makgeolliId)
            await send(.updateUserComment(userComment))
          } catch {
            await send(.logError(InformationCoreError(
              code: .failToLoadUserComment,
              underlying: error
            )))
          }
        }
        
      case let .updateUserComment(userComment):
        state.userComment = userComment
        return .none
        
      case let .saveComment(comment, isPublic):
        Amp.track(event: "comment_saved", properties: [
          "makgeolli_name": state.makgeolli.name,
          "is_public": isPublic
        ])
        
        let supabaseClient = self.supabaseClient
        return .run { [makgeolliId = state.makgeolli.id] send in
          do {
            let userId = getUserID()
            try await supabaseClient.saveUserComment(userId, makgeolliId, comment, isPublic)
            await send(.commentSaved)
          } catch {
            await send(.logError(InformationCoreError(
              code: .failToSaveUserComment,
              underlying: error
            )))
          }
        }
        
      case .commentSaved:
        return .merge(
          .send(.loadUserComment),
          .send(.loadPublicComments),
          .send(.showCommentSheet(false)),
          .send(.showEditActionSheet(false)),
          .run { _ in
            await MainActor.run {
              NotificationCenter.default.post(
                name: .myMakgeolliDataChanged,
                object: nil
              )
            }
          }
        )
        
      case .deleteComment:
        Amp.track(event: "comment_deleted", properties: [
          "makgeolli_name": state.makgeolli.name
        ])
        
        let supabaseClient = self.supabaseClient
        return .run { [makgeolliId = state.makgeolli.id] send in
          do {
            let userId = getUserID()
            try await supabaseClient.deleteUserComment(userId, makgeolliId)
            await send(.commentDeleted)
          } catch {
            await send(.logError(InformationCoreError(
              code: .failToDeleteUserComment,
              underlying: error
            )))
          }
        }
        
      case .commentDeleted:
        return .merge(
          .send(.loadUserComment),
          .send(.loadPublicComments),
          .send(.showDeleteAlert(false)),
          .send(.showEditActionSheet(false)),
          .run { _ in
            await MainActor.run {
              NotificationCenter.default.post(
                name: .myMakgeolliDataChanged,
                object: nil
              )
            }
          }
        )
        
      case .loadPublicComments:
        let supabaseClient = self.supabaseClient
        return .run { [makgeolliId = state.makgeolli.id] send in
          do {
            let publicComments = try await supabaseClient.getPublicComments(makgeolliId)
            await send(.updatePublicComments(publicComments))
          } catch {
            await send(.logError(InformationCoreError(
              code: .failToLoadPublicComments,
              underlying: error
            )))
          }
        }
        
      case let .updatePublicComments(publicComments):
        state.publicComments = publicComments
        let userIds = publicComments.map { $0.userId }
        return .send(.loadUserReactions(userIds))
        
      case let .loadUserReactions(userIds):
        let supabaseClient = self.supabaseClient
        return .run { [makgeolliId = state.makgeolli.id] send in
          var reactions: [UUID: String] = [:]
          
          for userId in userIds {
            do {
              if let reactionType = try await supabaseClient.getUserReaction(userId, makgeolliId) {
                reactions[userId] = reactionType
              }
            } catch {
              
            }
          }
          
          await send(.updateUserReactions(reactions))
        }
        
      case let .updateUserReactions(userReactions):
        state.userReactions = userReactions
        return .none
        
      case let .logError(error):
        let message = getErrorMessage(for: error.code)
        return .merge(
          .run { _ in Log.error(error) },
          .run { _ in
            NotificationCenter.default.post(
              name: .showToast,
              object: nil,
              userInfo: ["message": message, "type": "error"]
            )
          }
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
    case .failToLoadReactionCounts:
      return "평가 통계를 불러오지 못했습니다."
    case .failToLoadUserComment:
      return "내 코멘트를 불러오지 못했습니다."
    case .failToSaveUserComment:
      return "코멘트 저장에 실패했습니다."
    case .failToDeleteUserComment:
      return "코멘트 삭제에 실패했습니다."
    case .failToLoadPublicComments:
      return "다른 유저의 코멘트를 불러오지 못했습니다."
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
    case failToLoadReactionCounts
    case failToLoadUserComment
    case failToSaveUserComment
    case failToDeleteUserComment
    case failToLoadPublicComments
  }
}
