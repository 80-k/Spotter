// PreviewDataFactory.swift
// 미리보기용 샘플 데이터를 생성하는 유틸리티
// Created by woo on 4/15/25.

import Foundation
import SwiftData

/// 미리보기 화면에서 사용할 샘플 데이터를 생성하는 유틸리티 클래스
struct PreviewDataFactory {
    /// 미리보기용 SwiftData 컨테이너 생성
    static func createPreviewContainer() -> ModelContainer {
        do {
            let container = try ModelContainer(for: WorkoutTemplate.self, ExerciseItem.self, WorkoutSession.self)
            return container
        } catch {
            fatalError("미리보기 컨테이너 생성 실패: \(error)")
        }
    }
    
    /// 미리보기용 템플릿 샘플 생성
    static func createTemplates() -> [WorkoutTemplate] {
        let template1 = WorkoutTemplate(name: "상체 운동")
        let template2 = WorkoutTemplate(name: "하체 운동")
        let template3 = WorkoutTemplate(name: "전신 운동")
        
        template1.lastUsed = Date()
        template2.lastUsed = Date().addingTimeInterval(-86400) // 1일 전
        
        // 운동 항목 추가
        let benchPress = ExerciseItem(name: "벤치 프레스", category: "가슴")
        let squat = ExerciseItem(name: "스쿼트", category: "하체")
        let pullUp = ExerciseItem(name: "턱걸이", category: "등")
        let deadlift = ExerciseItem(name: "데드리프트", category: "전신")
        
        template1.addExercise(benchPress, sets: 3)
        template1.addExercise(pullUp, sets: 4)
        
        template2.addExercise(squat, sets: 4)
        template2.addExercise(deadlift, sets: 3)
        
        template3.addExercise(benchPress, sets: 3)
        template3.addExercise(squat, sets: 3)
        template3.addExercise(pullUp, sets: 3)
        
        return [template1, template2, template3]
    }
    
    /// 미리보기용 운동 세션 생성
    static func createWorkoutSessions(for template: WorkoutTemplate? = nil) -> [WorkoutSession] {
        let templates = template != nil ? [template!] : createTemplates()
        var sessions: [WorkoutSession] = []
        
        for template in templates {
            let session = WorkoutSession(template: template)
            session.startDate = Date().addingTimeInterval(-3600) // 1시간 전
            session.endDate = Date()
            sessions.append(session)
        }
        
        return sessions
    }
    
    /// 미리보기용 모델 컨텍스트에 샘플 데이터 추가
    static func populatePreviewContext(_ context: ModelContext) {
        let templates = createTemplates()
        
        for template in templates {
            context.insert(template)
        }
        
        for session in createWorkoutSessions(for: templates.first) {
            context.insert(session)
        }
        
        try? context.save()
    }
} 