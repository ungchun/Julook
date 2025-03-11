//
//  InformationCore.swift
//  FeatureHome
//
//  Created by Kim SungHun on 3/11/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation

import Core

import ComposableArchitecture

@Reducer
public struct InformationCore {
  public init() { }
  
  @ObservableState
  public struct State: Equatable {
    public var makgeolli: Makgeolli
    public var makgeolliImage: URL?
    
    public init(makgeolli: Makgeolli, makgeolliImage: URL? = nil) {
      self.makgeolli = makgeolli
      self.makgeolliImage = makgeolliImage
    }
  }
  
  public enum Action {
    case onAppear
    
    case dismiss
  }
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
        
      case.dismiss:
        return .none
      }
    }
  }
}
