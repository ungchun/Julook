//
//  LabelScanCore.swift
//  FeatureLabelScan
//
//  Created by Claude Code on 12/27/24.
//  Copyright © 2024 com.azhy.julook. All rights reserved.
//

import Foundation
import UIKit

import Core

import ComposableArchitecture

@Reducer
public struct LabelScanCore {
  @ObservableState
  public struct State: Equatable {
    // 카메라 상태
    public var isCameraReady: Bool = false
    public var capturedImage: UIImage?
    
    // 분석 상태
    public var isAnalyzing: Bool = false
    public var analysisResult: Makgeolli?
    
    // 선택 화면 (여러 후보가 있을 때)
    public var candidates: [Makgeolli] = []
    public var candidateImages: [UUID: URL] = [:]
    public var isShowingCandidates: Bool = false
    
    // 에러
    public var errorMessage: String?
    public var isShowingError: Bool = false
    
    public init() {}
  }
  
  public enum Action {
    // 라이프사이클
    case onAppear
    case onDisappear
    
    // 카메라
    case cameraReady
    case capturePhoto
    case photoCaptured(UIImage)
    case retakePhoto
    case resetCamera
    
    // 분석
    case analyzeImage(UIImage)
    case analysisCompleted(TaskResult<Makgeolli>)
    
    // 선택 화면
    case showCandidates([Makgeolli])
    case candidateImagesLoaded([UUID: URL])
    case selectCandidate(Makgeolli)
    case dismissCandidates
    
    // 에러
    case showError(String)
    case dismissError
    
    // 네비게이션
    case moveToInformation(Makgeolli, URL?)
  }
  
  public init() {}
  
  @Dependency(\.supabaseClient) var supabaseClient
  
  public var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .onAppear:
        return .none
        
      case .onDisappear:
        state.capturedImage = nil
        state.analysisResult = nil
        return .none
        
      case .cameraReady:
        state.isCameraReady = true
        return .none
        
      case .capturePhoto:
        return .none
        
      case let .photoCaptured(image):
        state.capturedImage = image
        return .send(.analyzeImage(image))
        
      case .retakePhoto:
        state.capturedImage = nil
        state.analysisResult = nil
        state.isAnalyzing = false
        return .none
        
      case .resetCamera:
        state.capturedImage = nil
        return .none
        
      case let .analyzeImage(image):
        state.isAnalyzing = true
        
        let supabaseClient = self.supabaseClient
        
        return .run { send in
          do {
            // 1. 이미지를 JPEG 데이터로 변환
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
              await send(.showError("이미지 변환에 실패했습니다."))
              await send(.resetCamera)
              return
            }
            
            // 2. Gemini API로 라벨 분석
            let analysisResult = try await supabaseClient.analyzeLabelImage(imageData)
            
            // 3. 분석 결과 확인
            let primaryName = analysisResult.primaryName
            let fullName = analysisResult.name
            
            guard (primaryName != nil && !primaryName!.isEmpty)
                    || (fullName != nil && !fullName!.isEmpty) else {
              await send(.showError("막걸리 라벨을 인식하지 못했습니다.\n다시 촬영해주세요."))
              await send(.resetCamera)
              return
            }
            
            // 불필요한 단어 제거 함수
            func cleanKeyword(_ text: String) -> String {
              let removeWords = [
                "막걸리", "생막걸리", "탁주", "생탁주", "프리미엄",
                "명품", "전통", "우리", "순", "참", "특선", "명가",
                "본가", "원조", "청정", "손"
              ]
              var result = text
              for word in removeWords {
                result = result.replacingOccurrences(of: word, with: "")
              }
              return result.trimmingCharacters(in: .whitespaces)
            }
            
            // 이름 매칭 여부 확인 함수
            func isNameMatched(searchQuery: String, makgeolliName: String) -> Bool {
              let query = searchQuery.replacingOccurrences(of: " ", with: "").lowercased()
              let name = makgeolliName.replacingOccurrences(of: " ", with: "").lowercased()
              return name.contains(query) || query.contains(name)
            }
            
            var searchResults: [Makgeolli] = []
            
            // 4-1. primaryName으로 먼저 검색 (가장 정확)
            if let primary = primaryName, !primary.isEmpty {
              let results = try await supabaseClient.searchMakgeollis(primary)
              searchResults = results.filter {
                isNameMatched(searchQuery: primary, makgeolliName: $0.name)
              }
            }
            
            // 4-2. primaryName 검색 실패 시, fullName에서 단어 분리 검색
            if searchResults.isEmpty, let full = fullName, !full.isEmpty {
              let cleanedFull = cleanKeyword(full)
              
              // 전체 이름으로 먼저 시도
              if !cleanedFull.isEmpty {
                let results = try await supabaseClient.searchMakgeollis(cleanedFull)
                searchResults = results.filter {
                  isNameMatched(searchQuery: cleanedFull, makgeolliName: $0.name)
                }
              }
              
              // 여전히 없으면 단어 분리 검색
              if searchResults.isEmpty {
                let words = cleanedFull.split(separator: " ").map(String.init).filter {
                  $0.count >= 2
                }
                for word in words {
                  let partialResults = try await supabaseClient.searchMakgeollis(word)
                  let matched = partialResults.filter {
                    isNameMatched(searchQuery: word, makgeolliName: $0.name)
                  }
                  searchResults.append(contentsOf: matched)
                }
                // ID 기반 중복 제거
                var seenIds = Set<UUID>()
                searchResults = searchResults.filter { seenIds.insert($0.id).inserted }
              }
            }
            
            // 4-3. 양조장으로 재검색
            if searchResults.isEmpty, let brewery = analysisResult.brewery, !brewery.isEmpty {
              let results = try await supabaseClient.searchMakgeollis(brewery)
              searchResults = results
            }
            
            // 4-4. 지역으로 재검색
            if searchResults.isEmpty, let region = analysisResult.region, !region.isEmpty {
              let results = try await supabaseClient.searchMakgeollis(region)
              searchResults = results
            }
            
            // 에러 메시지용 이름 결정
            let displayName = primaryName ?? fullName ?? "알 수 없는"
            
            // 유사도 계산 함수
            func calculateSimilarity(searchQuery: String, makgeolliName: String) -> Double {
              let query = searchQuery.replacingOccurrences(of: " ", with: "").lowercased()
              let name = makgeolliName.replacingOccurrences(of: " ", with: "").lowercased()
              
              // 완전 일치
              if query == name { return 1.0 }
              
              // 검색어가 이름에 포함되거나 이름이 검색어에 포함
              if name.contains(query) {
                return Double(query.count) / Double(name.count)
              }
              if query.contains(name) {
                return Double(name.count) / Double(query.count)
              }
              
              return 0.0
            }
            
            // 결과에 따른 분기 처리
            if searchResults.isEmpty {
              await send(.showError(
                "'\(displayName)' 막걸리를 찾지 못했습니다.\n아직 등록되지 않은 막걸리일 수 있습니다."
              ))
              await send(.resetCamera)
            } else {
              // 유사도 계산용 키워드 (primaryName 우선)
              let similarityKeyword = primaryName ?? fullName ?? ""
              
              // 각 결과의 유사도 계산
              let resultsWithSimilarity = searchResults.map { makgeolli in
                (makgeolli: makgeolli, similarity: calculateSimilarity(
                  searchQuery: similarityKeyword, makgeolliName: makgeolli.name)
                )
              }.sorted { $0.similarity > $1.similarity }
              
              // 1개만 있거나 최고 유사도가 90% 이상이면 바로 이동
              let shouldDirectNavigate = searchResults.count == 1 ||
              (resultsWithSimilarity.first?.similarity ?? 0) >= 0.9
              
              if shouldDirectNavigate, let bestMatch = resultsWithSimilarity.first {
                // 이미지 URL 로드
                var imageURL: URL? = nil
                if let imageName = bestMatch.makgeolli.imageName {
                  do {
                    let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
                    imageURL = try await supabaseClient.getPublicURL(
                      Bucket.MAKGEOLLIIMAGE, fileName
                    )
                  } catch { }
                }
                
                await send(.analysisCompleted(.success(bestMatch.makgeolli)))
                await send(.moveToInformation(bestMatch.makgeolli, imageURL))
                await send(.resetCamera)
              } else {
                // 2개 이상이고 90% 미만이면 선택 화면 표시
                await send(.showCandidates(searchResults))
                await send(.resetCamera)
              }
            }
          } catch {
            await send(.showError("분석 중 오류가 발생했습니다.\n다시 시도해주세요."))
            await send(.resetCamera)
          }
        }
        
      case let .analysisCompleted(.success(makgeolli)):
        state.isAnalyzing = false
        state.analysisResult = makgeolli
        // moveToInformation은 이미지 URL 로드 후 별도로 호출됨
        return .none
        
      case let .analysisCompleted(.failure(_)):
        state.isAnalyzing = false
        return .send(.showError("분석에 실패했습니다. 다시 시도해주세요."))
        
      case let .showError(message):
        state.isAnalyzing = false
        state.errorMessage = message
        state.isShowingError = true
        return .none
        
      case .dismissError:
        // 초기 상태로 리셋
        state.isShowingError = false
        state.errorMessage = nil
        state.capturedImage = nil
        state.analysisResult = nil
        state.isAnalyzing = false
        return .none
        
      case let .showCandidates(candidates):
        state.isAnalyzing = false
        state.candidates = candidates
        
        // 후보들의 이미지 URL 로드
        let supabaseClient = self.supabaseClient
        return .run { send in
          var images: [UUID: URL] = [:]
          for makgeolli in candidates {
            if let imageName = makgeolli.imageName {
              do {
                let fileName = imageName.hasSuffix(".png") ? imageName : "\(imageName).png"
                let url = try await supabaseClient.getPublicURL(Bucket.MAKGEOLLIIMAGE, fileName)
                images[makgeolli.id] = url
              } catch { }
            }
          }
          await send(.candidateImagesLoaded(images))
        }
        
      case let .candidateImagesLoaded(images):
        state.candidateImages = images
        state.isShowingCandidates = true
        return .none
        
      case let .selectCandidate(makgeolli):
        let imageURL = state.candidateImages[makgeolli.id]
        state.isShowingCandidates = false
        state.candidates = []
        state.candidateImages = [:]
        state.analysisResult = makgeolli
        
        // Sheet dismiss 애니메이션 후 초기화 및 화면 이동
        return .run { send in
          try await Task.sleep(for: .milliseconds(300))
          await send(.moveToInformation(makgeolli, imageURL))
        }
        
      case .dismissCandidates:
        state.isShowingCandidates = false
        state.candidates = []
        // 다시 촬영할 수 있도록 상태 초기화
        state.capturedImage = nil
        return .none
        
      case .moveToInformation:
        // 코디네이터에서 화면 전환 처리
        // 초기화는 showCandidates 또는 테스트 성공 시 이미 완료됨
        return .none
      }
    }
  }
}
