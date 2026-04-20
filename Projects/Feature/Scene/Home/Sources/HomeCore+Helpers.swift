import Foundation
import Security

extension HomeCore {
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

  func getErrorMessage(for code: HomeCoreError.Code) -> String {
    switch code {
    case .failToSupabaseClientInitialized:
      return "서비스 연결에 실패했습니다."
    case .failToFetchNewReleases:
      return "새로운 막걸리 정보를 불러오지 못했습니다."
    case .failToFetchRandomMakgeollis:
      return "추천 막걸리 정보를 불러오지 못했습니다."
    case .failToGetImageUrl:
      return "이미지를 불러오지 못했습니다."
    case .failToFetchImage:
      return "이미지 로딩에 실패했습니다."
    case .failToFetchAwards:
      return "수상 정보를 불러오지 못했습니다."
    case .failToFetchTopLiked:
      return "인기 막걸리 정보를 불러오지 못했습니다."
    case .failToUpdateFavoriteStatus:
      return "찜 상태 변경에 실패했습니다."
    case .failToFetchRecentComments:
      return "최근 코멘트를 불러오지 못했습니다."
    }
  }
}
