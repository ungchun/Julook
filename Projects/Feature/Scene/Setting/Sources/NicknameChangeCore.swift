//
//  NicknameChangeCore.swift
//  FeatureSetting
//
//  Created by Kim SungHun on 9/23/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import Security

import Core

import ComposableArchitecture

@Reducer
public struct NicknameChangeCore {
  @ObservableState
  public struct State: Equatable {
    public var currentNickname: String = ""
    public var newNickname: String = ""
    public var isNicknameAvailable: Bool? = nil
    public var isCheckingDuplicate: Bool = false
    
    public init(currentNickname: String = "") {
      self.currentNickname = currentNickname
      self.newNickname = currentNickname
    }
  }
  
  public enum Action {
    case onAppear
    case dismiss
    case nicknameChanged(String)
    case checkDuplicateButtonTapped
    case duplicateCheckResult(Bool)
    case duplicateCheckFailed
    case saveButtonTapped
    case nicknameUpdated
    case nicknameUpdateFailed
  }
  
  public init() { }
  
  @Dependency(\.userClient) var userClient
  @Dependency(\.supabaseClient) var supabaseClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
        
      case .dismiss:
        return .none
        
      case let .nicknameChanged(nickname):
        state.newNickname = nickname
        state.isNicknameAvailable = nil
        return .none
        
      case .checkDuplicateButtonTapped:
        state.isCheckingDuplicate = true
        let nickname = state.newNickname
        let supabaseClient = self.supabaseClient
        return .run { send in
          do {
            let isAvailable = try await supabaseClient.checkNicknameDuplicate(nickname)
            await send(.duplicateCheckResult(isAvailable))
          } catch {
            await send(.duplicateCheckFailed)
          }
        }
        
      case let .duplicateCheckResult(isAvailable):
        state.isCheckingDuplicate = false
        state.isNicknameAvailable = isAvailable
        return .none
        
      case .duplicateCheckFailed:
        state.isCheckingDuplicate = false
        state.isNicknameAvailable = nil
        return .none
        
      case .saveButtonTapped:
        let newNickname = state.newNickname
        let userClient = self.userClient
        let supabaseClient = self.supabaseClient
        let userId = getUserID()
        return .run { send in
          do {
            try await userClient.updateNickname(newNickname)
            try await supabaseClient.updateUserNickname(userId, newNickname)
            await send(.nicknameUpdated)
          } catch {
            await send(.nicknameUpdateFailed)
          }
        }
        
      case .nicknameUpdated:
        return .none
        
      case .nicknameUpdateFailed:
        return .none
      }
    }
  }
}

private extension NicknameChangeCore {
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
}
