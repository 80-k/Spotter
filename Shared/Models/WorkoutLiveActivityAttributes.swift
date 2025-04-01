// WorkoutLiveActivityAttributes.swift
// 운동 라이브 액티비티 속성 정의
//  Created by woo on 3/30/25.

import Foundation
import ActivityKit

/// 운동 라이브 액티비티에 사용되는 속성
struct WorkoutLiveActivityAttributes: ActivityAttributes {
    /// 라이브 액티비티를 식별하기 위한 운동명
    public let workoutName: String
    
    /// 라이브 액티비티 콘텐츠 상태
    public struct ContentState: Codable, Hashable {
        /// 운동 시작 시간
        var startTime: Date
        
        /// 운동에 포함된 운동 항목 수
        var exerciseCount: Int
        
        /// 완료된 세트 수
        var completedSets: Int
        
        /// 전체 세트 수
        var totalSets: Int
        
        /// 휴식 모드 여부
        var isRestMode: Bool = false
        
        /// 휴식 중인 운동의 이름
        var restExerciseName: String = ""
        
        /// 남은 휴식 시간 (초)
        var remainingRestTime: Int = 0
        
        /// 경과 시간 (초)
        var elapsedSeconds: Int {
            return Int(Date().timeIntervalSince(startTime))
        }
        
        /// 진행률 (0.0 ~ 1.0)
        var progressPercentage: Float {
            guard totalSets > 0 else { return 0.0 }
            return Float(completedSets) / Float(totalSets)
        }
    }
} 