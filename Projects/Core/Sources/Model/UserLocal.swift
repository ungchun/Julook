//
//  UserLocal.swift
//  Core
//
//  Created by Kim SungHun on 9/21/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import SwiftData
import Security

@Model
public class UserLocal {
  public var userId: UUID = UUID()
  public var nickname: String = ""
  public var profileImage: String = ""
  public var createdAt: Date = Date()
  public var updatedAt: Date = Date()

  public init(
    userId: UUID? = nil,
    nickname: String = "",
    profileImage: String = ""
  ) {
    self.userId = userId ?? Self.getOrCreateUserID()
    self.nickname = nickname
    self.profileImage = profileImage.isEmpty ? Self.getRandomProfileImage() : profileImage
    self.createdAt = Date()
    self.updatedAt = Date()
  }

  public func updateNickname(_ nickname: String) {
    self.nickname = nickname
    self.updatedAt = Date()
  }

  public func updateProfileImage(_ profileImage: String) {
    self.profileImage = profileImage
    self.updatedAt = Date()
  }

  public func setRandomProfileImageIfEmpty() {
    if self.profileImage.isEmpty {
      let randomIndex = Int.random(in: 1...8)
      self.profileImage = "p\(randomIndex)"
      self.updatedAt = Date()
    }
  }

  // MARK: - Profile Image

  private static func getRandomProfileImage() -> String {
    let randomIndex = Int.random(in: 1...8)
    return "p\(randomIndex)"
  }

  // MARK: - Keychain Integration

  private static func getOrCreateUserID() -> UUID {
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

  private static func getKeychainValue(service: String, account: String) -> String? {
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

  private static func setKeychainValue(service: String, account: String, value: String) {
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
