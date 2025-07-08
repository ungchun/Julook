//
//  MyMakgeolliCore.swift
//  FeatureMyMakgeolli
//
//  Created by Kim SungHun on 7/6/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core

import ComposableArchitecture

@Reducer
public struct MyMakgeolliCore: Sendable{
  @ObservableState
  public struct State: Equatable {
    public var myMakgeollis: [MyMakgeolliEntity] = []
    public var makgeolliImages: [UUID: URL] = [:]
    
    public init() { }
  }
  
  public enum Action {
    case viewAppeared
    
    case updateMyMakgeollis([MyMakgeolliEntity])
    case loadMakgeolliImages([MyMakgeolliEntity])
    case updateMakgeolliImage(UUID, URL)
    case myMakgeolliItemTapped(MyMakgeolliEntity)
    case fetchMakgeolliResponse(MyMakgeolliEntity, TaskResult<Makgeolli?>)
    
    case moveToInformation(Makgeolli, URL?)
    
    case logError(MyMakgeolliCoreError)
  }
  
  public init() { }
  
  @Dependency(\.myMakgeolliClient) var myMakgeolliClient
  @Dependency(\.supabaseClient) var supabaseClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .viewAppeared:
        return .run { send in
          do {
            let myMakgeollis = try await myMakgeolliClient.getMyMakgeollis()
            await send(.updateMyMakgeollis(myMakgeollis))
            await send(.loadMakgeolliImages(myMakgeollis))
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
        return .run { _ in
          Log.error(error)
        }
      }
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
