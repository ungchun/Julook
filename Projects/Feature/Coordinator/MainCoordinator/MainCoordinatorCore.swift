//
//  MainCoordinatorCore.swift
//  Feature
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import FeatureTabs
import FeatureHome
import FeatureSetting

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
public enum MainScreen {
  case tabs(TabCore)
  case filter(FilterCore)
  case information(InformationCore)
  case commentList(CommentListCore)
  case profileImagePicker(ProfileImagePickerCore)
  case nicknameChange(NicknameChangeCore)
}

@Reducer
public struct MainCoordinatorCore {
  public init() { }
  
  @ObservableState
  public struct State: Equatable {
    var routes: [Route<MainScreen.State>]
    
    public init(routes: [Route<MainScreen.State>]) {
      self.routes = routes
    }
  }
  
  public enum Action {
    case router(IndexedRouterActionOf<MainScreen>)
  }
  
  public var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .router(.routeAction(id: _, action: .tabs(.homeTab(.moveToFilter)))):
        state.routes.push(.filter(.init()))
        
      case let .router(.routeAction(
        id: _, action: .tabs(.homeTab(.moveToFilterWithSelection(filterName))))):
        state.routes.push(.filter(.init(initSelectedFilters: filterName)))
        return .none
        
      case let .router(.routeAction(
        id: _, action: .tabs(.homeTab(.moveToFilterWithTopic(title))))):
        state.routes.push(.filter(.init(topicTitle: title)))
        return .none
        
      case let .router(.routeAction(
        id: _, action: .tabs(.homeTab(.moveToInformation(makgeolli, imageURL))))):
        state.routes.presentCover(.information(
          .init(makgeolli: makgeolli, makgeolliImage: imageURL)))
        return .none
        
      case .router(.routeAction(id: _, action: .tabs(.homeTab(.moveToCommentList)))):
        state.routes.push(.commentList(.init()))
        return .none
        
      case let .router(.routeAction(
        id: _, action: .filter(.moveToInformation(makgeolli, imageURL)))):
        state.routes.presentCover(.information(
          .init(makgeolli: makgeolli, makgeolliImage: imageURL)))
        return .none
        
      case let .router(.routeAction(
        id: _, action: .tabs(.searchTab(.moveToInformation(makgeolli, imageURL))))):
        state.routes.presentCover(.information(
          .init(makgeolli: makgeolli, makgeolliImage: imageURL)))
        return .none
        
      case let .router(.routeAction(
        id: _, action: .tabs(.myMakgeolliTab(.moveToInformation(makgeolli, imageURL))))):
        state.routes.presentCover(.information(
          .init(makgeolli: makgeolli, makgeolliImage: imageURL)))
        return .none
        
      case .router(.routeAction(id: _, action: .information(.dismiss))):
        state.routes.dismiss()
        return .none
        
      case .router(.routeAction(id: _, action: .information(.favoriteStatusChanged))):
        return .send(.router(.routeAction(
          id: 0, action: .tabs(.myMakgeolliTab(.refreshMyMakgeollis)))))
        
      case .router(.routeAction(id: _, action: .information(.reactionStatusChanged))):
        return .send(.router(.routeAction(
          id: 0, action: .tabs(.myMakgeolliTab(.refreshMyMakgeollis)))))
        
      case let .router(.routeAction(
        id: _, action: .commentList(.moveToInformation(makgeolli, imageURL)))):
        state.routes.presentCover(.information(
          .init(makgeolli: makgeolli, makgeolliImage: imageURL)))
        return .none
        
      case .router(.routeAction(id: _, action: .commentList(.dismiss))):
        state.routes.goBack()
        return .none
        
      case let .router(.routeAction(
        id: _, action: .tabs(.settingTab(.moveToProfileImagePicker(currentProfileImage))))):
        state.routes.presentCover(.profileImagePicker(
          .init(currentProfileImage: currentProfileImage)))
        return .none
        
      case .router(.routeAction(id: _, action: .profileImagePicker(.dismiss))):
        state.routes.dismiss()
        return .none
        
      case .router(.routeAction(id: _, action: .profileImagePicker(.profileImageUpdated))):
        state.routes.dismiss()
        return .merge(
          .send(.router(.routeAction(
            id: 0, action: .tabs(.settingTab(.loadUser))))),
          .send(.router(.routeAction(
            id: 0, action: .tabs(.homeTab(.loadUserProfile)))))
        )

      case let .router(.routeAction(
        id: _, action: .tabs(.settingTab(.moveToNicknameChange(currentNickname))))):
        state.routes.presentCover(.nicknameChange(
          .init(currentNickname: currentNickname)))
        return .none

      case .router(.routeAction(id: _, action: .nicknameChange(.dismiss))):
        state.routes.dismiss()
        return .none

      case .router(.routeAction(id: _, action: .nicknameChange(.nicknameUpdated))):
        state.routes.dismiss()
        return .send(.router(.routeAction(
          id: 0, action: .tabs(.settingTab(.loadUser)))))
        
      default:
        break
      }
      
      return .none
    }
    .forEachRoute(\.routes, action: \.router)
  }
}
