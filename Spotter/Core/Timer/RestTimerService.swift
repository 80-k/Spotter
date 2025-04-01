// RestTimerService.swift
// 휴식 타이머 서비스 구현
//  Created by woo on 3/31/25.

import Foundation
import SwiftUI

/// 휴식 타이머 관리 서비스
final class RestTimerService: RestTimerProtocol {
    // 싱글톤 인스턴스
    static let shared = RestTimerService()
    
    // MARK: - 속성
    
    // 타이머 관련
    private var restTimer: Timer?
    
    // 마지막 휴식 타이머 값
    private var lastRestTimeValue: Int = -1
    
    // 앱 백그라운드 전환 시간 추적
    private var appBackgroundedTime: Date?
    
    // LiveActivity 서비스 참조
    private let liveActivityService = LiveActivityService.shared
    
    // 뷰모델 참조를 저장할 약한 참조 (순환 참조 방지)
    private weak var viewModel: ActiveWorkoutViewModel?
    private weak var _currentActiveSet: WorkoutSet?
    
    /// 현재 타이머가 활성 상태인지 여부
    var isActive: Bool {
        return restTimer != nil
    }
    
    /// 현재 활성 세트
    var currentActiveSet: WorkoutSet? {
        return _currentActiveSet
    }
    
    // 초기화
    private init() {}
    
    // MARK: - 공개 메서드
    
    /// 휴식 타이머 시작
    func startTimer(for set: WorkoutSet, viewModel: ActiveWorkoutViewModel) {
        // 기존 타이머 정리
        stopTimer()
        
        // 참조 저장
        self.viewModel = viewModel
        self._currentActiveSet = set
        
        // 상태 설정
        if let exercise = set.exerciseItem {
            viewModel.currentActiveExercise = exercise
            viewModel.currentActiveSet = set
            viewModel.remainingRestTime = set.restTime
            viewModel.restTimerActive = true
            
            // LiveActivity 업데이트
            liveActivityService.startRestTimerActivity(for: set)
            
            print("휴식 타이머 시작: \(exercise.name), 시간: \(Int(set.restTime))초")
        }
        
        // 타이머 시작
        startInternalTimer(for: set)
    }
    
    /// 휴식 타이머 중지
    func stopTimer() {
        // 타이머 무효화 및 정리
        restTimer?.invalidate()
        restTimer = nil
        
        // 활성 상태에서 수동으로 중지된 경우에만 LiveActivity 업데이트
        if let viewModel = viewModel, viewModel.restTimerActive, viewModel.remainingRestTime > 0 {
            print("휴식 타이머 수동 중지: 운동 모드로 전환")
            liveActivityService.updateWorkoutActivity(for: viewModel.currentSession)
        }
        
        // 타이머 상태 재설정
        _currentActiveSet = nil
    }
    
    /// 앱이 백그라운드로 전환될 때 호출
    func handleAppBackgrounded() {
        // 백그라운드 전환 시점 기록
        if let viewModel = viewModel, viewModel.restTimerActive, let set = _currentActiveSet {
            appBackgroundedTime = Date()
            
            // LiveActivity 현재 상태로 업데이트
            liveActivityService.updateRestTimerActivity(for: set)
            print("앱 백그라운드 전환: LiveActivity 업데이트 (\(Int(viewModel.remainingRestTime))초 남음)")
        } else if let viewModel = viewModel {
            // 운동 모드 유지
            liveActivityService.updateWorkoutActivity(for: viewModel.currentSession)
            print("앱 백그라운드 전환: 운동 모드 설정")
        }
        
        // 백그라운드 전환 처리
        liveActivityService.handleAppBackgroundTransition()
    }
    
    /// 앱이 포그라운드로 돌아올 때 호출
    func handleAppForegrounded() {
        handleTimerAfterBackgrounding()
    }
    
    // MARK: - 내부 메서드
    
    /// 내부 타이머 시작
    private func startInternalTimer(for set: WorkoutSet) {
        // 타이머 시작 시간 정확히 기록
        let timerStartTime = Date()
        
        // 타이머 생성 (0.25초 간격으로 정확한 업데이트)
        restTimer = Timer(timeInterval: 0.25, repeats: true) { [weak self, weak viewModel, weak set] timer in
            guard
                let self = self,
                let viewModel = viewModel,
                viewModel.restTimerActive,
                let set = set
            else {
                timer.invalidate()
                return
            }
            
            // 시간 계산 및 업데이트
            self.updateRemainingTime(
                timerStartTime: timerStartTime,
                set: set,
                viewModel: viewModel
            )
        }
        
        // RunLoop에 타이머 추가
        if let timer = restTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    /// 남은 시간 업데이트
    private func updateRemainingTime(timerStartTime: Date, set: WorkoutSet, viewModel: ActiveWorkoutViewModel) {
        // 현재 시간 기준으로 경과 시간 계산
        let now = Date()
        let elapsedTime = now.timeIntervalSince(timerStartTime)
        let adjustedRemainingTime = max(0, set.restTime - elapsedTime)
        
        // 표시를 위해 가장 가까운 초로 반올림
        let roundedRemainingTime = ceil(adjustedRemainingTime - 0.25)
        
        // 중요: ViewModel과 WorkoutSet 둘 다 업데이트
        viewModel.remainingRestTime = max(0, roundedRemainingTime)
        set.remainingRestTime = max(0, roundedRemainingTime)
        
        // 초 단위 변경 시에만 LiveActivity 업데이트
        let currentSecond = Int(viewModel.remainingRestTime)
        if currentSecond != lastRestTimeValue {
            lastRestTimeValue = currentSecond
            
            // LiveActivity 업데이트 - 우선순위 높게 설정하고 직접 set 객체 전달
            Task(priority: .high) {
                print("RestTimerService: LiveActivity 업데이트 - \(currentSecond)초 남음")
                // 업데이트 전 set의 값이 정확한지 다시 확인
                set.remainingRestTime = Double(currentSecond)
                self.liveActivityService.updateRestTimerActivity(for: set)
            }
        }
        
        // 타이머 완료 시
        if viewModel.remainingRestTime <= 0 {
            handleTimerCompletion(viewModel: viewModel)
        }
    }
    
    /// 타이머 완료 처리
    private func handleTimerCompletion(viewModel: ActiveWorkoutViewModel) {
        // 타이머 종료 처리
        viewModel.restTimerActive = false
        
        // 현재 세트가 있다면 남은 시간을 0으로 설정
        if let set = _currentActiveSet {
            // 명시적으로 남은 시간을 0으로 설정
            set.remainingRestTime = 0
            viewModel.remainingRestTime = 0
            
            // LiveActivity에 최종 업데이트 전송 - 남은 시간 0으로 표시
            Task(priority: .high) {
                print("RestTimerService: 타이머 완료 - LiveActivity 최종 업데이트 (0초)")
                liveActivityService.updateRestTimerActivity(for: set)
                
                // 약간의 지연 후 운동 모드로 전환
                try? await Task.sleep(for: .seconds(0.5))
                liveActivityService.switchToWorkoutMode()
            }
        }
        
        // 진동 피드백
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #endif
        
        // 타이머 중지
        stopTimer()
        
        print("휴식 타이머 완료: 운동 모드로 전환")
    }
    
    /// 백그라운드에서 복귀 후 타이머 처리
    private func handleTimerAfterBackgrounding() {
        // 휴식 타이머가 활성 상태이고 백그라운드 시간을 알고 있는 경우
        guard let viewModel = viewModel,
              viewModel.restTimerActive,
              let backgroundTime = appBackgroundedTime,
              let set = _currentActiveSet else {
            // 휴식 타이머가 종료된 경우 운동 모드로 전환
            if let viewModel = viewModel, !viewModel.restTimerActive {
                liveActivityService.updateWorkoutActivity(for: viewModel.currentSession)
            }
            return
        }
        
        // 백그라운드에 있던 시간 계산
        let timeInBackground = Date().timeIntervalSince(backgroundTime)
        
        // 남은 시간 조정
        let newRemainingTime = max(0, viewModel.remainingRestTime - timeInBackground)
        viewModel.remainingRestTime = newRemainingTime
        
        // 백그라운드에 있는 동안 타이머가 완료되었어야 하는 경우
        if viewModel.remainingRestTime <= 0 {
            // 타이머 상태 정리
            viewModel.restTimerActive = false
            
            liveActivityService.updateWorkoutActivity(for: viewModel.currentSession)
            
            print("휴식 타이머가 백그라운드에서 완료됨")
            
            // 진동 피드백
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
            
            // 타이머 중지
            stopTimer()
        } else {
            // 타이머가 아직 활성 상태면 LiveActivity 업데이트
            liveActivityService.updateRestTimerActivity(for: set)
        }
        
        // 백그라운드 시간 초기화
        appBackgroundedTime = nil
    }
} 