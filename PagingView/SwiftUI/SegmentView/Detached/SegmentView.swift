//
//  SegmentView.swift
//  PagingView
//
//  Created by Sun on 2024/7/31.
//

import UIKit
import SwiftUI

/// Detached SegmentView
public struct SegmentView: View {
    
    private let dataSource: SegmentedTitleDataSource
    private let indicator: SegmentedIndicatorView
    
    private var onSelect: ((Int) -> Void)?
    
    private var segmentedHeight: CGFloat
    private var foregroundColor: Color
    private var defaultSelectedIndex: Int
    private var listContainer: SegmentedListContainerView?
    private var isSyncScrollingWhenScrollListContainer: Bool = true
    
    public var body: some View {
        SegmentWappedRepresentableView(
            foregroundColor: self.foregroundColor,
            defaultSelectedIndex: self.defaultSelectedIndex,
            isSyncScrollingWhenScrollListContainer: self.isSyncScrollingWhenScrollListContainer,
            dataSource: self.dataSource,
            indicator: self.indicator,
            listContainer: self.listContainer,
            onSelect: self.onSelect
        )
        .frame(height: self.segmentedHeight)
    }
    
    /// Initializer
    public init<Title: StringProtocol>(
        _ titles: [Title],
        segmentedHeight: CGFloat = 50,
        foregroundColor: Color = .white,
        defaultSelectedIndex: Int = 0,
        listContainer: SegmentedListContainerView?
    ) {
        self.segmentedHeight = segmentedHeight
        self.foregroundColor = foregroundColor
        self.defaultSelectedIndex = defaultSelectedIndex
        let dataSource = SegmentedTitleDataSource()
        dataSource.titles = titles.map { String($0) }
        self.dataSource = dataSource
        self.listContainer = listContainer
        self.indicator = SegmentedIndicatorLineView()
    }
}

extension SegmentView {
    
    /// Called when an item was selected in the menu.
    ///
    /// - Parameter action: A closure that is called with the
    /// selected paging item.
    /// - Returns: An instance of self
    public func didSelect(_ action: @escaping (Int) -> Void) -> Self {
        var view = self
        if let didSelect = view.onSelect {
            view.onSelect = { index in
                didSelect(index)
                action(index)
            }
        } else {
            view.onSelect = action
        }
        return view
    }
    
    /// Whether to scroll synchronously when scrolling the list container.
    public func isSyncScrollingWhenScrollListContainer(_ isSync: Bool) -> Self {
        var view = self
        view.isSyncScrollingWhenScrollListContainer = isSync
        return view
    }
}

extension SegmentView {
    // MARK: - Segmented Item
    
    /// The color of the segmented items when not selected.
    public func titleNormalColor(_ color: Color) -> Self {
        self.dataSource.titleNormalColor = UIColor(color)
        return self
    }
    
    /// The color of the menu items when selected.
    public func titleSelectedColor(_ color: Color) -> Self {
        self.dataSource.titleSelectedColor = UIColor(color)
        return self
    }
    
    /// The font of the segmented items when not selected.
    public func titleNormalFont(_ font: UIFont) -> Self {
        self.dataSource.titleNormalFont = font
        return self
    }
    
    /// The font of the segmented items when selected.
    public func titleSelectedFont(_ font: UIFont) -> Self {
        self.dataSource.titleSelectedFont = font
        return self
    }
    
    /// Whether the title color should be gradually changed.
    public func isTitleColorGradientEnabled(_ enabled: Bool) -> Self {
        self.dataSource.isTitleColorGradientEnabled = enabled
        return self
    }
    
    /// Whether the title is scaled.
    public func isTitleZoomEnabled(_ enabled: Bool) -> Self {
        self.dataSource.isTitleZoomEnabled = enabled
        return self
    }
    
    /// It takes effect only when `isTitleZoomEnabled` is true.
    ///
    /// It is a scaling of the font size.
    public func titleSelectedZoomScale(_ scale: CGFloat) -> Self {
        self.dataSource.titleSelectedZoomScale = scale
        return self
    }
    
    /// Determine the width increment of the title item.
    public func itemWidthIncrement(_ widthIncrement: CGFloat) -> Self {
        self.dataSource.itemWidthIncrement = widthIncrement
        return self
    }
    
    /// The spacing between items.
    public func itemSpacing(_ spacing: CGFloat) -> Self {
        self.dataSource.itemSpacing = spacing
        return self
    }
    
    /// When collectionView.contentSize.width is smaller than the width of `SegmentedView`, whether to divide itemSpacing equally.
    public func isItemSpacingEquallyEnabled(_ enabled: Bool) -> Self {
        self.dataSource.isItemSpacingEquallyEnabled = enabled
        return self
    }
}

extension SegmentView {
    // MARK: - Segmented Indicator
    
    /// Determine the width of the indicator view.
    public func indicatorWidth(_ width: CGFloat) -> Self {
        self.indicator.indicatorWidth = width
        return self
    }
    
    /// Determine the height of the indicator view.
    public func indicatorHeight(_ height: CGFloat) -> Self {
        self.indicator.indicatorHeight = height
        return self
    }
    
    /// Determine the corner radius of the indicator view.
    public func indicatorCornerRadius(_ radius: CGFloat) -> Self {
        self.indicator.indicatorCornerRadius = radius
        return self
    }
    
    /// Determine the width increment of the indicator view.
    public func indicatorWidthIncrement(_ widthIncrement: CGFloat) -> Self {
        self.indicator.indicatorWidthIncrement = widthIncrement
        return self
    }
    
    /// Determine the color of the indicator view.
    public func indicatorColor(_ color: Color) -> Self {
        self.indicator.indicatorColor = UIColor(color)
        return self
    }
    
    /// Determine the position of the indicator view.
    public func indicatorPosition(_ position: SegmentedIndicatorPosition) -> Self {
        self.indicator.indicatorPosition = position
        return self
    }
    
    /// Determine the vertical offset of the indicator view.
    public func indicatorVerticalOffset(_ verticalOffset: CGFloat) -> Self {
        self.indicator.verticalOffset = verticalOffset
        return self
    }
}
