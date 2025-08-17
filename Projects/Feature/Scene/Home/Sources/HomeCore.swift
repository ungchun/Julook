//
//  HomeCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import Security

import Core
import DesignSystem

import ComposableArchitecture
import Supabase

@Reducer
public struct HomeCore {
  @ObservableState
  public struct State: Equatable {
    public var isInitialized: Bool = false
    
    // 신상 막걸리
    public var isLoadingNewReleases: Bool = false
    public var newReleases: [Makgeolli] = []
    public var newReleasesImages: [UUID: URL] = [:]
    
    // 수상
    public var isLoadingAwards: Bool = false
    public var awards: [Award] = []
    
    // 오늘의 랭킹
    public var isLoadingTopLiked: Bool = false
    public var topLikedMakgeollis: [Makgeolli] = []
    public var topLikedImages: [UUID: URL] = [:]
    public var topLikedFavoriteStatus: [UUID: Bool] = [:]
    
    // 최근 코멘트
    public var isLoadingRecentComments: Bool = false
    public var recentComments: [UserComment] = []
    public var recentCommentMakgeollis: [UUID: Makgeolli] = [:]
    public var recentCommentImages: [UUID: URL] = [:]
    public var recentCommentReactions: [UUID: String] = [:]
    
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
    case topLikedItemTapped(Makgeolli)
    case topLikedFavoriteButtonTapped(Makgeolli)
    
    // 신상 막걸리
    case fetchNewReleases
    case newReleasesResponse(TaskResult<[Makgeolli]>)
    case fetchNewReleasesImage(Makgeolli)
    case newReleasesImageResponse(id: UUID, TaskResult<URL>)
    
    // 수상
    case fetchAwards
    case awardsResponse(TaskResult<[Award]>)
    
    // 오늘의 랭킹
    case fetchTopLikedMakgeollis
    case topLikedMakgeollisResponse(TaskResult<[Makgeolli]>)
    case fetchTopLikedImage(Makgeolli)
    case topLikedImageResponse(id: UUID, TaskResult<URL>)
    case loadTopLikedFavoriteStatus(Makgeolli)
    case updateTopLikedFavoriteStatus(id: UUID, Bool)
    
    // 최근 코멘트
    case fetchRecentComments
    case recentCommentsResponse(TaskResult<[UserComment]>)
    case fetchRecentCommentMakgeolli(UserComment)
    case recentCommentMakgeolliResponse(UserComment, TaskResult<Makgeolli?>)
    case fetchRecentCommentImage(Makgeolli)
    case recentCommentImageResponse(id: UUID, TaskResult<URL>)
    case loadRecentCommentReaction(UserComment)
    case updateRecentCommentReaction(commentId: UUID, String?)
    case recentCommentItemTapped(UserComment)
    
    // 네비게이션
    case moveToFilter
    case moveToFilterWithSelection(FilterType)
    case moveToFilterWithTopic(String)
    case moveToInformation(Makgeolli, URL?)
    case moveToCommentList
    
    case logError(HomeCoreError)
    case showToast(String, ToastType)
  }
  
  public init() { }
  
  @Dependency(\.supabaseClient) var supabaseClient
  @Dependency(\.myMakgeolliClient) var myMakgeolliClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        if state.isInitialized {
          return .none
        }
        state.isInitialized = true
        
        if !state.isLoadingNewReleases && !state.isLoadingAwards && !state.isLoadingTopLiked && !state.isLoadingRecentComments {
          return .merge(
            .send(.fetchNewReleases),
            .send(.fetchAwards),
            .send(.fetchTopLikedMakgeollis),
            .send(.fetchRecentComments)
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
        
      case let .topLikedItemTapped(makgeolli):
        let imageURL = state.topLikedImages[makgeolli.id]
        return .send(.moveToInformation(makgeolli, imageURL))
        
      case let .topLikedFavoriteButtonTapped(makgeolli):
        let newFavoriteStatus = !(state.topLikedFavoriteStatus[makgeolli.id] ?? false)
        Amp.track(event: "top_liked_favorite_clicked", properties: [
          "makgeolli_name": makgeolli.name,
          "favorite_status": newFavoriteStatus ? "added" : "removed"
        ])
        
        let myMakgeolliClient = self.myMakgeolliClient
        return .run { send in
          await myMakgeolliClient.toggleFavorite(makgeolli)
          do {
            let isFavorite = try await myMakgeolliClient.isFavorite(makgeolli.id)
            await send(.updateTopLikedFavoriteStatus(id: makgeolli.id, isFavorite))
          } catch {
            await send(.logError(HomeCoreError(
              code: .failToUpdateFavoriteStatus,
              underlying: error
            )))
          }
        }
        
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
        
      case .fetchTopLikedMakgeollis:
        state.isLoadingTopLiked = true
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let makgeollis = try await supabaseClient.fetchTopLikedMakgeollis()
            await send(.topLikedMakgeollisResponse(.success(makgeollis)))
          } catch {
            await send(.topLikedMakgeollisResponse(.failure(error)))
          }
        }
        
      case let .topLikedMakgeollisResponse(.success(makgeollis)):
        state.isLoadingTopLiked = false
        state.topLikedMakgeollis = makgeollis
        return .merge(
          makgeollis.flatMap { makgeolli in
            [
              .send(.fetchTopLikedImage(makgeolli)),
              .send(.loadTopLikedFavoriteStatus(makgeolli))
            ]
          }
        )
        
      case let .topLikedMakgeollisResponse(.failure(error)):
        state.isLoadingTopLiked = false
        return .send(.logError(HomeCoreError(
          code: .failToFetchTopLiked,
          underlying: error
        )))
        
      case let .fetchTopLikedImage(makgeolli):
        guard let imageName = makgeolli.imageName else {
          return .none
        }
        
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
            let publicURL = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)
            await send(.topLikedImageResponse(id: makgeolli.id, .success(publicURL)))
          } catch {
            await send(.topLikedImageResponse(id: makgeolli.id, .failure(error)))
          }
        }
        
      case let .topLikedImageResponse(id, .success(url)):
        state.topLikedImages[id] = url
        return .none
        
      case let .topLikedImageResponse(_, .failure(error)):
        return .send(.logError(HomeCoreError(
          code: .failToFetchImage,
          underlying: error
        )))
        
      case let .loadTopLikedFavoriteStatus(makgeolli):
        let myMakgeolliClient = self.myMakgeolliClient
        return .run { send in
          do {
            let isFavorite = try await myMakgeolliClient.isFavorite(makgeolli.id)
            await send(.updateTopLikedFavoriteStatus(id: makgeolli.id, isFavorite))
          } catch {
            await send(.updateTopLikedFavoriteStatus(id: makgeolli.id, false))
          }
        }
        
      case let .updateTopLikedFavoriteStatus(id, isFavorite):
        state.topLikedFavoriteStatus[id] = isFavorite
        return .none
        
      case .fetchRecentComments:
        state.isLoadingRecentComments = true
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let comments = try await supabaseClient.getRecentComments()
            await send(.recentCommentsResponse(.success(comments)))
          } catch {
            await send(.recentCommentsResponse(.failure(error)))
          }
        }
        
      case let .recentCommentsResponse(.success(comments)):
        state.isLoadingRecentComments = false
        state.recentComments = comments
        return .merge(
          comments.compactMap { comment in
            return .send(.fetchRecentCommentMakgeolli(comment))
          }
        )
        
      case let .recentCommentsResponse(.failure(error)):
        state.isLoadingRecentComments = false
        return .send(.logError(HomeCoreError(
          code: .failToFetchRecentComments,
          underlying: error
        )))
        
      case let .fetchRecentCommentMakgeolli(comment):
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let makgeolli = try await supabaseClient.fetchMakgeolliById(comment.makgeolliId)
            await send(.recentCommentMakgeolliResponse(comment, .success(makgeolli)))
          } catch {
            await send(.recentCommentMakgeolliResponse(comment, .failure(error)))
          }
        }
        
      case let .recentCommentMakgeolliResponse(comment, .success(makgeolli)):
        guard let makgeolli = makgeolli else { return .none }
        state.recentCommentMakgeollis[comment.makgeolliId] = makgeolli
        return .merge(
          .send(.fetchRecentCommentImage(makgeolli)),
          .send(.loadRecentCommentReaction(comment))
        )
        
      case let .recentCommentMakgeolliResponse(_, .failure(error)):
        return .send(.logError(HomeCoreError(
          code: .failToFetchRecentComments,
          underlying: error
        )))
        
      case let .fetchRecentCommentImage(makgeolli):
        guard let imageName = makgeolli.imageName else {
          return .none
        }
        
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
            let publicURL = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)
            await send(.recentCommentImageResponse(id: makgeolli.id, .success(publicURL)))
          } catch {
            await send(.recentCommentImageResponse(id: makgeolli.id, .failure(error)))
          }
        }
        
      case let .recentCommentImageResponse(id, .success(url)):
        state.recentCommentImages[id] = url
        return .none
        
      case let .recentCommentImageResponse(_, .failure(error)):
        return .send(.logError(HomeCoreError(
          code: .failToFetchImage,
          underlying: error
        )))
        
      case let .loadRecentCommentReaction(comment):
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let reactionType = try await supabaseClient.getUserReaction(comment.userId, comment.makgeolliId)
            await send(.updateRecentCommentReaction(commentId: comment.id, reactionType))
          } catch {
            await send(.updateRecentCommentReaction(commentId: comment.id, nil))
          }
        }
        
      case let .updateRecentCommentReaction(commentId, reactionType):
        state.recentCommentReactions[commentId] = reactionType
        return .none
        
      case let .recentCommentItemTapped(comment):
        guard let makgeolli = state.recentCommentMakgeollis[comment.makgeolliId] else {
          return .none
        }
        let imageURL = state.recentCommentImages[makgeolli.id]
        return .send(.moveToInformation(makgeolli, imageURL))
        
      case .moveToFilter:
        return .none
        
      case .moveToFilterWithSelection:
        return .none
        
      case .moveToFilterWithTopic:
        return .none
        
      case .moveToInformation:
        return .none
        
      case .moveToCommentList:
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

private extension HomeCore {
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
  
  func getErrorMessage(for code: HomeCoreError.Code) -> String {
    switch code {
    case .failToSupabaseClientInitialized:
      return "서비스 연결에 실패했습니다."
    case .failToFetchNewReleases:
      return "새로운 막걸리 정보를 불러오지 못했습니다."
    case .failToGetImageUrl:
      return "이미지를 불러오지 못했습니다."
    case .failToFetchImage:
      return "이미지 로딩에 실패했습니다."
    case .failToFetchAwards:
      return "수상 정보를 불러오지 못했습니다."
    case .failToFetchTopLiked:
      return "인기 막걸리 정보를 불러오지 못했습니다."
    case .failToUpdateFavoriteStatus:
      return "찜 상태 변경에 실패했습니다."
    case .failToFetchRecentComments:
      return "최근 코멘트를 불러오지 못했습니다."
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
    case failToFetchTopLiked
    case failToUpdateFavoriteStatus
    case failToFetchRecentComments
  }
}
