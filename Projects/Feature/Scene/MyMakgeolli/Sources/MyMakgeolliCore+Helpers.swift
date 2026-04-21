import Foundation
import Security

import Core

extension MyMakgeolliCore {
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

  func getErrorMessage(for code: MyMakgeolliCoreError.Code) -> String {
    switch code {
    case .failToFetchMyMakgeollis:
      return L10n.MyMakgeolli.Error.fetchFavoritesFailed
    case .failToFetchReactionData:
      return L10n.MyMakgeolli.Error.fetchReactionsFailed
    case .failToFetchImage:
      return L10n.Common.Error.imageLoadFailed
    case .failToFetchMakgeolliDetail:
      return L10n.Common.Error.fetchMakgeolliFailed
    case .makgeolliNotFound:
      return L10n.MyMakgeolli.Error.makgeolliNotFound
    }
  }
}
