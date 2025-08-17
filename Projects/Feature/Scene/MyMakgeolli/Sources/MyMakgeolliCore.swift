//
//  MyMakgeolliCore.swift
//  FeatureMyMakgeolli
//
//  Created by Kim SungHun on 7/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import Security

import Core
import DesignSystem

import ComposableArchitecture

public enum MyMakgeolliFilterTab: String, CaseIterable, Equatable {
  case all = "전체"
  case like = "좋았어요"
  case dislike = "아쉬워요"
  case favorite = "찜"
  case comment = "코멘트"
}

@Reducer
public struct MyMakgeolliCore: Sendable{
  @ObservableState
  public struct State: Equatable {
    public var isInitialized: Bool = false
    public var isLoading: Bool = false
    public var selectedTab: MyMakgeolliFilterTab = .all
    public var allMyMakgeollis: [MyMakgeolliEntity] = []
    public var likedMakgeollis: [MyMakgeolliEntity] = []
    public var dislikedMakgeollis: [MyMakgeolliEntity] = []
    public var favoriteMakgeollis: [MyMakgeolliEntity] = []
    public var commentMakgeollis: [MyMakgeolliEntity] = []
    public var makgeolliImages: [UUID: URL] = [:]
    public var myMakgeollis: [MyMakgeolliEntity] {
      switch selectedTab {
      case .all:
        return allMyMakgeollis
      case .like:
        return likedMakgeollis
      case .dislike:
        return dislikedMakgeollis
      case .favorite:
        return favoriteMakgeollis
      case .comment:
        return commentMakgeollis
      }
    }
    
    public init() { }
  }
  
  public enum Action {
    case viewAppeared
    
    case tabSelected(MyMakgeolliFilterTab)
    case refreshMyMakgeollis
    case loadReactionData
    case myMakgeolliDataChanged
    case updateAllData(
      [MyMakgeolliEntity], [MyMakgeolliEntity], [MyMakgeolliEntity], [MyMakgeolliEntity], [MyMakgeolliEntity]
    )
    case loadMakgeolliImages([MyMakgeolliEntity])
    case loadNewMakgeolliImages([MyMakgeolliEntity])
    case updateMakgeolliImage(UUID, URL)
    case myMakgeolliItemTapped(MyMakgeolliEntity)
    case fetchMakgeolliResponse(MyMakgeolliEntity, TaskResult<Makgeolli?>)
    
    case moveToInformation(Makgeolli, URL?)
    
    case logError(MyMakgeolliCoreError)
    case showToast(String, ToastType)
  }
  
  public init() { }
  
  @Dependency(\.myMakgeolliClient) var myMakgeolliClient
  @Dependency(\.makgeolliReactionClient) var makgeolliReactionClient
  @Dependency(\.supabaseClient) var supabaseClient
  
  private func getUserID() -> UUID {
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
  
  private func getKeychainValue(service: String, account: String) -> String? {
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
  
  private func setKeychainValue(service: String, account: String, value: String) {
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
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .viewAppeared:
        if state.isInitialized {
          return .none
        }
        state.isInitialized = true
        state.isLoading = true
        return .send(.loadReactionData)
        
      case let .tabSelected(tab):
        state.selectedTab = tab
        return .none
        
      case .refreshMyMakgeollis:
        return .send(.loadReactionData)
        
      case .myMakgeolliDataChanged:
        return .send(.loadReactionData)
        
      case .loadReactionData:
        return .run { send in
          do {
            let favoriteMakgeollis = try await myMakgeolliClient.getMyMakgeollis()
            let allReactions = try await makgeolliReactionClient.getAllReactions()
            
            // 유저 코멘트가 있는 막걸리들 조회
            let userId = getUserID()
            let userComments = try await supabaseClient.getUserComments(userId)
            
            var likedMakgeollis: [MyMakgeolliEntity] = []
            var dislikedMakgeollis: [MyMakgeolliEntity] = []
            var commentMakgeollis: [MyMakgeolliEntity] = []
            var allMakgeollisMap: [UUID: MyMakgeolliEntity] = [:]
            
            for makgeolli in favoriteMakgeollis {
              allMakgeollisMap[makgeolli.id] = makgeolli
            }
            
            for reaction in allReactions {
              guard let reactionType = reaction.reactionType else { continue }
              
              if let favoriteMakgeolli = allMakgeollisMap[reaction.makgeolliId] {
                if reactionType == "like" {
                  likedMakgeollis.append(favoriteMakgeolli)
                } else if reactionType == "dislike" {
                  dislikedMakgeollis.append(favoriteMakgeolli)
                }
              } else {
                do {
                  if let makgeolliInfo = try await supabaseClient.fetchMakgeolliById(
                    reaction.makgeolliId
                  ) {
                    let makgeolliEntity = MyMakgeolliEntity(
                      id: makgeolliInfo.id,
                      name: makgeolliInfo.name,
                      imageName: makgeolliInfo.imageName,
                      feedback: nil,
                      isFavorite: false,
                      comment: nil,
                      createdAt: reaction.createdAt,
                      updatedAt: reaction.updatedAt
                    )
                    
                    allMakgeollisMap[reaction.makgeolliId] = makgeolliEntity
                    
                    if reactionType == "like" {
                      likedMakgeollis.append(makgeolliEntity)
                    } else if reactionType == "dislike" {
                      dislikedMakgeollis.append(makgeolliEntity)
                    }
                  }
                } catch {
                  
                }
              }
            }
            
            // 코멘트가 있는 막걸리들 추가
            for comment in userComments {
              if let existingMakgeolli = allMakgeollisMap[comment.makgeolliId] {
                commentMakgeollis.append(existingMakgeolli)
              } else {
                do {
                  if let makgeolliInfo = try await supabaseClient.fetchMakgeolliById(
                    comment.makgeolliId
                  ) {
                    let makgeolliEntity = MyMakgeolliEntity(
                      id: makgeolliInfo.id,
                      name: makgeolliInfo.name,
                      imageName: makgeolliInfo.imageName,
                      feedback: nil,
                      isFavorite: false,
                      comment: comment.comment,
                      createdAt: comment.createdAt,
                      updatedAt: comment.updatedAt
                    )
                    
                    commentMakgeollis.append(makgeolliEntity)
                    allMakgeollisMap[comment.makgeolliId] = makgeolliEntity
                  }
                } catch {
                  
                }
              }
            }
            
            let sortedAllMakgeollis = Array(allMakgeollisMap.values).sorted {
              $0.updatedAt > $1.updatedAt
            }
            let sortedLikedMakgeollis = likedMakgeollis.sorted {
              $0.updatedAt > $1.updatedAt
            }
            let sortedDislikedMakgeollis = dislikedMakgeollis.sorted {
              $0.updatedAt > $1.updatedAt
            }
            let sortedFavoriteMakgeollis = favoriteMakgeollis.sorted {
              $0.updatedAt > $1.updatedAt
            }
            let sortedCommentMakgeollis = commentMakgeollis.sorted {
              $0.updatedAt > $1.updatedAt
            }
            
            await send(.updateAllData(
              sortedAllMakgeollis,
              sortedLikedMakgeollis,
              sortedDislikedMakgeollis,
              sortedFavoriteMakgeollis,
              sortedCommentMakgeollis)
            )
          } catch {
            await send(.logError(MyMakgeolliCoreError(
              code: .failToFetchReactionData,
              underlying: error
            )))
          }
        }
        
      case let .updateAllData(allData, likedData, dislikedData, favoriteData, commentData):
        state.allMyMakgeollis = allData
        state.likedMakgeollis = likedData
        state.dislikedMakgeollis = dislikedData
        state.favoriteMakgeollis = favoriteData
        state.commentMakgeollis = commentData
        state.isLoading = false
        
        var allUniqueMakgeollis = Set<MyMakgeolliEntity>()
        allUniqueMakgeollis.formUnion(allData)
        allUniqueMakgeollis.formUnion(likedData)
        allUniqueMakgeollis.formUnion(dislikedData)
        allUniqueMakgeollis.formUnion(favoriteData)
        allUniqueMakgeollis.formUnion(commentData)
        
        let uniqueMakgeollisList = Array(allUniqueMakgeollis)
        
        return .send(.loadMakgeolliImages(uniqueMakgeollisList))
        
      case let .loadMakgeolliImages(myMakgeollis):
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            for makgeolli in myMakgeollis {
              group.addTask {
                guard let imageName = makgeolli.imageName else { return }
                
                do {
                  let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
                  let imageURL = try await supabaseClient.getPublicURL(
                    Bucket.MAKGEOLLIIMAGE,
                    fileName
                  )
                  await send(.updateMakgeolliImage(makgeolli.id, imageURL))
                } catch {
                  await send(.logError(MyMakgeolliCoreError(
                    code: .failToFetchImage,
                    underlying: error
                  )))
                }
              }
            }
          }
        }
        
      case let .loadNewMakgeolliImages(newMakgeollis):
        return .run { send in
          await withTaskGroup(of: Void.self) { group in
            for makgeolli in newMakgeollis {
              group.addTask {
                guard let imageName = makgeolli.imageName else { return }
                
                do {
                  let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
                  let imageURL = try await supabaseClient.getPublicURL(
                    Bucket.MAKGEOLLIIMAGE,
                    fileName
                  )
                  await send(.updateMakgeolliImage(makgeolli.id, imageURL))
                } catch {
                  await send(.logError(MyMakgeolliCoreError(
                    code: .failToFetchImage,
                    underlying: error
                  )))
                }
              }
            }
          }
        }
        
      case let .updateMakgeolliImage(id, url):
        state.makgeolliImages[id] = url
        return .none
        
      case let .myMakgeolliItemTapped(makgeolli):
        return .run { send in
          do {
            let fullMakgeolli = try await supabaseClient.fetchMakgeolliById(makgeolli.id)
            await send(.fetchMakgeolliResponse(makgeolli, .success(fullMakgeolli)))
          } catch {
            await send(.fetchMakgeolliResponse(makgeolli, .failure(error)))
          }
        }
        
      case let .fetchMakgeolliResponse(entity, .success(makgeolli)):
        guard let makgeolli = makgeolli else {
          return .send(.logError(MyMakgeolliCoreError(
            code: .makgeolliNotFound,
            underlying: nil
          )))
        }
        let imageURL = state.makgeolliImages[entity.id]
        return .send(.moveToInformation(makgeolli, imageURL))
        
      case let .fetchMakgeolliResponse(_, .failure(error)):
        return .send(.logError(MyMakgeolliCoreError(
          code: .failToFetchMakgeolliDetail,
          underlying: error
        )))
        
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
  
  private func getErrorMessage(for code: MyMakgeolliCoreError.Code) -> String {
    switch code {
    case .failToFetchMyMakgeollis:
      return "찜한 막걸리 목록을 불러오지 못했습니다."
    case .failToFetchReactionData:
      return "반응 데이터를 불러오지 못했습니다."
    case .failToFetchImage:
      return "이미지 로딩에 실패했습니다."
    case .failToFetchMakgeolliDetail:
      return "막걸리 정보를 불러오지 못했습니다."
    case .makgeolliNotFound:
      return "해당 막걸리를 찾을 수 없습니다."
    }
  }
}

public struct MyMakgeolliCoreError: JulookError, @unchecked Sendable {
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
    case failToFetchMyMakgeollis
    case failToFetchReactionData
    case failToFetchImage
    case failToFetchMakgeolliDetail
    case makgeolliNotFound
  }
}
