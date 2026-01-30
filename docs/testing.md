# 테스트

## 테스트 디렉터리
- `Projects/App/Tests/`: 앱 레벨 테스트

## TCA 테스트

```swift
@Test
func testFetchData() async {
  let store = TestStore(initialState: HomeCore.State()) {
    HomeCore()
  }

  await store.send(.fetchData) {
    $0.isLoading = true
  }

  await store.receive(.fetchResponse(.success(mockData))) {
    $0.isLoading = false
    $0.items = mockData
  }
}
```
