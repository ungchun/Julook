//
//  UserClient.swift
//  Core
//
//  Created by Kim SungHun on 9/21/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import SwiftData

import ComposableArchitecture

@DependencyClient
public struct UserClient: Sendable {
  public var getUser: @Sendable () async throws -> UserEntity?
  public var updateNickname: @Sendable (String) async throws -> Void
  public var updateProfileImage: @Sendable (String) async throws -> Void
}

extension UserClient: DependencyKey {
  public static var liveValue: UserClient {
    return UserClient(
      getUser: {
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try await SharedModelContainer.shared.container
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<UserLocal>()
              let users = try context.fetch(descriptor)
              
              let nickname = NSUbiquitousKeyValueStore.default.string(
                forKey: "user_nickname"
              ) ?? ""
              let profileImage = NSUbiquitousKeyValueStore.default.string(
                forKey: "user_profile_image"
              ) ?? "p1"
              
              if let user = users.first {
                let entity = UserEntity(
                  userId: user.userId,
                  nickname: nickname,
                  profileImage: profileImage,
                  createdAt: user.createdAt,
                  updatedAt: user.updatedAt
                )
                continuation.resume(returning: entity)
              } else {
                continuation.resume(returning: nil)
              }
            } catch {
              Log.error(UserClientError(
                code: .failToGetUser,
                underlying: error
              ))
              continuation.resume(throwing: error)
            }
          }
        }
      },
      
      updateNickname: { nickname in
        NSUbiquitousKeyValueStore.default.set(nickname, forKey: "user_nickname")
        NSUbiquitousKeyValueStore.default.synchronize()
      },
      
      updateProfileImage: { profileImage in
        NSUbiquitousKeyValueStore.default.set(profileImage, forKey: "user_profile_image")
        NSUbiquitousKeyValueStore.default.synchronize()
      }
    )
  }
}

extension DependencyValues {
  public var userClient: UserClient {
    get { self[UserClient.self] }
    set { self[UserClient.self] = newValue }
  }
}

public struct UserClientError: JulookError, @unchecked Sendable {
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
    case failToGetUser
    case failToUpdateNickname
    case failToUpdateProfileImage
  }
}
