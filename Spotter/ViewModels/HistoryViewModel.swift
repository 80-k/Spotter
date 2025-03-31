//
//  HistoryViewModel.swift
//  Spotter
//
//  Created by woo on 3/29/25.
//

import Foundation
import SwiftData
import SwiftUI

import Combine

class HistoryViewModel: ObservableObject {
    // 데이터 모델 컨텍스트
    private var modelContext: ModelContext
    
    // 운동 세션 기록
    @Published var sessions: [WorkoutSession] = []
    
    // 선택된 날짜
    @Published var selectedDate: Date = Date()
    
    // 날짜별 운동 세션 맵
    @Published var sessionsByDate: [Date: [WorkoutSession]] = [:]
    
    // 통계 정보
    @Published var totalWorkouts: Int = 0
    @Published var streakDays: Int = 0
    @Published var totalDuration: TimeInterval = 0
    @Published var averageWorkoutTime: TimeInterval = 0
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        fetchSessions()
    }
    
    // 모든 세션 가져오기 - 개선된 버전
    func fetchSessions() {
        do {
            print("세션 가져오기 시작")
            let descriptor = FetchDescriptor<WorkoutSession>(
                predicate: #Predicate { session in
                    session.endTime != nil
                },
                sortBy: [SortDescriptor(\.startTime, order: .reverse)]
            )
            sessions = try modelContext.fetch(descriptor)
            print("가져온 세션 수: \(sessions.count)")
            
            // 세션 정보 로깅
            for (index, session) in sessions.enumerated() {
                print("세션 \(index): 시작=\(session.startTime), 종료=\(session.endTime ?? Date())")
            }
            
            // 날짜별 세션 정리
            updateSessionsByDate()
            
            // 통계 계산
            calculateStatistics()
        } catch {
            print("세션 목록을 가져오는 중 오류 발생: \(error)")
        }
    }
    
    // 날짜별 세션 목록 업데이트
    private func updateSessionsByDate() {
        sessionsByDate = [:]
        
        let calendar = Calendar.current
        
        for session in sessions {
            if let endTime = session.endTime {
                // 날짜만 추출 (시간 제외)
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: endTime)
                if let date = calendar.date(from: dateComponents) {
                    if sessionsByDate[date] == nil {
                        sessionsByDate[date] = []
                    }
                    sessionsByDate[date]?.append(session)
                }
            }
        }
        
        // 날짜별 세션 로깅
        for (date, dateSessions) in sessionsByDate {
            print("날짜 \(date): 세션 \(dateSessions.count)개")
        }
    }
    
    // 통계 계산
    private func calculateStatistics() {
        // 총 운동 수
        totalWorkouts = sessions.count
        
        // 총 운동 시간
        totalDuration = sessions.reduce(0) { sum, session in
            sum + (session.totalDuration ?? 0)
        }
        
        // 평균 운동 시간
        if totalWorkouts > 0 {
            averageWorkoutTime = totalDuration / Double(totalWorkouts)
        } else {
            averageWorkoutTime = 0
        }
        
        // 연속 운동 일수 계산
        calculateStreakDays()
    }
    
    // 연속 운동 일수 계산
    private func calculateStreakDays() {
        guard !sessionsByDate.isEmpty else {
            streakDays = 0
            return
        }
        
        let calendar = Calendar.current
        
        // 오늘 날짜 가져오기
        let today = calendar.startOfDay(for: Date())
        
        // 현재 스트릭을 계산하기 위한 날짜 배열
        var streakDates: [Date] = []
        
        // 1. 날짜별로 정렬
        let sortedDates = sessionsByDate.keys.sorted(by: >)
        
        // 가장 최근 운동 날짜
        guard let lastWorkoutDate = sortedDates.first else {
            streakDays = 0
            return
        }
        
        // 오늘 또는 어제 이후에 운동을 하지 않았다면 스트릭이 없음
        let yesterday = calendar.date(byAdding: .day, value: -1, to: today)!
        
        if calendar.compare(lastWorkoutDate, to: yesterday, toGranularity: .day) == .orderedAscending {
            streakDays = 0
            return
        }
        
        // 2. 연속 일수 계산
        var currentDate = lastWorkoutDate
        
        while sessionsByDate[currentDate] != nil {
            streakDates.append(currentDate)
            
            // 전날로 이동
            guard let previousDate = calendar.date(byAdding: .day, value: -1, to: currentDate) else {
                break
            }
            
            currentDate = previousDate
        }
        
        streakDays = streakDates.count
    }
    
    // 특정 날짜의 세션 목록
    func sessionsForDate(_ date: Date) -> [WorkoutSession] {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        
        if let normalizedDate = calendar.date(from: dateComponents) {
            return sessionsByDate[normalizedDate] ?? []
        }
        
        return []
    }
    
    // 특정 날짜에 세션이 있는지 확인
    func hasSessionsForDate(_ date: Date) -> Bool {
        return !sessionsForDate(date).isEmpty
    }
    
    // 세션 삭제 - 완전히 새로운 방식으로 구현 (EXC_BAD_ACCESS 오류 해결)
    func deleteSession(_ session: WorkoutSession) {
        // 세션 ID 저장 (안전한 참조를 위해)
        let sessionId = session.id
        
        // 삭제 작업을 처리할 별도의 블록에서 실행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 세션 상태 저장
            let sessionToDelete = self.sessions.first { $0.id == sessionId }
            guard let sessionToDelete = sessionToDelete else {
                print("삭제할 세션을 찾을 수 없습니다.")
                return
            }
            
            // 새로운 방식: 세션 삭제 전에 참조 제거
            sessionToDelete.template = nil
            sessionToDelete.sets = []
            
            // 메모리에서 삭제된 세션 제거 (새로운 배열 생성)
            self.sessions = self.sessions.filter { $0.id != sessionId }
            
            // 세션 삭제
            self.modelContext.delete(sessionToDelete)
            
            do {
                try self.modelContext.save()
                print("세션이 성공적으로 삭제되었습니다.")
                
                // 세션 목록 새로고침 (안전하게 다시 가져오기)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.fetchSessions()
                }
            } catch {
                print("세션 삭제 중 오류 발생: \(error)")
            }
        }
    }
    
    // 완료된 운동을 다시 활성화하여 새 세션 생성 - 개선된 버전
    func reactivateSession(_ completedSession: WorkoutSession) -> WorkoutSession? {
        // 완료되지 않은 세션이면 무시
        guard completedSession.endTime != nil else {
            print("완료되지 않은 세션은 다시 활성화할 수 없습니다.")
            return nil
        }
        
        // 안전하게 세션 데이터 복사
        guard let sessionSets = completedSession.sets?.compactMap({ $0 }) else {
            print("세션에 세트가 없습니다.")
            return nil
        }
        
        // 템플릿 처리
        var template: WorkoutTemplate
        if let existingTemplate = completedSession.template {
            // 기존 템플릿의 새 인스턴스 생성 (안전한 참조를 위해)
            template = WorkoutTemplate(name: existingTemplate.name)
            template.exercises = existingTemplate.exercises
            modelContext.insert(template)
        } else {
            template = createTemplateFromSession(completedSession)
        }
        
        // 새 세션 생성
        let newSession = WorkoutSession(template: template)
        modelContext.insert(newSession)
        
        // 운동별 세트 그룹화
        var exerciseSets: [PersistentIdentifier: [WorkoutSet]] = [:]
        for set in sessionSets {
            guard let exercise = set.exercise else { continue }
            if exerciseSets[exercise.id] == nil {
                exerciseSets[exercise.id] = []
            }
            exerciseSets[exercise.id]?.append(set)
        }
        
        // 새 세션에 세트 추가
        if let exercises = template.exercises {
            for exercise in exercises {
                let completedSets = exerciseSets[exercise.id] ?? []
                let setCount = max(completedSets.count + 1, 3) // 최소 3개, 완료된 세트 수 + 1
                
                // 세트 추가
                for i in 0..<setCount {
                    let newSet = newSession.addSet(for: exercise)
                    
                    // 이전 세트 정보가 있으면 복사 (무게, 반복 횟수 등)
                    if i < completedSets.count {
                        let oldSet = completedSets[i]
                        newSet.weight = oldSet.weight
                        newSet.reps = oldSet.reps
                        newSet.restTime = oldSet.restTime
                    }
                }
            }
        }
        
        do {
            try modelContext.save()
            print("완료된 운동을 다시 활성화하였습니다.")
            return newSession
        } catch {
            print("세션 다시 활성화 중 오류 발생: \(error)")
            return nil
        }
    }
    
    // 완료된 세션에서 템플릿 생성
    private func createTemplateFromSession(_ session: WorkoutSession) -> WorkoutTemplate {
        let templateName = session.template?.name ?? "재개한 운동"
        let template = WorkoutTemplate(name: templateName)
        
        // 세션에서 운동 추출
        if let sets = session.sets {
            var exerciseDict: [PersistentIdentifier: ExerciseItem] = [:]
            
            for set in sets {
                if let exercise = set.exercise, exerciseDict[exercise.id] == nil {
                    exerciseDict[exercise.id] = exercise
                }
            }
            
            // 템플릿에 운동 추가
            template.exercises = Array(exerciseDict.values)
        }
        
        modelContext.insert(template)
        return template
    }
}
