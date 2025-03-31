// ExerciseItem.swift
// 운동 항목 모델 - 개별 운동의 정보를 저장
//  Created by woo on 3/29/25.

import Foundation
import SwiftData

@Model
final class ExerciseItem {
    // 운동 기본 정보
    var name: String
    var muscleGroup: String
    var exerciseDescription: String
    
    @Relationship(deleteRule: .cascade)
    var workoutTemplates: [WorkoutTemplate]? = []
    
    init(name: String, muscleGroup: String, exerciseDescription: String = "") {
        self.name = name
        self.muscleGroup = muscleGroup
        self.exerciseDescription = exerciseDescription
    }
}

// 운동 부위 enum
enum MuscleGroup: String, CaseIterable, Codable {
    case chest = "가슴"
    case back = "등"
    case legs = "하체"
    case shoulders = "어깨"
    case arms = "팔"
    case core = "코어"
    case cardio = "유산소"
    case fullBody = "전신"
}
