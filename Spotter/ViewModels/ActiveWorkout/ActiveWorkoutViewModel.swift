// ActiveWorkoutViewModel.swift
// 활성 운동 세션 관리 뷰모델 (기본 클래스)
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
    
    // LiveActivity와의 통합을 위한 참조
    private let liveActivityManager = LiveActivityManager.shared
    
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
        restTimerManager.stopTimer()
    }
    
    // 타이머 시작
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            self.elapsedTime = Date().timeIntervalSince(self.currentSession.startTime)
            
            // 라이브 액티비티 주기적 업데이트
            self.liveActivityManager.updateElapsedTime()
        }
    }
    
    // MARK: - 세트 및 운동 관리
    
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
                restTimerManager.stopTimer()
                currentActiveSet = nil
                currentActiveExercise = nil
                restTimerActive = false
                
                // 라이브 액티비티 종료
                liveActivityManager.updateElapsedTime()
            }
        } else {
            // 미완료 상태에서 완료
            set.completeSet()
            
            // 현재 진행 중 상태 설정
            if let exercise = set.exercise {
                currentActiveExercise = exercise
                currentActiveSet = set
                restTimerManager.startTimer(for: set, viewModel: self)
                
                // 라이브 액티비티에 휴식 타이머 업데이트
                liveActivityManager.updateRestTimer(
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
    
    // 운동 종료 시 호출되는 메서드도 수정
    func completeWorkout() -> Bool {
        currentSession.completeWorkout()
        timer?.invalidate()
        restTimerManager.stopTimer()
        
        // 라이브 액티비티 종료 - 더 명확히 호출
        liveActivityManager.endActivity()
        print("운동 완료: LiveActivity 종료")
        
        do {
            try modelContext.save()
            
            // 운동 완료 알림 발송
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
    
    
    // 운동 삭제 메서드 개선 (진행 중인 세트 처리 로직 추가)
    func deleteExerciseFromWorkout(_ exercise: ExerciseItem) {
        // 현재 활성 운동이면 상태 초기화
        if currentActiveExercise?.id == exercise.id {
            restTimerManager.stopTimer()
            currentActiveExercise = nil
            currentActiveSet = nil
            restTimerActive = false
            
            // 라이브 액티비티 모드 전환
            liveActivityManager.switchToWorkoutMode()
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
            print("\(exercise.name) 운동이 삭제되었습니다.")
        } catch {
            print("운동 삭제 중 오류 발생: \(error)")
        }
    }
    
    // MARK: - 통계 및 정보 메서드
    
    // 운동의 총 휴식 시간
    func totalRestTimeForExercise(_ exercise: ExerciseItem) -> TimeInterval {
        let sets = getSetsForExercise(exercise)
        return sets.reduce(0) { $0 + $1.restTime }
    }
    
    // 운동의 총 볼륨 (무게 × 횟수)
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
    
    // 현재 휴식 타이머 관리자
    let restTimerManager = RestTimerManager()
    
    // 휴식 종료 확인
    func isCurrentlyActive(_ exercise: ExerciseItem) -> Bool {
        return currentActiveExercise?.id == exercise.id
    }
    
    // 다른 운동이 활성화되어 있는지 확인
    func isAnotherExerciseActive(_ exercise: ExerciseItem) -> Bool {
        return currentActiveExercise != nil && currentActiveExercise?.id != exercise.id
    }
    
    // MARK: - 앱 상태 관리 (스켈레톤 메서드)
    
    // 앱이 백그라운드로 전환될 때 호출될 메서드
    func handleAppBackgrounded() {
        restTimerManager.handleAppBackgrounded()
    }
    
    // 앱이 포그라운드로 돌아올 때 호출될 메서드
    func handleAppForegrounded() {
        restTimerManager.handleAppForegrounded()
    }
    
    

    // 동시에 여러 운동을 추가하는 배치 메서드 (선택적으로 추가)
    func batchAddExercisesToWorkout(_ exercises: [ExerciseItem]) {
        var addedCount = 0
        
        for exercise in exercises {
            // 이미 존재하지 않는 경우에만 추가
            if !self.exercises.contains(where: { $0.id == exercise.id }) {
                // 기존 addExerciseToWorkout 메서드 활용
                self.exercises.append(exercise)
                
                // 기본 세트 3개 추가
                for _ in 0..<3 {
                    let _ = currentSession.addSet(for: exercise)
                }
                
                addedCount += 1
            }
        }
        
        // 변경사항 저장
        if addedCount > 0 {
            do {
                try modelContext.save()
                print("\(addedCount)개의 운동이 추가되었습니다.")
            } catch {
                print("운동 일괄 추가 중 오류 발생: \(error)")
            }
        }
    }

    // 운동 목록 일괄 업데이트 메서드 (선택적으로 추가)
    func updateExerciseList(with newExercises: [ExerciseItem]) {
        // 현재 운동과 새 운동 목록의 ID 세트
        let currentIds = Set(exercises.map { $0.id })
        let newIds = Set(newExercises.map { $0.id })
        
        // 추가할 운동 목록
        let exercisesToAdd = newExercises.filter { !currentIds.contains($0.id) }
        
        // 제거할 운동 목록 (완료된 운동은 제외)
        let completedIds = Set(completedExercises.map { $0.id })
        let exercisesToRemove = exercises.filter {
            !newIds.contains($0.id) && !completedIds.contains($0.id)
        }
        
        // 운동 추가
        for exercise in exercisesToAdd {
            addExerciseToWorkout(exercise)
        }
        
        // 운동 제거
        for exercise in exercisesToRemove {
            deleteExerciseFromWorkout(exercise)
        }
        
        print("운동 목록 업데이트 완료: \(exercisesToAdd.count)개 추가, \(exercisesToRemove.count)개 제거")
    }
}
