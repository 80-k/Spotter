// ViewModelSyncProtocol.swift
// 뷰모델 동기화 프로토콜
// Created by woo on 4/19/25.

import Foundation

/// 뷰모델 간 상태 동기화를 위한 프로토콜
protocol ViewModelSyncProtocol {
    /// 뷰모델 간 상태 동기화
    func syncViewModels<SourceModel: StateUpdateable, TargetModel: StateUpdateable>(
        source: SourceModel, 
        target: TargetModel
    )
    
    /// 여러 뷰모델의 상태 동기화
    func syncMultipleViewModels<SourceModel: StateUpdateable>(
        source: SourceModel,
        targets: [any StateUpdateable]
    )
}

/// 기본 구현 제공
extension ViewModelSyncProtocol {
    /// 뷰모델 간 상태 동기화 기본 구현
    func syncViewModels<SourceModel: StateUpdateable, TargetModel: StateUpdateable>(
        source: SourceModel, 
        target: TargetModel
    ) {
        target.syncState(from: source)
    }
    
    /// 여러 뷰모델의 상태 동기화 기본 구현
    func syncMultipleViewModels<SourceModel: StateUpdateable>(
        source: SourceModel,
        targets: [any StateUpdateable]
    ) {
        for target in targets {
            target.syncState(from: source)
        }
    }
} 