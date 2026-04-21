import XCTest

import ConcurrencyExtras

@testable import Core

final class SupabaseClientTranslationTests: XCTestCase {

  // MARK: - ko locale: skip fetch

  func test_fetchTranslationsIfNeeded_koLocale_skipsFetchAndReturnsEmpty() async throws {
    let invocationCount = LockIsolated(0)
    var client = SupabaseClient()
    client.fetchMakgeolliTranslations = { _ in
      invocationCount.withValue { $0 += 1 }
      return []
    }

    let result = try await client.fetchTranslationsIfNeeded(for: .ko)

    XCTAssertEqual(invocationCount.value, 0, "ko locale은 fetch를 호출하지 않아야 함")
    XCTAssertTrue(result.isEmpty)
  }

  // MARK: - en locale: invoke fetch

  func test_fetchTranslationsIfNeeded_enLocale_invokesFetchWithEn() async throws {
    let receivedLocale = LockIsolated<SupportedLocale?>(nil)
    let id = UUID()
    let sample = MakgeolliTranslation(
      makgeolliId: id,
      locale: "en",
      name: "Haechang",
      brewery: nil,
      awards: nil,
      ingredients: nil,
      description: nil
    )
    var client = SupabaseClient()
    client.fetchMakgeolliTranslations = { locale in
      receivedLocale.setValue(locale)
      return [sample]
    }

    let result = try await client.fetchTranslationsIfNeeded(for: .en)

    XCTAssertEqual(receivedLocale.value, .en, "en locale이 fetcher에 전달되어야 함")
    XCTAssertEqual(result, [sample])
  }

  // MARK: - error propagation

  func test_fetchTranslationsIfNeeded_propagatesFetchError() async {
    struct DummyError: Error, Equatable {}
    var client = SupabaseClient()
    client.fetchMakgeolliTranslations = { _ in
      throw DummyError()
    }

    do {
      _ = try await client.fetchTranslationsIfNeeded(for: .en)
      XCTFail("Error가 전파되어야 하는데 성공함")
    } catch let error as DummyError {
      XCTAssertEqual(error, DummyError())
    } catch {
      XCTFail("예상 DummyError와 다름: \(error)")
    }
  }
}
