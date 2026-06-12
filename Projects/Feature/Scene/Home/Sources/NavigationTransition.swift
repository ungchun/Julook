//
//  NavigationTransition.swift
//  FeatureHome
//
//  Created by Kim SungHun on 6/12/26.
//  Copyright © 2026 com.azhy.julook. All rights reserved.
//

import Foundation

/// push 전환 중 화면 State가 변하면 NavigationStack path 요소(동등성에 State 전체가 포함됨)가
/// 교체되어 전환 애니메이션이 중단된다 (TCACoordinators 0.16 + iOS 26 NavigationStack).
/// 그래서 push로 진입하는 화면의 첫 데이터 로드는 전환이 끝난 뒤에 시작해야 한다.
/// 0.65초는 FlowStacks가 자체 전환 지연에 쓰는 상수와 동일.
enum NavigationTransition {
  static let settleDuration: Duration = .milliseconds(650)
}
