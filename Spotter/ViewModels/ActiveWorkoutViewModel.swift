// ActiveWorkoutViewModel.swift
// 활성 운동 세션 관리 뷰모델
//  Created by woo on 3/29/25.

import Foundation
import SwiftData
import SwiftUI
import Combine

@Observable
class ActiveWorkoutViewModel {
    // 데이터 모델 컨텍스트
    private var modelContext: ModelContext
    
    // 현재 세션
    var currentSession: WorkoutSession
    
    // 타이머 관련
    private var timer: Timer?
    var elapsedTime: TimeInterval = 0
    
    // 운동 목록
    var exercises: [ExerciseItem] = []
    
    // 완료된 운동 목록 속성 추가
    var completedExercises: [ExerciseItem] {
        // 모든 세트가 완료된 운동만 완료된 운동으로 간주
        return exercises.filter { exercise in
            let sets = getSetsForExercise(exercise)
            return !sets.isEmpty && sets.allSatisfy { $0.isCompleted }
        }
    }
    
    // 삭제할 운동을 임시 저장하는 변수
    var exerciseToDelete: ExerciseItem? = nil
    
    // 현재 진행 중인 운동 관리
    var currentActiveExercise: ExerciseItem? = nil
    var currentActiveSet: WorkoutSet? = nil
    var restTimerActive: Bool = false
    var remainingRestTime: TimeInterval = 0
    private var restTimer: Timer? = nil
    
    init(modelContext: ModelContext, session: WorkoutSession) {
        self.modelContext = modelContext
        self.currentSession = session
        
        // 세션에 포함된 운동 가져오기
        if let templateExercises = session.template?.exercises {
            self.exercises = templateExercises
        }
        
        // 타이머 시작
        startTimer()
    }
    
    deinit {
        timer?.invalidate()
        restTimer?.invalidate()
    }
    
    // 타이머 시작
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime = Date().timeIntervalSince(self.currentSession.startTime)
            
            // 라이브 액티비티 주기적 업데이트
            LiveActivityManager.shared.updateElapsedTime()
        }
    }
    
    // 특정 운동에 대한 세트 목록 가져오기
    func getSetsForExercise(_ exercise: ExerciseItem) -> [WorkoutSet] {
        return currentSession.getSetsForExercise(exercise.id)
    }
    
    // 세트 추가
    func addSet(for exercise: ExerciseItem) {
        let newSet = currentSession.addSet(for: exercise)
        
        do {
            try modelContext.save()
        } catch {
            print("세트 추가 중 오류 발생: \(error)")
        }
    }
    
    // 세트 업데이트
    func updateSet(_ set: WorkoutSet, weight: Double? = nil, reps: Int? = nil) {
        if let weight = weight {
            set.weight = weight
        }
        
        if let reps = reps {
            set.reps = reps
        }
        
        do {
            try modelContext.save()
        } catch {
            print("세트 업데이트 중 오류 발생: \(error)")
        }
    }
    
    // 세트 삭제
    func deleteSet(_ set: WorkoutSet) {
        // 세션에서 세트 제거
        currentSession.sets?.removeAll(where: { $0.id == set.id })
        
        // 데이터베이스에서 세트 삭제
        modelContext.delete(set)
        
        do {
            try modelContext.save()
        } catch {
            print("세트 삭제 중 오류 발생: \(error)")
        }
    }
    
    // 세트 완료 토글 - 현재 진행 중 관리 기능 추가
    func toggleSetCompletion(_ set: WorkoutSet) {
        // 현재 진행 중인 운동이 있는데 다른 운동이면 무시
        if let currentExercise = currentActiveExercise,
           let exerciseOfSet = set.exercise,
           currentExercise.id != exerciseOfSet.id {
            return
        }
        
        if set.isCompleted {
            // 완료 상태에서 재개
            set.resumeSet()
            
            // 현재 진행 중 상태 제거
            if currentActiveSet?.id == set.id {
                stopRestTimer()
                currentActiveSet = nil
                currentActiveExercise = nil
                restTimerActive = false
                
                // 라이브 액티비티 종료
                LiveActivityManager.shared.endActivity()
            }
        } else {
            // 미완료 상태에서 완료
            set.completeSet()
            
            // 현재 진행 중 상태 설정
            if let exercise = set.exercise {
                currentActiveExercise = exercise
                currentActiveSet = set
                startRestTimer(for: set)
                
                // 라이브 액티비티에 휴식 타이머 업데이트
                LiveActivityManager.shared.updateRestTimer(
                    exerciseName: exercise.name,
                    remainingTime: Int(set.restTime)
                )
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("세트 완료 상태 변경 중 오류 발생: \(error)")
        }
    }
    
    // 운동 종료
    func completeWorkout() -> Bool {
        currentSession.completeWorkout()
        timer?.invalidate()
        stopRestTimer()
        
        // 라이브 액티비티 종료
        LiveActivityManager.shared.endActivity()
        
        do {
            // 세션이 템플릿에 연결되어 있는지 확인
            if let template = currentSession.template {
                // 템플릿의 세션 목록에 추가
                if template.sessions == nil {
                    template.sessions = []
                }
                
                // 이미 추가되지 않았다면 추가
                if !template.sessions!.contains(where: { $0.id == currentSession.id }) {
                    template.sessions!.append(currentSession)
                }
            }
            
            try modelContext.save()
            print("운동 세션 완료 및 저장 성공: \(String(describing: currentSession.endTime))")
            
            // 알림 발송 (HistoryViewModel이 새로고침할 수 있도록)
            NotificationCenter.default.post(name: Notification.Name("WorkoutCompleted"), object: nil)
            
            return true
        } catch {
            print("운동 완료 중 오류 발생: \(error)")
            return false
        }
    }
    
    // 운동 추가
    func addExerciseToWorkout(_ exercise: ExerciseItem) {
        // 세션의 운동 목록이 없으면 생성
        if !exercises.contains(where: { $0.id == exercise.id }) {
            exercises.append(exercise)
            
            // 기본 세트 3개 추가
            for _ in 0..<3 {
                let _ = currentSession.addSet(for: exercise)
            }
            
            do {
                try modelContext.save()
            } catch {
                print("운동 추가 중 오류 발생: \(error)")
            }
        }
    }
    
    // 운동의 모든 세트에 대한 휴식 시간 설정
    func setRestTimeForExercise(_ exercise: ExerciseItem, time: TimeInterval) {
        let sets = getSetsForExercise(exercise)
        
        for set in sets {
            set.restTime = time
        }
        
        do {
            try modelContext.save()
        } catch {
            print("세트 휴식 시간 업데이트 중 오류 발생: \(error)")
        }
    }
    
    // 현재 세션에서 운동 삭제
    func deleteExerciseFromWorkout(_ exercise: ExerciseItem) {
        // 현재 활성 운동이면 상태 초기화
        if currentActiveExercise?.id == exercise.id {
            stopRestTimer()
            currentActiveExercise = nil
            currentActiveSet = nil
            restTimerActive = false
        }
        
        // 세션에서 해당 운동의 모든 세트 삭제
        if let sets = currentSession.sets {
            let setsToDelete = sets.filter { $0.exercise?.id == exercise.id }
            
            for set in setsToDelete {
                modelContext.delete(set)
            }
        }
        
        // 운동 목록에서 삭제
        exercises.removeAll { $0.id == exercise.id }
        
        do {
            try modelContext.save()
        } catch {
            print("운동 삭제 중 오류 발생: \(error)")
        }
    }
    
    func totalRestTimeForExercise(_ exercise: ExerciseItem) -> TimeInterval {
        let sets = getSetsForExercise(exercise)
        return sets.reduce(0) { $0 + $1.restTime }
    }
    
    func totalVolumeForExercise(_ exercise: ExerciseItem) -> Double {
        let sets = getSetsForExercise(exercise)
        
        // 완료된 세트만 계산
        let completedSets = sets.filter { $0.isCompleted }
        
        // 총 볼륨 계산 (무게 × 반복 횟수)
        let totalVolume = completedSets.reduce(0) { total, set in
            total + (set.weight * Double(set.reps))
        }
        
        return totalVolume
    }
    
    // 휴식 타이머 시작
    private func startRestTimer(for set: WorkoutSet) {
        stopRestTimer()
        
        remainingRestTime = set.restTime
        restTimerActive = true
        
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            if self.remainingRestTime > 0 {
                self.remainingRestTime -= 1
                
                // 라이브 액티비티 주기적 업데이트
                if let exercise = set.exercise {
                    LiveActivityManager.shared.updateRestTimer(
                        exerciseName: exercise.name,
                        remainingTime: Int(self.remainingRestTime)
                    )
                }
            } else {
                // 시간이 종료되면 타이머 숨기기
                self.restTimerActive = false
                
                // 알림 진동
                #if os(iOS)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                #endif
                
                // 라이브 액티비티 종료
                LiveActivityManager.shared.endActivity()
                
                self.stopRestTimer()
            }
        }
        
        // 타이머를 메인 스레드에 등록
        RunLoop.current.add(restTimer!, forMode: .common)
    }
    
    // 휴식 타이머 정지
    private func stopRestTimer() {
        restTimer?.invalidate()
        restTimer = nil
    }
    
    // 휴식 종료 확인
    func isCurrentlyActive(_ exercise: ExerciseItem) -> Bool {
        return currentActiveExercise?.id == exercise.id
    }
    
    // 다른 운동이 활성화되어 있는지 확인
    func isAnotherExerciseActive(_ exercise: ExerciseItem) -> Bool {
        return currentActiveExercise != nil && currentActiveExercise?.id != exercise.id
    }
}
