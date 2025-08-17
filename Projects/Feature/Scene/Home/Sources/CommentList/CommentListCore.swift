//
//  CommentListCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 8/17/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core
import DesignSystem

import ComposableArchitecture

@Reducer
public struct CommentListCore {
  @ObservableState
  public struct State: Equatable {
    public var isLoading: Bool = false
    public var isLoadingMore: Bool = false
    public var commentedMakgeollis: [UserComment] = []
    public var makgeolliImages: [UUID: URL] = [:]
    public var makgeolliInfo: [UUID: Makgeolli] = [:]
    public var userReactions: [UUID: String] = [:]
    public var currentPage: Int = 0
    public var hasMoreData: Bool = true
    public var pageSize: Int = 10
    
    public init() { }
  }
  
  public enum Action {
    case onAppear
    case dismiss
    
    case fetchCommentedMakgeollis
    case commentedMakgeollisResponse(TaskResult<[UserComment]>)
    case loadMoreComments
    case loadMoreCommentsResponse(TaskResult<[UserComment]>)
    case fetchMakgeolliInfo(UserComment)
    case makgeolliInfoResponse(UserComment, TaskResult<Makgeolli?>)
    case fetchMakgeolliImage(Makgeolli)
    case makgeolliImageResponse(id: UUID, TaskResult<URL>)
    case loadUserReaction(UserComment)
    case updateUserReaction(commentId: UUID, String?)
    
    case commentItemTapped(UserComment)
    case moveToInformation(Makgeolli, URL?)
    
    case logError(CommentListCoreError)
    case showToast(String, ToastType)
  }
  
  public init() { }
  
  @Dependency(\.supabaseClient) var supabaseClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        if !state.isLoading && state.commentedMakgeollis.isEmpty {
          return .send(.fetchCommentedMakgeollis)
        }
        return .none
        
      case .dismiss:
        return .none
        
      case .fetchCommentedMakgeollis:
        state.isLoading = true
        state.currentPage = 0
        state.hasMoreData = true
        let supabaseClient = self.supabaseClient
        let pageSize = state.pageSize
        return .run { send in
          do {
            let comments = try await supabaseClient.getRecentCommentsPaginated(pageSize, 0)
            await send(.commentedMakgeollisResponse(.success(comments)))
          } catch {
            await send(.commentedMakgeollisResponse(.failure(error)))
          }
        }
        
      case let .commentedMakgeollisResponse(.success(comments)):
        state.isLoading = false
        state.commentedMakgeollis = comments
        state.currentPage = 1
        state.hasMoreData = comments.count == state.pageSize
        return .merge(
          comments.compactMap { comment in
            return .send(.fetchMakgeolliInfo(comment))
          }
        )
        
      case let .commentedMakgeollisResponse(.failure(error)):
        state.isLoading = false
        return .send(.logError(CommentListCoreError(
          code: .failToFetchComments,
          underlying: error
        )))
        
      case .loadMoreComments:
        guard state.hasMoreData && !state.isLoadingMore else {
          return .none
        }
        
        state.isLoadingMore = true
        let supabaseClient = self.supabaseClient
        let pageSize = state.pageSize
        let offset = state.currentPage * pageSize
        return .run { send in
          do {
            let comments = try await supabaseClient.getRecentCommentsPaginated(pageSize, offset)
            await send(.loadMoreCommentsResponse(.success(comments)))
          } catch {
            await send(.loadMoreCommentsResponse(.failure(error)))
          }
        }
        
      case let .loadMoreCommentsResponse(.success(comments)):
        state.isLoadingMore = false
        state.commentedMakgeollis.append(contentsOf: comments)
        state.currentPage += 1
        state.hasMoreData = comments.count == state.pageSize
        return .merge(
          comments.compactMap { comment in
            return .send(.fetchMakgeolliInfo(comment))
          }
        )
        
      case let .loadMoreCommentsResponse(.failure(error)):
        state.isLoadingMore = false
        return .send(.logError(CommentListCoreError(
          code: .failToFetchComments,
          underlying: error
        )))
        
      case let .fetchMakgeolliInfo(comment):
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let makgeolli = try await supabaseClient.fetchMakgeolliById(comment.makgeolliId)
            await send(.makgeolliInfoResponse(comment, .success(makgeolli)))
          } catch {
            await send(.makgeolliInfoResponse(comment, .failure(error)))
          }
        }
        
      case let .makgeolliInfoResponse(comment, .success(makgeolli)):
        guard let makgeolli = makgeolli else { return .none }
        state.makgeolliInfo[comment.makgeolliId] = makgeolli
        return .merge(
          .send(.fetchMakgeolliImage(makgeolli)),
          .send(.loadUserReaction(comment))
        )
        
      case let .makgeolliInfoResponse(_, .failure(error)):
        return .send(.logError(CommentListCoreError(
          code: .failToFetchMakgeolliInfo,
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
        return .send(.logError(CommentListCoreError(
          code: .failToFetchImage,
          underlying: error
        )))
        
      case let .loadUserReaction(comment):
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let reactionType = try await supabaseClient.getUserReaction(comment.userId, comment.makgeolliId)
            await send(.updateUserReaction(commentId: comment.id, reactionType))
          } catch {
            await send(.updateUserReaction(commentId: comment.id, nil))
          }
        }
        
      case let .updateUserReaction(commentId, reactionType):
        state.userReactions[commentId] = reactionType
        return .none
        
      case let .commentItemTapped(comment):
        guard let makgeolli = state.makgeolliInfo[comment.makgeolliId] else {
          return .none
        }
        let imageURL = state.makgeolliImages[makgeolli.id]
        return .send(.moveToInformation(makgeolli, imageURL))
        
      case .moveToInformation:
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
  
  private func getErrorMessage(for code: CommentListCoreError.Code) -> String {
    switch code {
    case .failToFetchComments:
      return "코멘트 목록을 불러오지 못했습니다."
    case .failToFetchMakgeolliInfo:
      return "막걸리 정보를 불러오지 못했습니다."
    case .failToFetchImage:
      return "이미지를 불러오지 못했습니다."
    }
  }
}

public struct CommentListCoreError: JulookError, @unchecked Sendable {
  public var userInfo: [String: Any] = [:]
  public var code: Code
  public var underlying: Error?
  
  public enum Code: Int, Sendable {
    case failToFetchComments
    case failToFetchMakgeolliInfo
    case failToFetchImage
  }
}
