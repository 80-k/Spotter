//
//  HistoryViewModel.swift
//  Spotter
//
//  Created by woo on 3/29/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class HistoryViewModel {
    // 데이터 모델 컨텍스트
    private var modelContext: ModelContext
    
    // 운동 세션 기록
    var sessions: [WorkoutSession] = []
    
    // 선택된 날짜
    var selectedDate: Date = Date()
    
    // 날짜별 운동 세션 맵
    var sessionsByDate: [Date: [WorkoutSession]] = [:]
    
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
    
    // 세션 삭제
    func deleteSession(_ session: WorkoutSession) {
        modelContext.delete(session)
        
        do {
            try modelContext.save()
            fetchSessions()
        } catch {
            print("세션 삭제 중 오류 발생: \(error)")
        }
    }
}
