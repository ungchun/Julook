//
//  MainScreen.swift
//  Feature
//
//  Created by Kim SungHun on 3/4/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import FeatureHome

import ComposableArchitecture
import TCACoordinators

@Reducer(state: .equatable)
public enum MainScreen {
  case home(HomeCore)
}
