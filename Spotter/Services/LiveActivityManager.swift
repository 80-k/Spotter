// LiveActivityManager.swift
// 다이나믹 아일랜드 라이브 액티비티 관리 - 전환 딜레이 감소
// Created by woo on 3/29/25.

import Foundation
import ActivityKit
import Combine
import SwiftUI
import UIKit

class LiveActivityManager {
    static let shared = LiveActivityManager()
    
    // 현재 활성 Activity
    private var currentActivity: Activity<WorkoutActivityAttributes>?
    
    // 상태 관리를 위한 명확한 열거형 정의
    enum ActivityMode {
        case none           // 활동 없음
        case workout        // 일반 운동 모드
        case restTimer      // 휴식 타이머 모드
    }
    
    // 현재 활동 모드
    private var currentMode: ActivityMode = .none
    
    // 마지막 업데이트 시간 추적 - 모드별로 분리
    private var lastWorkoutUpdateTime: Date = Date()
    private var lastRestUpdateTime: Date = Date()
    
    // 업데이트 제한 간격 (초) - 모드 전환에는 더 짧은 간격 적용
    private let regularUpdateInterval: TimeInterval = 0.5  // 일반 업데이트
    private let transitionUpdateInterval: TimeInterval = 0.1  // 모드 전환용
    
    // 운동 세부 정보 저장
    private var workoutName: String = ""
    private var workoutStartTime: Date = Date()
    private var restExerciseName: String = ""
    
    // 마지막 휴식 타이머 값 (0이 되었을 때 중복 호출 방지)
    private var lastRestTimeValue: Int = -1
    
    // 앱 종료 감지를 위한 Notification 구독
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // 앱 종료 및 백그라운드 전환 감지
        setupNotifications()
        
        // AppStateManager에 등록
        registerWithAppStateManager()
    }
    
    // 앱 상태 변경 감지를 위한 알림 설정
    private func setupNotifications() {
        // 앱 종료 감지
        NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)
            .sink { [weak self] _ in
                print("앱 종료 감지: LiveActivity 종료 중...")
                self?.endAllActivities()
            }
            .store(in: &cancellables)
        
        // 앱이 백그라운드로 전환될 때 타이머 중지
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                print("앱 백그라운드 전환 감지: LiveActivity 상태 저장 중...")
                self?.handleBackgroundTransition()
            }
            .store(in: &cancellables)
    }
    
    // AppStateManager와 연동
    private func registerWithAppStateManager() {
        let appStateManager = AppStateManager.shared
        
        // 백그라운드 전환 시 콜백
        appStateManager.onBackgrounded = { [weak self] in
            print("AppStateManager: 앱이 백그라운드로 전환됨")
            self?.handleBackgroundTransition()
        }
    }
    
    // 앱이 백그라운드로 전환될 때 처리
    private func handleBackgroundTransition() {
        // 휴식 타이머가 실행 중인 경우에는 종료
        if currentMode == .restTimer {
            print("백그라운드 전환: 휴식 타이머 실행 중 - LiveActivity 종료")
            endAllActivities()
        }
    }
    
    // 백그라운드 전환을 외부에서 처리할 수 있는 public 메서드
    func handleAppBackgroundTransition() {
        print("LiveActivityManager: 앱 백그라운드 전환 처리")
        handleBackgroundTransition()
    }
    
    // 모든 활동 즉시 종료 (앱 종료 시 호출)
    private func endAllActivities() {
        if let activity = currentActivity {
            Task {
                do {
                    // 즉시 종료 정책 사용
                    await activity.end(dismissalPolicy: .immediate)
                    print("LiveActivity 즉시 종료 성공")
                } catch {
                    print("LiveActivity 종료 실패: \(error)")
                }
            }
        }
        
        currentActivity = nil
        currentMode = .none
    }
    
    // 모든 활동 종료 및 상태 초기화
    func reset() {
        if let activity = currentActivity {
            Task {
                await activity.end(
                    ActivityContent(
                        state: WorkoutActivityAttributes.ContentState(
                            startTime: workoutStartTime,
                            elapsedTime: 0,
                            isRestTimer: false,
                            restExerciseName: "",
                            restTimeRemaining: 0
                        ),
                        staleDate: nil
                    ),
                    dismissalPolicy: .immediate
                )
            }
        }
        
        currentActivity = nil
        currentMode = .none
        workoutName = ""
        workoutStartTime = Date()
        restExerciseName = ""
        lastRestTimeValue = -1
        
        print("LiveActivity 모두 초기화 완료")
    }
    
    // 운동 라이브 액티비티 시작
    func startActivity(workoutName: String, startTime: Date) {
        // 이미 활성화되어 있는 활동이 있으면 종료
        if currentActivity != nil {
            reset()
        }
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("라이브 액티비티가 활성화되지 않았습니다.")
            return
        }
        
        // 세부 정보 저장
        self.workoutName = workoutName
        self.workoutStartTime = startTime
        
        let attributes = WorkoutActivityAttributes(workoutName: workoutName)
        let contentState = WorkoutActivityAttributes.ContentState(
            startTime: startTime,
            elapsedTime: 0,
            isRestTimer: false,
            restExerciseName: "",
            restTimeRemaining: 0
        )
        
        do {
            let initialContent = ActivityContent(state: contentState, staleDate: nil)
            
            currentActivity = try Activity.request(
                attributes: attributes,
                content: initialContent,
                pushType: nil
            )
            
            // 모드 업데이트
            currentMode = .workout
            lastWorkoutUpdateTime = Date()
            
            print("운동 라이브 액티비티 시작: \(workoutName), 모드: \(currentMode)")
        } catch {
            print("라이브 액티비티 시작 실패: \(error)")
        }
    }
    
    // 휴식 타이머 시작 또는 업데이트 - 최적화된 버전
    func updateRestTimer(exerciseName: String, remainingTime: Int) {
        // 값이 같으면 중복 업데이트 방지 (0초가 여러번 호출되는 경우)
        if remainingTime == lastRestTimeValue {
            return
        }
        
        // 마지막 값 저장
        lastRestTimeValue = remainingTime
        
        // 시간이 0이면 즉시 운동 모드로 전환 (딜레이 없음)
        if remainingTime <= 0 {
            if currentMode == .restTimer {
                switchToWorkoutMode(immediate: true)  // 즉시 전환 플래그
            }
            return
        }
        
        // 모드 전환 여부 확인
        let isTransitionToRestMode = currentMode != .restTimer
        
        // 현재 모드 확인 및 저장
        if isTransitionToRestMode {
            print("휴식 타이머 모드로 전환: \(exerciseName), 남은 시간: \(remainingTime)초")
            restExerciseName = exerciseName
        }
        
        // 업데이트 제한 (너무 빠른 연속 업데이트 방지)
        // 모드 전환 시에는 더 빠른 업데이트 허용
        let now = Date()
        let minInterval = isTransitionToRestMode ? transitionUpdateInterval : regularUpdateInterval
        
        if now.timeIntervalSince(lastRestUpdateTime) < minInterval && !isTransitionToRestMode {
            return  // 모드 전환이 아닌 일반 업데이트는 제한 적용
        }
        
        // LiveActivity가 없으면 새로 만들기
        if currentActivity == nil {
            createRestTimerActivity(exerciseName: exerciseName, remainingTime: remainingTime)
            return
        }
        
        // 기존 LiveActivity 업데이트
        guard let activity = currentActivity else { return }
        
        let updatedState = WorkoutActivityAttributes.ContentState(
            startTime: workoutStartTime,
            elapsedTime: Date().timeIntervalSince(workoutStartTime),
            isRestTimer: true,
            restExerciseName: exerciseName,
            restTimeRemaining: remainingTime
        )
        
        let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(updatedContent)
            currentMode = .restTimer
            lastRestUpdateTime = Date()
        }
    }
    
    // 운동 모드로 명시적 전환 - 최적화된 버전
    func switchToWorkoutMode(immediate: Bool = false) {
        guard let activity = currentActivity else { return }
        
        // 이미 운동 모드면 무시
        if currentMode == .workout {
            return
        }
        
        // 업데이트 제한 (immediate 플래그가 true면 무시)
        let now = Date()
        if !immediate && now.timeIntervalSince(lastWorkoutUpdateTime) < transitionUpdateInterval {
            return
        }
        
        print("운동 모드로 전환 중...")
        
        let updatedState = WorkoutActivityAttributes.ContentState(
            startTime: workoutStartTime,
            elapsedTime: Date().timeIntervalSince(workoutStartTime),
            isRestTimer: false,
            restExerciseName: "",
            restTimeRemaining: 0
        )
        
        let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
        
        Task(priority: .high) {  // 우선순위 높임
            await activity.update(updatedContent)
            currentMode = .workout
            lastWorkoutUpdateTime = Date()
            lastRestTimeValue = -1  // 리셋
            print("운동 모드로 전환 완료")
        }
    }
    
    // 새 휴식 타이머 활동 생성
    private func createRestTimerActivity(exerciseName: String, remainingTime: Int) {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("라이브 액티비티가 활성화되지 않았습니다.")
            return
        }
        
        // 세부 정보 저장
        self.restExerciseName = exerciseName
        
        let attributes = WorkoutActivityAttributes(workoutName: workoutName.isEmpty ? exerciseName : workoutName)
        let contentState = WorkoutActivityAttributes.ContentState(
            startTime: workoutStartTime,
            elapsedTime: Date().timeIntervalSince(workoutStartTime),
            isRestTimer: true,
            restExerciseName: exerciseName,
            restTimeRemaining: remainingTime  // 매개변수 이름을 수정함
        )
        
        do {
            let initialContent = ActivityContent(state: contentState, staleDate: nil)
            
            currentActivity = try Activity.request(
                attributes: attributes,
                content: initialContent,
                pushType: nil
            )
            
            currentMode = .restTimer
            lastRestUpdateTime = Date()
            
            print("휴식 타이머 활동 생성 성공: \(exerciseName)")
        } catch {
            print("휴식 타이머 활동 생성 실패: \(error)")
        }
    }
    
    // 운동 시간 업데이트 - 최적화된 버전
    func updateElapsedTime() {
        guard let activity = currentActivity else { return }
        
        // 휴식 타이머 모드면 업데이트 무시
        if currentMode == .restTimer {
            return
        }
        
        // 업데이트 제한 (초당 2회 이상 방지)
        let now = Date()
        if now.timeIntervalSince(lastWorkoutUpdateTime) < regularUpdateInterval {
            return
        }
        
        let updatedState = WorkoutActivityAttributes.ContentState(
            startTime: workoutStartTime,
            elapsedTime: Date().timeIntervalSince(workoutStartTime),
            isRestTimer: false,
            restExerciseName: "",
            restTimeRemaining: 0
        )
        
        let updatedContent = ActivityContent(state: updatedState, staleDate: nil)
        
        Task {
            await activity.update(updatedContent)
            
            // 모드 확인 및 설정
            if currentMode != .workout {
                currentMode = .workout
                print("모드 업데이트: 운동 모드")
            }
            
            lastWorkoutUpdateTime = Date()
        }
    }
    
    // 운동 라이브 액티비티 종료
    func endActivity() {
        guard let activity = currentActivity else {
            print("종료할 활동이 없음")
            return
        }
        
        // 즉시 종료하는 방식으로 변경
        Task {
            do {
                // 즉시 종료 정책 사용
                await activity.end(dismissalPolicy: .immediate)
                
                // 상태 초기화
                currentActivity = nil
                currentMode = .none
                lastRestTimeValue = -1
                
                print("LiveActivity 종료 완료")
            } catch {
                print("LiveActivity 종료 중 오류 발생: \(error)")
                
                // 오류 발생 시 강제 종료 시도
                endAllActivities()
            }
        }
    }
    
    // 현재 상태 로깅 (디버깅용)
    func logCurrentState() {
        print("===== LiveActivity 현재 상태 =====")
        print("모드: \(currentMode)")
        print("액티비티 존재: \(currentActivity != nil)")
        print("운동 이름: \(workoutName)")
        print("시작 시간: \(workoutStartTime)")
        print("현재 시간: \(Date())")
        
        if currentMode == .restTimer {
            print("휴식 운동: \(restExerciseName)")
            print("마지막 타이머 값: \(lastRestTimeValue)초")
        }
        
        print("================================")
    }
}

// ActivityMode 열거형 확장 - 문자열 표현
extension LiveActivityManager.ActivityMode: CustomStringConvertible {
    var description: String {
        switch self {
        case .none:
            return "없음"
        case .workout:
            return "운동 모드"
        case .restTimer:
            return "휴식 타이머 모드"
        }
    }
}
