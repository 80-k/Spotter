// RestTimerManager.swift
// 휴식 타이머 관리를 위한 독립 클래스
//  Created by woo on 3/30/25.

import Foundation
import SwiftUI

class RestTimerManager {
    // 타이머 관련
    private var restTimer: Timer?
    
    // 마지막 휴식 타이머 값 (0이 되었을 때 중복 호출 방지)
    private var lastRestTimeValue: Int = -1
    
    // 앱 백그라운드 전환 시간 추적
    private var appBackgroundedTime: Date?
    
    // LiveActivity와의 통합을 위한 참조
    private let liveActivityManager = LiveActivityManager.shared
    
    // 뷰모델 참조를 저장할 약한 참조 (순환 참조 방지)
    private weak var viewModel: ActiveWorkoutViewModel?
    private weak var currentSet: WorkoutSet?
    
    init() {
        // 초기화 코드
    }
    
    // MARK: - 타이머 관리
    
    // 휴식 타이머 시작
    func startTimer(for set: WorkoutSet, viewModel: ActiveWorkoutViewModel) {
        // 1. 기존 타이머 정리
        stopTimer()
        
        // 2. 참조 저장
        self.viewModel = viewModel
        self.currentSet = set
        
        // 3. 상태 설정
        if let exercise = set.exercise {
            viewModel.currentActiveExercise = exercise
            viewModel.currentActiveSet = set
            viewModel.remainingRestTime = set.restTime
            viewModel.restTimerActive = true
            
            // LiveActivity 업데이트
            liveActivityManager.updateRestTimer(
                exerciseName: exercise.name,
                remainingTime: Int(set.restTime)
            )
            
            print("휴식 타이머 시작: \(exercise.name), 시간: \(Int(set.restTime))초")
        }
        
        // 4. 타이머 시작 시간 기록
        let timerStartTime = Date()
        
        // 5. 타이머 생성 (0.25초 간격으로 더 정확한 업데이트)
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
            
            // 실제 경과 시간에 기반한 계산으로 타이머 드리프트 방지
            let elapsedTime = Date().timeIntervalSince(timerStartTime)
            let adjustedRemainingTime = max(0, set.restTime - elapsedTime)
            
            // 표시를 위해 가장 가까운 초로 반올림
            let roundedRemainingTime = ceil(adjustedRemainingTime - 0.25)
            viewModel.remainingRestTime = max(0, roundedRemainingTime)
            
            // 초 단위 변경 시에만 LiveActivity 업데이트 (업데이트 빈도 줄이기)
            let currentSecond = Int(viewModel.remainingRestTime)
            if let exercise = set.exercise, currentSecond != self.lastRestTimeValue {
                self.lastRestTimeValue = currentSecond
                self.liveActivityManager.updateRestTimer(
                    exerciseName: exercise.name,
                    remainingTime: currentSecond
                )
            }
            
            // 타이머 완료 시
            if viewModel.remainingRestTime <= 0 {
                viewModel.restTimerActive = false
                
                // 진동 피드백
                #if os(iOS)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                #endif
                
                // LiveActivity 업데이트
                self.liveActivityManager.switchToWorkoutMode()
                
                // 타이머 중지
                self.stopTimer()
                
                print("휴식 타이머 완료: 운동 모드로 전환")
            }
        }
        
        // 사용자 상호작용 중에도 타이머가 계속 작동하도록 RunLoop에 추가
        if let timer = restTimer {
            RunLoop.current.add(timer, forMode: .common)
        }
    }
    
    // 휴식 타이머 중지
    func stopTimer() {
        // 타이머 무효화 및 정리
        restTimer?.invalidate()
        restTimer = nil
        
        // 활성 상태에서 수동으로 중지된 경우에만 LiveActivity 업데이트
        if let viewModel = viewModel, viewModel.restTimerActive && viewModel.remainingRestTime > 0 {
            print("휴식 타이머 수동 중지: 운동 모드로 전환")
            liveActivityManager.switchToWorkoutMode()
        }
        
        // 타이머 상태 재설정
        currentSet = nil
    }
    
    // MARK: - 앱 상태 관리
    
    // 앱이 백그라운드로 전환될 때
    func handleAppBackgrounded() {
        // 백그라운드 전환 시점 기록
        if let viewModel = viewModel, viewModel.restTimerActive {
            appBackgroundedTime = Date()
            
            // LiveActivity 현재 상태로 업데이트
            if let exercise = viewModel.currentActiveExercise {
                liveActivityManager.updateRestTimer(
                    exerciseName: exercise.name,
                    remainingTime: Int(viewModel.remainingRestTime)
                )
                print("앱 백그라운드 전환: LiveActivity 업데이트 (\(Int(viewModel.remainingRestTime))초 남음)")
            }
        } else if let viewModel = viewModel {
            // 운동 모드 유지
            liveActivityManager.switchToWorkoutMode()
            print("앱 백그라운드 전환: 운동 모드 설정")
        }
        
        // 현재 상태 로깅
        liveActivityManager.logCurrentState()
    }
    
    // 앱이 포그라운드로 돌아올 때
    func handleAppForegrounded() {
        // 휴식 타이머가 활성 상태이고 백그라운드 시간을 알고 있는 경우
        if let viewModel = viewModel,
           viewModel.restTimerActive,
           let backgroundTime = appBackgroundedTime,
           let set = currentSet {
            
            // 백그라운드에 있던 시간 계산
            let timeInBackground = Date().timeIntervalSince(backgroundTime)
            
            // 남은 시간 조정
            let newRemainingTime = max(0, viewModel.remainingRestTime - timeInBackground)
            viewModel.remainingRestTime = newRemainingTime
            
            // 백그라운드에 있는 동안 타이머가 완료되었어야 하는 경우
            if viewModel.remainingRestTime <= 0 {
                // 타이머 상태 정리
                viewModel.restTimerActive = false
                liveActivityManager.switchToWorkoutMode()
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
                if let exercise = viewModel.currentActiveExercise {
                    liveActivityManager.updateRestTimer(
                        exerciseName: exercise.name,
                        remainingTime: Int(viewModel.remainingRestTime)
                    )
                    print("앱 포그라운드 복귀: 타이머 \(Int(viewModel.remainingRestTime))초 남음으로 업데이트")
                    
                    // 새 타이머 시작 (백그라운드 시간을 고려한 상태에서)
                    if let set = viewModel.currentActiveSet {
                        // 이전 타이머 중지
                        restTimer?.invalidate()
                        restTimer = nil
                        
                        // 남은 시간으로 새 타이머 생성
                        let adjustedSet = set
                        adjustedSet.restTime = viewModel.remainingRestTime
                        startTimer(for: adjustedSet, viewModel: viewModel)
                    }
                }
            }
        } else if let viewModel = viewModel, !viewModel.restTimerActive {
            // 일반 운동 모드
            liveActivityManager.switchToWorkoutMode()
        }
        
        // 백그라운드 시간 초기화
        appBackgroundedTime = nil
        
        // 현재 상태 로깅
        liveActivityManager.logCurrentState()
    }
}
