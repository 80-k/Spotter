// SwiftDataManager.swift
// SwiftData 모델 컨테이너 관리
//  Created by woo on 3/31/25.

import Foundation
import SwiftData

/// SwiftData 모델 관리 클래스
final class SwiftDataManager {
    // 싱글톤 인스턴스
    static let shared = SwiftDataManager()
    
    /// 공유 모델 컨테이너
    let sharedModelContainer: ModelContainer
    
    // 초기화
    private init() {
        // 데이터 모델 컨테이너 정의
        let schema = Schema([
            ExerciseItem.self,
            WorkoutTemplate.self,
            WorkoutSession.self,
            WorkoutSet.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("모델 컨테이너 생성 실패: \(error)")
        }
    }
} 