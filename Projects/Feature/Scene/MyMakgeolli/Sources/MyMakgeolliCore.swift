//
//  MyMakgeolliCore.swift
//  FeatureMyMakgeolli
//
//  Created by Kim SungHun on 7/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core
import DesignSystem

import ComposableArchitecture

@Reducer
public struct MyMakgeolliCore: Sendable{
  @ObservableState
  public struct State: Equatable {
    public var isInitialized: Bool = false
    public var myMakgeollis: [MyMakgeolliEntity] = []
    public var makgeolliImages: [UUID: URL] = [:]
    
    public init() { }
  }
  
  public enum Action {
    case viewAppeared
    
    case refreshMyMakgeollis
    case updateMyMakgeollis([MyMakgeolliEntity])
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
  @Dependency(\.supabaseClient) var supabaseClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .viewAppeared:
        if state.isInitialized {
          return .none
        }
        state.isInitialized = true
        return .send(.refreshMyMakgeollis)
        
      case .refreshMyMakgeollis:
        return .run { [currentMakgeollis = state.myMakgeollis] send in
          do {
            let myMakgeollis = try await myMakgeolliClient.getMyMakgeollis()
            await send(.updateMyMakgeollis(myMakgeollis))
            
            let currentIds = Set(currentMakgeollis.map { $0.id })
            let newMakgeollis = myMakgeollis.filter { !currentIds.contains($0.id) }
            
            if !newMakgeollis.isEmpty {
              await send(.loadNewMakgeolliImages(newMakgeollis))
            }
          } catch {
            await send(.updateMyMakgeollis([]))
            await send(.logError(MyMakgeolliCoreError(
              code: .failToFetchMyMakgeollis,
              underlying: error
            )))
          }
        }
        
      case let .updateMyMakgeollis(myMakgeollis):
        state.myMakgeollis = myMakgeollis
        return .none
        
      case let .loadMakgeolliImages(myMakgeollis):
        return .run { [makgeolliImages = state.makgeolliImages] send in
          await withTaskGroup(of: Void.self) { group in
            for makgeolli in myMakgeollis {
              group.addTask {
                guard let imageName = makgeolli.imageName,
                      makgeolliImages[makgeolli.id] == nil else { return }
                
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
    case failToFetchImage
    case failToFetchMakgeolliDetail
    case makgeolliNotFound
  }
}
