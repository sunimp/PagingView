//
//  ListType.swift
//  Example
//
//  Created by Sun on 2024/7/30.
//

import UIKit

enum ListType: CaseIterable {
    
    case recent
    case nearby
    case all
    
    var title: String {
        switch self {
        case .recent: return "Recent"
        case .nearby: return "Nearby"
        case .all: return "All"
        }
    }
}

enum CellStyle {
    
    case solid
    case translucent
    
    func backgroundColor(for listType: ListType) -> UIColor {
        switch listType {
        case .recent:
            switch self {
            case .solid:
                return .systemBlue
            case .translucent:
                return .systemBlue.withAlphaComponent(0.45)
            }
        case .nearby:
            switch self {
            case .solid:
                return .systemGreen
            case .translucent:
                return .systemGreen.withAlphaComponent(0.45)
            }
        case .all:
            switch self {
            case .solid:
                return .systemPink
            case .translucent:
                return .systemPink.withAlphaComponent(0.45)
            }
        }
    }
    
    func insets(for listType: ListType) -> UIEdgeInsets {
        switch listType {
        case .recent:
            return UIEdgeInsets(
                top: 5,
                left: 5,
                bottom: -5,
                right: -CGFloat.random(in: 5...120)
            )
            
        case .nearby:
            return .zero
            
        case .all:
            return UIEdgeInsets(top: 5, left: 5, bottom: -5, right: -5)
        }
    }
}
