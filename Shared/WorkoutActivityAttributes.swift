// WorkoutActivityAttributes.swift
// 다이나믹 아일랜드 LiveActivity 속성 정의
// Created by woo on 3/30/25.

import Foundation
import ActivityKit

// 운동 활동 속성 정의
public struct WorkoutActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        public var startTime: Date
        public var elapsedTime: TimeInterval
        public var isRestTimer: Bool
        public var restExerciseName: String
        public var restTimeRemaining: Int
        
        public init(startTime: Date, elapsedTime: TimeInterval, isRestTimer: Bool, restExerciseName: String, restTimeRemaining: Int) {
            self.startTime = startTime
            self.elapsedTime = elapsedTime
            self.isRestTimer = isRestTimer
            self.restExerciseName = restExerciseName
            self.restTimeRemaining = restTimeRemaining
        }
    }
    
    public var workoutName: String
    
    public init(workoutName: String) {
        self.workoutName = workoutName
    }
}
