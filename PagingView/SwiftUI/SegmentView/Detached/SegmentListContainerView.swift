//
//  SegmentListContainerView.swift
//  PagingView
//
//  Created by Sun on 2024/8/1.
//

import UIKit
import SwiftUI

/// Detached SegmentedListContainerView
public struct SegmentListContainerView<T: Hashable, C: View, L: View, N: View>: View {
    
    let pages: [Page<T, C, L, N>]
    
    private var onDidScroll: ((CGFloat) -> Void)?
    private var onListContainer: ((SegmentedListContainerView) -> Void)?
    
    private var count: Int
    private var foregroundColor: Color
    
    public var body: some View {
        ListContainerWrappedRepresentableView(
            foregroundColor: self.foregroundColor,
            count: self.count,
            pages: self.pages,
            onListContainer: self.onListContainer,
            onDidScroll: self.onDidScroll
        )
    }
    
    /// Initializer
    public init(
        _ count: Int = 0,
        foregroundColor: Color = .white,
        content: (Int) -> Page<T, C, L, N>
    ) {
        self.count = count
        self.foregroundColor = foregroundColor
        self.pages = (0..<count).map { index in
            content(index)
        }
    }
}

extension SegmentListContainerView {
    
    /// Called when the user finished scrolling to a new view.
    ///
    /// - Parameter action: A closure that is called with the
    /// paging item that was scrolled to.
    /// - Returns: An instance of self
    public func didScroll(_ action: @escaping (CGFloat) -> Void) -> Self {
        var view = self
        if let onDidScroll = view.onDidScroll {
            view.onDidScroll = { offsetY in
                onDidScroll(offsetY)
                action(offsetY)
            }
        } else {
            view.onDidScroll = action
        }
        return view
    }
    
    /// Called when the SegmentedListContainerView was created.
    ///
    /// - Parameter action: A closure that is called with the
    /// SegmentedListContainerView that was created.
    /// - Returns: An instance of self
    public func onListContainer(_ action: @escaping (SegmentedListContainerView) -> Void) -> Self {
        var view = self
        if let onListContainer = view.onListContainer {
            view.onListContainer = { containerView in
                onListContainer(containerView)
                action(containerView)
            }
        } else {
            view.onListContainer = action
        }
        return view
    }
}
