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
  public var createUser: @Sendable (String, String) async throws -> UserEntity
  public var updateNickname: @Sendable (String) async throws -> Void
  public var updateProfileImage: @Sendable (String) async throws -> Void
  public var initializeUserProfile: @Sendable () async throws -> UserEntity
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
              let result: UserEntity? = users.first?.toEntity()
              continuation.resume(returning: result)
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
      
      createUser: { nickname, profileImage in
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try await SharedModelContainer.shared.container
              let context = container.mainContext
              
              let newUser = UserLocal(
                nickname: nickname,
                profileImage: profileImage
              )
              context.insert(newUser)
              try context.save()
              
              let result = newUser.toEntity()
              continuation.resume(returning: result)
            } catch {
              Log.error(UserClientError(
                code: .failToCreateUser,
                underlying: error
              ))
              continuation.resume(throwing: error)
            }
          }
        }
      },
      
      updateNickname: { nickname in
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try await SharedModelContainer.shared.container
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<UserLocal>()
              let users = try context.fetch(descriptor)
              
              if let user = users.first {
                user.updateNickname(nickname)
                try context.save()
              }
              
              continuation.resume()
            } catch {
              Log.error(UserClientError(
                code: .failToUpdateNickname,
                underlying: error
              ))
              continuation.resume(throwing: error)
            }
          }
        }
      },
      
      updateProfileImage: { profileImage in
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try await SharedModelContainer.shared.container
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<UserLocal>()
              let users = try context.fetch(descriptor)
              
              if let user = users.first {
                user.updateProfileImage(profileImage)
                try context.save()
              }
              
              continuation.resume()
            } catch {
              Log.error(UserClientError(
                code: .failToUpdateProfileImage,
                underlying: error
              ))
              continuation.resume(throwing: error)
            }
          }
        }
      },
      
      initializeUserProfile: {
        return try await withCheckedThrowingContinuation { continuation in
          Task { @MainActor in
            do {
              let container = try await SharedModelContainer.shared.container
              let context = container.mainContext
              
              let descriptor = FetchDescriptor<UserLocal>()
              let existingUsers = try context.fetch(descriptor)
              
              let user: UserLocal
              if existingUsers.isEmpty {
                // 새로운 사용자 생성 (프로필 이미지 자동 설정됨)
                user = UserLocal()
                context.insert(user)
                try context.save()
              } else {
                // 기존 사용자들의 빈 프로필 이미지 설정
                user = existingUsers.first!
                user.setRandomProfileImageIfEmpty()
                try context.save()
              }
              
              let result = user.toEntity()
              continuation.resume(returning: result)
            } catch {
              Log.error(UserClientError(
                code: .failToInitializeUser,
                underlying: error
              ))
              continuation.resume(throwing: error)
            }
          }
        }
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
    case failToCreateUser
    case failToUpdateNickname
    case failToUpdateProfileImage
    case failToInitializeUser
  }
}
