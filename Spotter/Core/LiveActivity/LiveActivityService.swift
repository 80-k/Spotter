// LiveActivityService.swift
// 라이브 액티비티 서비스 구현
//  Created by woo on 3/30/25.

import Foundation
import ActivityKit
import Combine
import SwiftUI
import SwiftData

/// 라이브 액티비티 서비스 구현
final class LiveActivityService: LiveActivityServiceProtocol, @unchecked Sendable {
    // 싱글톤 인스턴스
    static let shared = LiveActivityService()
    
    // 현재 활성 Activity
    private var currentActivity: Activity<WorkoutActivityAttributes>?
    
    // 상태 관리를 위한 명확한 열거형 정의
    enum ActivityMode {
        case none                  // 활동 없음
        case workoutMode           // 일반 운동 모드
        case restTimerMode         // 휴식 타이머 모드
        case fadeInWorkoutMode     // 휴식 타이머에서 운동 모드로 페이드인(전환) 중
        case fadeInRestTimerMode   // 운동 모드에서 휴식 타이머 모드로 페이드인(전환) 중
    }
    
    // 현재 활동 모드
    private var currentMode: ActivityMode = .none
    
    // 마지막 업데이트 시간 추적 - 모드별로 분리
    private var lastWorkoutUpdateTime: Date = Date()
    private var lastRestUpdateTime: Date = Date()
    
    // 운동 세부 정보 저장
    private var workoutName: String = ""
    private var workoutStartTime: Date = Date()
    private var restExerciseName: String = ""
    
    // 타이머 전환 관련 데이터 저장
    private var lastSessionCompletedSets: Int = 0
    private var lastSessionTotalSets: Int = 0
    private var lastSessionExerciseCount: Int = 0
    
    // 마지막 휴식 타이머 값 (0이 되었을 때 중복 호출 방지)
    private var lastRestTimeValue: Int = -1
    
    // 모드 전환 애니메이션을 위한 타이머
    private var transitionTimer: Timer?
    
    // 앱 상태 변경 감지를 위한 구독
    private var cancellables = Set<AnyCancellable>()
    
    // 앱 상태 모니터링을 위한 Scene Phase 옵저버
    private var scenePhaseObserver: AnyCancellable?
    
    // 업데이트 간격 상수
    private struct UpdateIntervals {
        static let transition: TimeInterval = 0.1  // 모드 전환 시 업데이트 간격 (빠른 업데이트)
        static let regular: TimeInterval = 1.0     // 일반 업데이트 간격 (1초마다 최대)
        static let animationDuration: TimeInterval = 0.4 // 전환 애니메이션 시간
    }
    
    // 초기화
    private init() {
        setupNotifications()
    }
    
    // 앱 상태 변경 감지를 위한 알림 설정
    private func setupNotifications() {
        // 종료 및 백그라운드 전환을 위한 ScenePhase 감지 설정
        setupScenePhaseObserver()
        
        // 종료 알림도 백업으로 유지
        NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in
                print("앱 종료 감지: LiveActivity 종료 중...")
                self?.endAllActivities()
            }
            .store(in: &cancellables)
    }
    
    // ScenePhase 옵저버 설정
    private func setupScenePhaseObserver() {
        // 앱의 ScenePhase는 EnvironmentObject로 관찰해야 하지만,
        // 싱글톤 서비스에서는 NotificationCenter를 통해 처리합니다.
        NotificationCenter.default.publisher(for: NSNotification.Name("scenePhaseChanged"))
            .compactMap { notification -> ScenePhase? in
                return notification.object as? ScenePhase
            }
            .sink { [weak self] phase in
                switch phase {
                case .background:
                    print("앱 백그라운드 전환 감지: LiveActivity 상태 저장 중...")
                    self?.handleAppBackgroundTransition()
                case .inactive:
                    // 필요한 경우 inactive 상태 처리
                    break
                case .active:
                    // 필요한 경우 active 상태 처리
                    break
                @unknown default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    // 모든 활동 즉시 종료 (앱 종료 시 호출)
    public func endAllActivities() {
        guard let activity = currentActivity else { return }
        
        // 전환 타이머 종료
        invalidateTransitionTimer()
        
        Task {
            await activity.end(nil, dismissalPolicy: .immediate)
            
            // 상태 초기화
            currentActivity = nil
            currentMode = .none
        }
    }
    
    // 전환 타이머 종료
    private func invalidateTransitionTimer() {
        transitionTimer?.invalidate()
        transitionTimer = nil
    }
    
    // MARK: - Public 메서드
    
    /// 운동 활동 시작
    func startWorkoutActivity(for session: WorkoutSession) {
        guard let templateName = session.workoutTemplate?.name else { return }
        
        // 이미 활성화되어 있는 활동이 있으면 종료
        if currentActivity != nil {
            endActivity()
            // 비동기 작업이므로 약간의 딜레이 필요
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.createNewWorkoutActivity(workoutName: templateName, startTime: session.startTime)
            }
            return
        }
        
        createNewWorkoutActivity(workoutName: templateName, startTime: session.startTime)
    }
    
    /// 운동 활동 업데이트
    func updateWorkoutActivity(for session: WorkoutSession) {
        guard let activity = currentActivity else { return }
        
        // 휴식 타이머 모드나 전환 모드일 경우 세션 정보만 저장
        if currentMode == .restTimerMode || currentMode == .fadeInRestTimerMode || currentMode == .fadeInWorkoutMode {
            // 세션 정보 저장 (휴식 모드가 끝나면 이 정보로 업데이트됨)
            lastSessionCompletedSets = session.completedSets
            lastSessionTotalSets = session.totalSets
            lastSessionExerciseCount = session.workoutTemplate?.exerciseItems?.count ?? 0
            return
        }
        
        // 업데이트 제한 적용
        let now = Date()
        if now.timeIntervalSince(lastWorkoutUpdateTime) < UpdateIntervals.regular {
            return
        }
        
        // 운동 상태 업데이트
        let updatedState = WorkoutActivityAttributes.ContentState(
            startTime: session.startTime,
            exerciseCount: session.workoutTemplate?.exerciseItems?.count ?? 0,
            completedSets: session.completedSets,
            totalSets: session.totalSets
        )
        
        let activityCopy = activity
        
        Task {
            await activityCopy.update(ActivityContent(state: updatedState, staleDate: nil))
            
            // 마지막 업데이트 시간 갱신
            DispatchQueue.main.async { [weak self] in
                self?.lastWorkoutUpdateTime = Date()
            }
        }
    }
    
    /// 휴식 타이머 활동 시작
    func startRestTimerActivity(for set: WorkoutSet) {
        // 전환 타이머 종료 (이전 전환이 있었다면)
        invalidateTransitionTimer()
        
        // 전환 모드로 변경
        currentMode = .fadeInRestTimerMode
        
        if let exerciseName = set.exerciseItem?.name {
            restExerciseName = exerciseName
        }
        
        // 부드러운 전환을 위한 상태 업데이트
        applyTransitionToRestMode(for: set)
    }
    
    /// 휴식 타이머 업데이트
    func updateRestTimerActivity(for set: WorkoutSet) {
        guard let activity = currentActivity else {
            print("LiveActivityService: 활성 Activity가 없어 휴식 타이머 업데이트 불가")
            return
        }
        
        // 운동 모드로 전환 중이면 업데이트 무시
        if currentMode == .fadeInWorkoutMode {
            print("LiveActivityService: 운동 모드로 전환 중 - 휴식 타이머 업데이트 무시")
            return
        }
        
        // 남은 시간 계산 - set 객체에서 직접 가져오기
        let remainingTime = Int(set.remainingRestTime)
        
        print("LiveActivityService: 휴식 타이머 업데이트 - 세트 ID: \(set.id), 남은 시간: \(remainingTime)초")
        
        // 동일한 값의 중복 업데이트 방지
        if remainingTime == lastRestTimeValue && 
           (currentMode == .restTimerMode || currentMode == .fadeInRestTimerMode) {
            print("LiveActivityService: 동일한 시간값 중복 업데이트 방지 - \(remainingTime)초")
            return
        }
        
        // 마지막 값 저장
        lastRestTimeValue = remainingTime
        
        // 시간이 0이면 즉시 운동 모드로 전환
        if remainingTime <= 0 {
            if currentMode == .restTimerMode || currentMode == .fadeInRestTimerMode {
                print("LiveActivityService: 휴식 시간 종료 - 운동 모드로 전환")
                switchToWorkoutMode()
            }
            return
        }
        
        // 운동 이름 가져오기 (없으면 현재 저장된 값 사용)
        if let exerciseName = set.exerciseItem?.name, !exerciseName.isEmpty {
            restExerciseName = exerciseName
        }
        
        // 휴식 타이머 상태로 업데이트
        let updatedState = WorkoutActivityAttributes.ContentState(
            startTime: workoutStartTime,
            exerciseCount: 0,  // 휴식 모드에서는 사용하지 않음
            completedSets: 0,  // 휴식 모드에서는 사용하지 않음
            totalSets: 0,      // 휴식 모드에서는 사용하지 않음
            isRestMode: true,
            restExerciseName: restExerciseName,
            remainingRestTime: remainingTime
        )
        
        let activityCopy = activity
        let capturedRemainingTime = remainingTime
        
        Task {
            do {
                await activityCopy.update(ActivityContent(state: updatedState, staleDate: nil))
                
                // 마지막 업데이트 시간 갱신
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.lastRestUpdateTime = Date()
                    if self.currentMode == .fadeInRestTimerMode {
                        self.currentMode = .restTimerMode
                    }
                    print("LiveActivityService: 휴식 타이머 LiveActivity 업데이트 성공: \(capturedRemainingTime)초")
                }
            } catch {
                print("LiveActivityService: 휴식 타이머 업데이트 오류 - \(error.localizedDescription)")
            }
        }
    }
    
    /// 운동 모드로 전환
    func switchToWorkoutMode() {
        // 이미 운동 모드면 무시
        if currentMode == .workoutMode {
            print("LiveActivityService: 이미 운동 모드임 - 전환 무시")
            return
        }
        
        print("LiveActivityService: 운동 모드로 전환 시작 - 이전 모드: \(currentMode)")
        
        // 전환 타이머 종료
        invalidateTransitionTimer()
        
        // 전환 모드로 설정
        currentMode = .fadeInWorkoutMode
        
        // 휴식 타이머 관련 상태 초기화
        lastRestTimeValue = -1
        
        // 부드러운 전환을 위한 상태 변경
        applyTransitionToWorkoutMode()
    }
    
    /// 모든 활동 종료 및 상태 초기화
    func endActivity() {
        guard let activity = currentActivity else { return }
        
        // 전환 타이머 종료
        invalidateTransitionTimer()
        
        let activityCopy = activity
        
        Task {
            await activityCopy.end(nil, dismissalPolicy: .immediate)
            
            DispatchQueue.main.async { [weak self] in
                self?.currentActivity = nil
                self?.currentMode = .none
                self?.workoutName = ""
                self?.workoutStartTime = Date()
                self?.restExerciseName = ""
                self?.lastRestTimeValue = -1
                self?.lastSessionCompletedSets = 0
                self?.lastSessionTotalSets = 0
                self?.lastSessionExerciseCount = 0
                
                print("LiveActivity 모두 초기화 완료")
            }
        }
    }
    
    /// 앱이 백그라운드로 전환될 때 처리
    func handleAppBackgroundTransition() {
        // 휴식 타이머가 실행 중인 경우에도 LiveActivity 유지
        if currentMode == .restTimerMode || currentMode == .fadeInRestTimerMode || currentMode == .fadeInWorkoutMode {
            print("백그라운드 전환: 휴식 타이머 또는 전환 중 LiveActivity 유지")
            // 라이브 액티비티는 백그라운드에서도 계속 작동합니다
        }
    }
    
    // MARK: - Private 헬퍼 메서드
    
    // 휴식 모드로의 부드러운 전환 적용
    private func applyTransitionToRestMode(for set: WorkoutSet) {
        guard let activity = currentActivity else { return }
        
        let remainingTime = Int(set.remainingRestTime)
        
        // 첫 번째 상태 업데이트 (전환 시작)
        let transitionState = WorkoutActivityAttributes.ContentState(
            startTime: workoutStartTime,
            exerciseCount: lastSessionExerciseCount,
            completedSets: lastSessionCompletedSets,
            totalSets: lastSessionTotalSets,
            isRestMode: true,  // 이제 휴식 모드로 전환
            restExerciseName: restExerciseName,
            remainingRestTime: remainingTime
        )
        
        // Sendable 문제 해결을 위해 클로저로 전달되기 전에 필요한 값을 로컬 변수에 저장
        let capturedRemainingTime = remainingTime
        
        Task {
            // 첫 번째 전환 상태 적용
            await activity.update(ActivityContent(state: transitionState, staleDate: nil))
            
            // 마지막 업데이트 시간 갱신
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.lastRestUpdateTime = Date()
                
                // 약간의 시간 후 완전한 휴식 모드 적용
                DispatchQueue.main.asyncAfter(deadline: .now() + UpdateIntervals.animationDuration) {
                    self.finalizeRestTimerTransition(remainingTime: capturedRemainingTime)
                }
            }
        }
    }
    
    // 휴식 모드 전환 완료
    private func finalizeRestTimerTransition(remainingTime: Int) {
        guard let activity = currentActivity, currentMode == .fadeInRestTimerMode else { return }
        
        lastRestTimeValue = remainingTime
        
        // 완전한 휴식 상태 (운동 정보는 모두 0으로 처리)
        let finalRestState = WorkoutActivityAttributes.ContentState(
            startTime: workoutStartTime,
            exerciseCount: 0,
            completedSets: 0,
            totalSets: 0,
            isRestMode: true,
            restExerciseName: restExerciseName,
            remainingRestTime: remainingTime
        )
        
        Task {
            await activity.update(ActivityContent(state: finalRestState, staleDate: nil))
            
            DispatchQueue.main.async { [weak self] in
                self?.currentMode = .restTimerMode
                self?.lastRestUpdateTime = Date()
                print("휴식 타이머 전환 완료: \(remainingTime)초")
            }
        }
    }
    
    // 운동 모드로의 부드러운 전환 적용
    private func applyTransitionToWorkoutMode() {
        guard let activity = currentActivity else {
            print("LiveActivityService: 활성 Activity가 없어 운동 모드 전환 불가")
            return
        }
        
        print("LiveActivityService: 운동 모드로 전환 적용 시작")
        
        // 첫 번째 상태 업데이트 (전환 시작)
        let transitionState = WorkoutActivityAttributes.ContentState(
            startTime: workoutStartTime,
            exerciseCount: lastSessionExerciseCount,  // 저장된 운동 개수 사용
            completedSets: lastSessionCompletedSets,  // 저장된 완료 세트 사용
            totalSets: lastSessionTotalSets,          // 저장된 총 세트 사용
            isRestMode: false,                       // 이제 운동 모드로 전환
            restExerciseName: "",
            remainingRestTime: 0
        )
        
        Task {
            try? await activity.update(ActivityContent(state: transitionState, staleDate: nil))
            
            print("LiveActivityService: 운동 모드 전환 중간 상태 업데이트 완료")
            
            // 약간의 시간 후 완전한 운동 모드 적용
            try? await Task.sleep(for: .seconds(UpdateIntervals.animationDuration))
            
            // 완전한 운동 상태
            let finalWorkoutState = WorkoutActivityAttributes.ContentState(
                startTime: workoutStartTime,
                exerciseCount: lastSessionExerciseCount,
                completedSets: lastSessionCompletedSets,
                totalSets: lastSessionTotalSets,
                isRestMode: false,
                restExerciseName: "",
                remainingRestTime: 0
            )
            
            try? await activity.update(ActivityContent(state: finalWorkoutState, staleDate: nil))
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.currentMode = .workoutMode
                self.lastWorkoutUpdateTime = Date()
                print("LiveActivityService: 운동 모드 전환 완료")
            }
        }
    }
    
    private func createNewWorkoutActivity(workoutName: String, startTime: Date) {
        // 세부 정보 저장
        self.workoutName = workoutName
        self.workoutStartTime = startTime
        
        let initialState = WorkoutActivityAttributes.ContentState(
            startTime: startTime,
            exerciseCount: 0,
            completedSets: 0,
            totalSets: 0
        )
        
        let attributes = WorkoutActivityAttributes(workoutName: workoutName)
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: ActivityContent(state: initialState, staleDate: nil),
                pushType: nil
            )
            
            currentActivity = activity
            currentMode = .workoutMode
            lastWorkoutUpdateTime = Date()
            
            print("운동 라이브 액티비티 시작: \(workoutName)")
        } catch {
            print("LiveActivity 시작 실패: \(error.localizedDescription)")
        }
    }
}

// ScenePhase 감지를 위한 SwiftUI 환경 모니터
struct ScenePhaseObserver: ViewModifier {
    @Environment(\.scenePhase) var scenePhase
    
    func body(content: Content) -> some View {
        content
            .onChange(of: scenePhase) { _, newPhase in
                NotificationCenter.default.post(
                    name: NSNotification.Name("scenePhaseChanged"),
                    object: newPhase
                )
            }
    }
}

extension View {
    func observeScenePhase() -> some View {
        self.modifier(ScenePhaseObserver())
    }
} 