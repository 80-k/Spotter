// ActiveWorkoutViewModel.swift
// 활성 운동 세션 관리 뷰모델 (기본 클래스)
//  Created by woo on 3/29/25.

import Foundation
import SwiftData
import SwiftUI
import Combine

@Observable
class ActiveWorkoutViewModel {
    // 데이터 모델 컨텍스트 - internal로 변경하여 외부에서 접근 가능하도록 함
    var modelContext: ModelContext
    
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
            guard let sets = currentSession.sets else { return false }
            // 세트가 없으면 완료되지 않은 것으로 간주
            guard !sets.isEmpty else { return false }
            // 모든 세트가 완료되어야 완료된 운동으로 간주
            return sets.filter { $0.exercise == exercise }.allSatisfy { $0.isCompleted }
        }
    }
    
    // 적어도 하나의 세트가 완료되었는지 확인
    var hasAnyCompletedSet: Bool {
        return currentSession.sets?.contains(where: { $0.isCompleted }) ?? false
    }
    
    // 모든 세트가 완료되었는지 확인
    var areAllSetsCompleted: Bool {
        guard let sets = currentSession.sets, !sets.isEmpty else { return false }
        return sets.allSatisfy { $0.isCompleted }
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
        print("ActiveWorkoutViewModel deinit 호출됨")
        
        // 타이머 중지
        timer?.invalidate()
        timer = nil
        
        // 휴식 타이머 중지
        restTimerManager.stopTimer()
        
        // LiveActivity 종료
        liveActivityManager.endActivity()
        
        print("ActiveWorkoutViewModel 리소스 정리 완료")
    }
    
    // 타이머 시작
    private func startTimer() {
        // 높은 우선순위로 타이머 초기화
        let timerInterval: TimeInterval = 0.5 // 0.5초 간격으로 업데이트하여 정확도 향상
        
        // RunLoop에 추가하여 앱이 활성화된 상태에서 더 정확하게 작동하도록 함
        timer = Timer(timeInterval: timerInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            // 현재 시간과 시작 시간의 차이로 정확한 경과 시간 계산
            let now = Date()
            self.elapsedTime = now.timeIntervalSince(self.currentSession.startTime)
            
            // 라이브 액티비티 업데이트 - 1초 간격으로 제한
            // 0.5초마다 타이머가 트리거되므로 2번에 한 번만 업데이트
            if Int(self.elapsedTime * 2) % 2 == 0 {
                self.liveActivityManager.updateElapsedTime()
            }
        }
        
        // RunLoop에 타이머 추가
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }
    
    // MARK: - 세트 및 운동 관리
    
    // 특정 운동에 대한 세트 목록 가져오기
    func getSetsForExercise(_ exercise: ExerciseItem) -> [WorkoutSet] {
        let sets = currentSession.getSetsForExercise(exercise.id)
        // 세트를 order 속성에 따라 정렬 (오름차순)
        return sets.sorted { $0.order < $1.order }
    }
    
    // 세트 추가
    @discardableResult
    func addSet(for exercise: ExerciseItem) -> WorkoutSet {
        print("ViewModel: 세트 추가 시작 - 운동: \(exercise.name)")
        
        let newSet = currentSession.addSet(for: exercise)
        
        print("ViewModel: currentSession sets 개수: \(currentSession.sets?.count ?? 0)")
        
        do {
            try modelContext.save()
            print("ViewModel: modelContext 저장 성공")
        } catch {
            print("ViewModel: 세트 추가 중 오류 발생: \(error)")
            print("ViewModel: 오류 상세 - \(error.localizedDescription)")
        }

        return newSet
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
    
    // 세트 순서 변경
    func reorderSets(for exercise: ExerciseItem, from source: IndexSet, to destination: Int) {
        // 해당 운동의 세트만 가져오기
        var sets = getSetsForExercise(exercise)
        
        // 순서 변경
        sets.move(fromOffsets: source, toOffset: destination)
        
        // order 속성 업데이트
        for (index, set) in sets.enumerated() {
            set.order = index + 1
        }
        
        // 세션의 세트 목록에서 해당 운동의 세트를 모두 제거
        currentSession.sets?.removeAll(where: { $0.exercise?.id == exercise.id })
        
        // 새로운 순서로 세트 추가
        for set in sets {
            currentSession.sets?.append(set)
        }
        
        do {
            try modelContext.save()
        } catch {
            print("세트 순서 변경 중 오류 발생: \(error)")
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
                
                // 이 운동의 모든 세트가 완료되었는지 확인
                checkAndHandleExerciseCompletion(exercise)
            }
        }
        
        do {
            try modelContext.save()
        } catch {
            print("세트 완료 상태 변경 중 오류 발생: \(error)")
        }
    }
    
    // 운동의 모든 세트가 완료되었는지 확인하고 자동으로 휴식 타이머 종료
    private func checkAndHandleExerciseCompletion(_ exercise: ExerciseItem) {
        let sets = getSetsForExercise(exercise)
        
        // 운동의 모든 세트가 완료되었는지 확인
        if !sets.isEmpty && sets.allSatisfy({ $0.isCompleted }) {
            // 휴식 타이머가 종료되면 현재 진행 중 상태 초기화
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                
                if self.currentActiveExercise?.id == exercise.id {
                    self.restTimerManager.stopTimer()
                    self.currentActiveSet = nil
                    self.currentActiveExercise = nil
                    self.restTimerActive = false
                    
                    // 라이브 액티비티 업데이트
                    self.liveActivityManager.updateElapsedTime()
                }
            }
        }
    }
    
    // 완료된 운동을 다시 대기 중으로 이동
    func reactivateExercise(_ exercise: ExerciseItem) {
        // 운동에 연결된 모든 세트를 가져옴
        let sets = getSetsForExercise(exercise)
        
        // 마지막 세트의 무게와 횟수 정보 참조
        var lastWeight: Double = 0.0
        var lastReps: Int = 0
        
        if let lastSet = sets.last, lastSet.weight > 0, lastSet.reps > 0 {
            lastWeight = lastSet.weight
            lastReps = lastSet.reps
        }
        
        // 모든 세트를 미완료 상태로 변경 (무게와 횟수 정보 유지)
        for set in sets {
            set.resumeSet()
        }
        
        // 새로운 세트 추가 (이전 세트의 무게와 횟수 정보 유지)
        let newSet = addSet(for: exercise)
        
        // 이전 세트의 무게와 횟수 정보가 있다면 적용
        if lastWeight > 0 && lastReps > 0 {
            newSet.weight = lastWeight
            newSet.reps = lastReps
        }
        
        do {
            try modelContext.save()
        } catch {
            print("운동 재활성화 중 오류 발생: \(error)")
        }
    }
    
    // 운동 종료 시 호출되는 메서드도 수정
    func completeWorkout() -> Bool {
        // 적어도 하나의 세트가 완료되었는지 확인
        guard hasAnyCompletedSet else {
            print("완료된 세트가 없습니다. 운동을 완료할 수 없습니다.")
            return false
        }
        
        // 완료된 세트만 유지
        if let sets = currentSession.sets {
            // 이미 모든 세트가 완료되었기 때문에 필터링은 필요 없지만 안전성을 위해 유지
            currentSession.sets = sets.filter { $0.isCompleted }
        }
        
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

    // 완료된 운동에 새 세트 추가 (기존 세트는 그대로 두고 새 세트만 추가)
    func addSetToCompletedExercise(_ exercise: ExerciseItem) {
        // 운동에 연결된 모든 세트를 가져옴
        let sets = getSetsForExercise(exercise)
        
        // 마지막 세트의 무게와 횟수 정보 참조
        var lastWeight: Double = 0.0
        var lastReps: Int = 0
        
        if let lastSet = sets.last, lastSet.weight > 0, lastSet.reps > 0 {
            lastWeight = lastSet.weight
            lastReps = lastSet.reps
        }
        
        // 현재 진행 중인 운동이 있는지 확인
        if let currentExercise = currentActiveExercise {
            // 현재 진행 중인 운동이 있으면 세트는 대기중 운동으로 추가
            // 새로운 세트 추가 (이전 세트의 무게와 횟수 정보 유지)
            let newSet = addSet(for: exercise)
            
            // 이전 세트의 무게와 횟수 정보가 있다면 적용
            if lastWeight > 0 && lastReps > 0 {
                newSet.weight = lastWeight
                newSet.reps = lastReps
            }
        } else {
            // 현재 진행 중인 운동이 없으면 해당 운동을 활성화하고 세트 추가
            // 완료된 운동을 다시 활성화
            for set in sets {
                set.isCompleted = true
            }
            
            // 새로운 세트 추가 (이전 세트의 무게와 횟수 정보 유지)
            let newSet = addSet(for: exercise)
            
            // 이전 세트의 무게와 횟수 정보가 있다면 적용
            if lastWeight > 0 && lastReps > 0 {
                newSet.weight = lastWeight
                newSet.reps = lastReps
            }
            
            // 이 운동을 현재 활성 운동으로 설정
            currentActiveExercise = exercise
        }
        
        do {
            try modelContext.save()
            print("완료된 운동에 새 세트 추가됨: \(exercise.name)")
        } catch {
            print("세트 추가 중 오류 발생: \(error)")
        }
    }
}
