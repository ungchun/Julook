import Foundation
import Security

import Core

extension InformationCore {
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

  func getErrorMessage(for code: InformationCoreError.Code) -> String {
    switch code {
    case .failToCheckFavoriteStatus:
      return L10n.Information.Error.favoriteStatusFailed
    case .failToUpdateFavoriteStatus:
      return L10n.Common.Error.favoriteToggleFailed
    case .failToLoadReaction:
      return L10n.Information.Error.reactionFetchFailed
    case .failToSaveReaction:
      return L10n.Information.Error.reactionSaveFailed
    case .failToLoadReactionCounts:
      return L10n.Information.Error.statsFetchFailed
    case .failToLoadUserComment:
      return L10n.Information.Error.myCommentFetchFailed
    case .failToSaveUserComment:
      return L10n.Information.Error.commentSaveFailed
    case .failToDeleteUserComment:
      return L10n.Information.Error.commentDeleteFailed
    case .failToLoadPublicComments:
      return L10n.Information.Error.otherUsersCommentFetchFailed
    }
  }

  func applyReactionState(_ state: inout State, reactionType: String?) {
    state.currentReaction = reactionType
    if reactionType == "like" {
      state.likeButtonState = .active
      state.dislikeButtonState = .disabled
    } else if reactionType == "dislike" {
      state.likeButtonState = .disabled
      state.dislikeButtonState = .active
    } else {
      state.likeButtonState = .disabled
      state.dislikeButtonState = .disabled
    }
  }
}
