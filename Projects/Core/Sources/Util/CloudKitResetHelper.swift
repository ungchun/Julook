//
//  CloudKitResetHelper.swift
//  Core
//
//  Created by Kim SungHun on 7/15/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import Foundation
import CloudKit
import SwiftData

#if DEBUG
/// 개발 중에만 사용하는 CloudKit 데이터 초기화 헬퍼
public struct CloudKitResetHelper {
  
  /// 로컬 SwiftData 및 CloudKit 데이터 완전 초기화
  public static func resetAllData() async throws {
    print("🔄 CloudKit 데이터 초기화 시작...")
    
    // 1. 로컬 SwiftData 초기화
    try await resetLocalData()
    
    // 2. CloudKit 컨테이너 초기화
    try await resetCloudKitData()
    
    print("✅ CloudKit 데이터 초기화 완료")
  }
  
  /// 로컬 SwiftData 초기화
  private static func resetLocalData() async throws {
    print("🗑️ 로컬 SwiftData 초기화 중...")
    
    let container = try await SharedModelContainer.shared.container
    
    await MainActor.run {
      let context = container.mainContext
      
      // 모든 MyMakgeolli 데이터 삭제
      do {
        let makgeolliDescriptor = FetchDescriptor<MyMakgeolliLocal>()
        let makgeollis = try context.fetch(makgeolliDescriptor)
        for makgeolli in makgeollis {
          context.delete(makgeolli)
        }
        
        // 모든 MakgeolliReaction 데이터 삭제
        let reactionDescriptor = FetchDescriptor<MakgeolliReactionLocal>()
        let reactions = try context.fetch(reactionDescriptor)
        for reaction in reactions {
          context.delete(reaction)
        }
        
        try context.save()
        print("✅ 로컬 SwiftData 초기화 완료")
      } catch {
        print("❌ 로컬 SwiftData 초기화 실패: \(error)")
      }
    }
  }
  
  /// CloudKit 컨테이너 초기화
  private static func resetCloudKitData() async throws {
    print("☁️ CloudKit 데이터 초기화 중...")
    
    let container = CKContainer.default()
    let database = container.privateCloudDatabase
    
    // CloudKit 레코드 타입들 삭제
    let recordTypes = ["CD_MyMakgeolli", "CD_MakgeolliReaction"]
    
    for recordType in recordTypes {
      do {
        let query = CKQuery(recordType: recordType, predicate: NSPredicate(value: true))
        let records = try await database.records(matching: query)
        
        let recordIDs = records.matchResults.compactMap { (recordID, result) in
          switch result {
          case .success(let record):
            return record.recordID
          case .failure:
            return nil
          }
        }
        
        if !recordIDs.isEmpty {
          let (_, deleteResults) = try await database.modifyRecords(
            saving: [], deleting: recordIDs
          )
          let deletedCount = deleteResults.filter { result in
            switch result.value {
            case .success:
              return true
            case .failure:
              return false
            }
          }.count
          print("✅ CloudKit \(recordType) 레코드 \(deletedCount)개 삭제 완료")
        }
      } catch {
        print("⚠️ CloudKit \(recordType) 삭제 중 오류 (계속 진행): \(error)")
      }
    }
    
    print("✅ CloudKit 데이터 초기화 완료")
  }
}
#endif
