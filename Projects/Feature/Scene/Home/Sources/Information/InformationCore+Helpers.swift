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
      return "찜 상태를 확인하지 못했습니다."
    case .failToUpdateFavoriteStatus:
      return "찜 상태 변경에 실패했습니다."
    case .failToLoadReaction:
      return "반응 정보를 불러오지 못했습니다."
    case .failToSaveReaction:
      return "반응 저장에 실패했습니다."
    case .failToLoadReactionCounts:
      return "평가 통계를 불러오지 못했습니다."
    case .failToLoadUserComment:
      return "내 코멘트를 불러오지 못했습니다."
    case .failToSaveUserComment:
      return "코멘트 저장에 실패했습니다."
    case .failToDeleteUserComment:
      return "코멘트 삭제에 실패했습니다."
    case .failToLoadPublicComments:
      return "다른 유저의 코멘트를 불러오지 못했습니다."
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
