//
//  SegmentedView.swift
//  PagingView
//
//  Created by Sun on 2024/7/25.
//

import UIKit

/// The type of item when it is selected.
///
/// - programmatically: Select by call the function `selectItem(at:)`
/// - clicking: Select by clicking on the item
/// - scrolling: Select by scrolling to the item
/// - unselected: Not selected
public enum SegmentedViewItemSelectedType {
    case programmatically
    case clicking
    case scrolling
    case unselected
}

/// The position of indicator when it is selected.
///
/// - top: At the top of `SegmentedView`.
/// - bottom: At the bottom of `SegmentedView`.
public enum SegmentedIndicatorPosition {
    case top
    case bottom
}

/// The style of line indicator when it is switching.
///
/// - normal: Normal style when rolling.
/// - lengthen: It will become longer when rolling.
/// - lengthenOffset: When scrolling, it will become longer and accompanied by offset.
public enum SegmentedIndicatorLineStyle {
    case normal
    case lengthen
    case lengthenOffset
}

///The container protocol of the list for the linkage of `NestPagingView` and `SegmentedView`.
public protocol SegmentedViewListContainer {
    
    /// Used to trigger the loading of the default index list.
    var defaultSelectedIndex: Int { set get }
    /// UIScrollView responsible for vertical scrolling of the view in the list.
    func contentScrollView() -> UIScrollView
    /// Function of reloading list data.
    func reloadData()
    /// Function used to calculate list lifecycle methods when the list is scrolled horizontally.
    func scrolling(from leftIndex: Int, to rightIndex: Int, percentage: CGFloat, selectedIndex: Int)
    /// Function called when clicking to selecting.
    func didClickSelectedItem(at index: Int)
}

/// The methods adopted by the object you use to manage data and provide segmented items for a `SegmentedView`.
public protocol SegmentedViewDataSource: AnyObject {
    
    /// Whether to enable item width scaling.
    var isItemWidthZoomEnabled: Bool { get }
    /// The selected animation duration.
    var selectedAnimationDuration: TimeInterval { get }
    /// The spacing between items.
    var itemSpacing: CGFloat { get }
    /// Whether to enable item spacing equalization.
    var isItemSpacingEquallyEnabled: Bool { get }
    
    /// Reload the `SegmentedView` data.
    func reloadData(selectedIndex: Int)
    
    /// Returns the data source array. The array elements must be `SegmentedItemModel` or its subclasses.
    ///
    /// - Parameter segmentedView: SegmentedView
    /// - Returns: Array of data sources
    func itemDataSource(in segmentedView: SegmentedView) -> [SegmentedItemModel]
    
    /// Returns the width of the item corresponding to index.
    ///
    /// - Parameters:
    ///   - segmentedView: SegmentedView
    ///   - index: Corresponding index
    ///   - isItemWidthZoomValid: Whether the calculated width needs to be affected by `isItemWidthZoomEnabled`.
    /// - Returns: The width of item
    func segmentedView(_ segmentedView: SegmentedView, widthForItemAt index: Int, isItemWidthZoomValid: Bool) -> CGFloat
    
    /// Register cell class.
    ///
    /// - Parameter segmentedView: SegmentedView
    func registerCellClass(in segmentedView: SegmentedView)
    
    /// Returns the cell corresponding to index
    ///
    /// - Parameters:
    ///   - segmentedView: SegmentedView
    ///   - index: Corresponding index
    /// - Returns: SegmentedItemCell or its subclasses
    func segmentedView(_ segmentedView: SegmentedView, cellForItemAt index: Int) -> SegmentedItemCell
    
    /// Refresh the itemModel of the target index according to the currently selected selectedIndex.
    ///
    /// - Parameters:
    ///   - itemModel: SegmentedItemModel
    ///   - index: Corresponding index
    ///   - selectedIndex: currently selected index
    func refreshItemModel(_ segmentedView: SegmentedView, _ itemModel: SegmentedItemModel, at index: Int, selectedIndex: Int)
    
    /// Call when the item is selected. The currentSelectedItemModel status currently selected needs to be updated to unselected; the status of the willSelectedItemModel to be selected needs to be updated to selected.
    ///
    /// - Parameters:
    ///   - currentSelectedItemModel: The currently selected itemModel
    ///   - willSelectedItemModel: The itemModel to be selected
    ///   - selectedType: Selected type
    func refreshItemModel(_ segmentedView: SegmentedView, currentSelectedItemModel: SegmentedItemModel, willSelectedItemModel: SegmentedItemModel, selectedType: SegmentedViewItemSelectedType)
    
    /// Called when scrolling left or right. Refresh leftItemModel and rightItemModel according to the current percentage from left to right
    ///
    /// - Parameters:
    ///   - leftItemModel: The itemModel with relative position on the left
    ///   - rightItemModel: The itemModel with relative position on the right
    ///   - percentage: Percentage from left to right
    func refreshItemModel(_ segmentedView: SegmentedView, leftItemModel: SegmentedItemModel, rightItemModel: SegmentedItemModel, percentage: CGFloat)
}

/// The methods adopted by the object you use to manage user interactions with items in a `SegmentedView`.
public protocol SegmentedViewDelegate: AnyObject {
    
    /// This method is called when you click to select or scroll to select. It is suitable for situations where you only care about the selection event, not whether it is clicked or scrolled to select.
    ///
    /// - Parameters:
    ///   - segmentedView: SegmentedView
    ///   - index: Selected index
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int)
    
    /// This method will be called only when the selection is clicked.
    ///
    /// - Parameters:
    ///   - segmentedView: SegmentedView
    ///   - index: Selected index
    func segmentedView(_ segmentedView: SegmentedView, didClickSelectedItemAt index: Int)
    
    /// This method is called only when scrolling is selected
    ///
    /// - Parameters:
    ///   - segmentedView: SegmentedView
    ///   - index: Selected index
    func segmentedView(_ segmentedView: SegmentedView, didScrollSelectedItemAt index: Int)
    
    /// This method will be called when scrolling.
    ///
    /// - Parameters:
    ///   - segmentedView: SegmentedView
    ///   - leftIndex: Scrolling, relative position is at the index on the left
    ///   - rightIndex: Scrolling, relative position is at the index on the right
    ///   - percentage: Percentage calculated from left to right
    func segmentedView(_ segmentedView: SegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percentage: CGFloat)
    
    /// Whether it allowed to click on the item of the target index
    ///
    /// - Parameters:
    ///   - segmentedView: SegmentedView
    ///   - index: Target index
    func segmentedView(_ segmentedView: SegmentedView, canClickItemAt index: Int) -> Bool
}

/// The methods adopted by the object you use to manage indicator in a `SegmentedView`.
public protocol SegmentedIndicatorProtocol {
    
    /// Whether the current indicator frame needs to be converted to a cell. This is used to assist the use of the `isTitleMaskEnabled` property of `SegmentedTitleDataSource`.
    ///
    /// If multiple indicators are added, only one indicator can have `isIndicatorConvertToItemFrameEnabled` set to true.
    ///
    /// If `isIndicatorConvertToItemFrameEnabled` is true for multiple indicators, the last indicator whose `isIndicatorConvertToItemFrameEnabled` is true shall prevail.
    var isIndicatorConvertToItemFrameEnabled: Bool { get }
    
    /// Called when the view is reset, the state is updated with the currently selected index.
    ///
    /// - Parameters:
    ///     - configuration: The configuration of indicator
    func refreshIndicatorState(configuration: SegmentedIndicatorConfiguration)
    
    /// When contentScrollView performs a gesture slide, it processes the indicator to follow the gesture change UI logic.
    ///
    /// - Parameters:
    ///     - configuration: The configuration of indicator
    func contentScrollViewDidScroll(configuration: SegmentedIndicatorConfiguration)
    
    /// Click to select an item.
    ///
    /// - Parameters:
    ///     - configuration: The configuration of indicator
    func selectItem(configuration: SegmentedIndicatorConfiguration)
}

/// Model used to describe text type Segment item
public class SegmentedTitleItemModel: SegmentedItemModel {
    
    /// The segment item title text
    public var title: String?
    /// Number of title text lines
    public var titleNumberOfLines: Int = 0
    /// Normal state text color
    public var titleNormalColor: UIColor = .black
    /// Current state text color
    public var titleCurrentColor: UIColor = .black
    /// Selected state text color
    public var titleSelectedColor: UIColor = .systemBlue
    /// Normal state text font
    public var titleNormalFont: UIFont = .systemFont(ofSize: 15)
    /// Selected state text font
    public var titleSelectedFont: UIFont = .systemFont(ofSize: 15)
    /// Whether to enable title zoom scaling
    public var isTitleZoomEnabled: Bool = false
    /// Normal state title zoom scaling
    public var titleNormalZoomScale: CGFloat = 0
    /// Current state title zoom scaling
    public var titleCurrentZoomScale: CGFloat = 0
    /// Selected state title zoom scaling
    public var titleSelectedZoomScale: CGFloat = 0
    /// Whether to enable title stroke width
    public var isTitleStrokeWidthEnabled: Bool = false
    /// Normal state title stroke width
    public var titleNormalStrokeWidth: CGFloat = 0
    /// Current state title stroke width
    public var titleCurrentStrokeWidth: CGFloat = 0
    /// Selected state title stroke width
    public var titleSelectedStrokeWidth: CGFloat = 0
    /// Whether to enable title mask
    public var isTitleMaskEnabled: Bool = false
    /// Width of title
    public var textWidth: CGFloat = 0
}

/// An implementation of the `SegmentedViewDataSource` protocol used to provide text type segments.
public class SegmentedTitleDataSource: SegmentedViewDataSource {
    
    /// Title array in `SegmentedView`.
    public var titles: [String] = []
    
    /// If `SegmentedView` is nested in the cell of UITableView, each time it is reused, `SegmentedView` will recalculate all title widths when reloadingData.
    ///
    /// Therefore, in this application scenario, the cellModel of UITableView needs to cache the text width of titles and then return it to `SegmentedView` through this closure method.
    public var widthForTitleClosure: ((String) -> CGFloat)?
    
    /// Number of title text lines.
    public var titleNumberOfLines: Int = 1
    
    /// Normal state text color.
    public var titleNormalColor: UIColor = .black
    
    /// Selected state text color.
    public var titleSelectedColor: UIColor = .systemBlue
    
    /// Normal state text font.
    public var titleNormalFont: UIFont = .systemFont(ofSize: 15)
    
    /// The font of the title when it is selected.
    /// If no value is assigned, it will default to the same as `titleNormalFont`
    public var titleSelectedFont: UIFont?
    
    /// Whether the title color should be gradually changed
    public var isTitleColorGradientEnabled: Bool = true
    
    /// Whether the title is scaled.
    ///
    /// When using this effect, be sure to ensure that the values of `titleNormalFont` and `titleSelectedFont` are the same.
    public var isTitleZoomEnabled: Bool = false
    
    /// It takes effect only when `isTitleZoomEnabled` is true.
    ///
    /// It is a scaling of the font size.
    ///
    /// For example, if the pointSize of `titleNormalFont` is 10, the font size after enlargement is 10*1.2=12.
    public var titleSelectedZoomScale: CGFloat = 1.2
    
    /// Whether the line width of the title is allowed to be thick or thin.
    ///
    /// When using this effect, be sure to ensure that the values of `titleNormalFont` and `titleSelectedFont` are the same.
    public var isTitleStrokeWidthEnabled: Bool = false
    
    /// Used to control the thickness of the font (implemented through `NSStrokeWidthAttributeName` at the bottom layer).
    /// The smaller the negative number, the thicker the font.
    public var titleSelectedStrokeWidth: CGFloat = -2
    
    /// Whether to use mask transition for title.
    public var isTitleMaskEnabled: Bool = false
    
    /// The data source array passed to `SegmentedView`.
    public var dataSource: [SegmentedTitleItemModel] = []
    
    /// The cell content width is based on the width calculated by the content when it is `SegmentedView.automaticDimension`, otherwise it is based on the specific value of itemContentWidth.
    public var itemContentWidth: CGFloat = SegmentedView.automaticDimension
    
    /// The actual item width = itemContentWidth + itemWidthIncrement.
    public var itemWidthIncrement: CGFloat = 0
    
    /// The spacing between items.
    public var itemSpacing: CGFloat = 20
    
    /// When collectionView.contentSize.width is smaller than the width of `SegmentedView`, whether to divide itemSpacing equally.
    public var isItemSpacingEquallyEnabled: Bool = false
    
    /// Whether to allow gradient when item scrolls left and right, such as `SegmentedTitleDataSource`'s titleZoom, titleNormalColor, titleStrokeWidth, etc.
    public var isItemTransitionEnabled: Bool = true
    
    /// When selected, whether animation transition is required. Custom cells need to handle the animation transition logic by themselves.
    /// For animation processing logic, refer to `SegmentedTitleItemCell`
    public var isSelectedAnimable: Bool = false
    
    /// Select the duration of the animation
    public var selectedAnimationDuration: TimeInterval = 0.25
    
    /// Whether to allow item width to scale
    public var isItemWidthZoomEnabled: Bool = false
    
    /// Item width scaling when selected
    public var itemWidthSelectedZoomScale: CGFloat = 1.5
    
    /// Selected animator
    private var animator: SegmentedAnimator?
    
    /// Initializer
    public init() { }
    
    /// After configuring various properties, you need to manually call this method to update the data source
    ///
    /// - Parameter selectedIndex: Currently selected index
    public func reloadData(selectedIndex: Int) {
        self.dataSource.removeAll()
        
        for index in self.titles.indices {
            let itemModel = SegmentedTitleItemModel()
            self.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)
            self.dataSource.append(itemModel)
        }
    }
    
    
    // MARK: - SegmentedViewDataSource
    public func itemDataSource(in segmentedView: SegmentedView) -> [SegmentedItemModel] {
        return self.dataSource
    }
    
    public final func segmentedView(
        _ segmentedView: SegmentedView,
        widthForItemAt index: Int,
        isItemWidthZoomValid: Bool
    ) -> CGFloat {
        let itemWidth = self.preferredSegmentedView(segmentedView, widthForItemAt: index)
        if self.isItemWidthZoomEnabled && isItemWidthZoomValid {
            return itemWidth * self.dataSource[index].itemWidthCurrentZoomScale
        } else {
            return itemWidth
        }
    }
    
    public func registerCellClass(in segmentedView: SegmentedView) {
        segmentedView.collectionView.register(SegmentedTitleItemCell.self, forCellWithReuseIdentifier: "cell")
    }
    
    public func segmentedView(_ segmentedView: SegmentedView, cellForItemAt index: Int) -> SegmentedItemCell {
        return segmentedView.dequeueReusableCell(withReuseIdentifier: "cell", at: index)
    }
    
    public func refreshItemModel(
        _ segmentedView: SegmentedView,
        currentSelectedItemModel: SegmentedItemModel,
        willSelectedItemModel: SegmentedItemModel,
        selectedType: SegmentedViewItemSelectedType
    ) {
        currentSelectedItemModel.isSelected = false
        willSelectedItemModel.isSelected = true
        
        if self.isItemWidthZoomEnabled {
            if (selectedType == .scrolling && !self.isItemTransitionEnabled) ||
                selectedType == .clicking ||
                selectedType == .programmatically {
                self.animator = SegmentedAnimator()
                self.animator?.duration = self.selectedAnimationDuration
                self.animator?.progressClosure = {[weak self] percentage in
                    currentSelectedItemModel.itemWidthCurrentZoomScale = interpolate(
                        from: currentSelectedItemModel.itemWidthSelectedZoomScale,
                        to: currentSelectedItemModel.itemWidthNormalZoomScale,
                        percentage: percentage
                    )
                    currentSelectedItemModel.itemWidth = self?.segmentedView(
                        segmentedView,
                        widthForItemAt: currentSelectedItemModel.index,
                        isItemWidthZoomValid: true
                    ) ?? 0
                    willSelectedItemModel.itemWidthCurrentZoomScale = interpolate(
                        from: willSelectedItemModel.itemWidthNormalZoomScale,
                        to: willSelectedItemModel.itemWidthSelectedZoomScale,
                        percentage: percentage
                    )
                    willSelectedItemModel.itemWidth = self?.segmentedView(
                        segmentedView,
                        widthForItemAt: willSelectedItemModel.index,
                        isItemWidthZoomValid: true
                    ) ?? 0
                    segmentedView.collectionView.collectionViewLayout.invalidateLayout()
                }
                self.animator?.start()
            }
        } else {
            currentSelectedItemModel.itemWidthCurrentZoomScale = currentSelectedItemModel.itemWidthNormalZoomScale
            willSelectedItemModel.itemWidthCurrentZoomScale = willSelectedItemModel.itemWidthSelectedZoomScale
        }
        
        guard let currentSelectedModel = currentSelectedItemModel as? SegmentedTitleItemModel,
              let willSelectedModel = willSelectedItemModel as? SegmentedTitleItemModel else {
            return
        }
        
        currentSelectedModel.titleCurrentColor = currentSelectedModel.titleNormalColor
        currentSelectedModel.titleCurrentZoomScale = currentSelectedModel.titleNormalZoomScale
        currentSelectedModel.titleCurrentStrokeWidth = currentSelectedModel.titleNormalStrokeWidth
        currentSelectedModel.indicatorConvertToItemFrame = .zero
        
        willSelectedModel.titleCurrentColor = willSelectedModel.titleSelectedColor
        willSelectedModel.titleCurrentZoomScale = willSelectedModel.titleSelectedZoomScale
        willSelectedModel.titleCurrentStrokeWidth = willSelectedModel.titleSelectedStrokeWidth
    }
    
    public func refreshItemModel(
        _ segmentedView: SegmentedView,
        leftItemModel: SegmentedItemModel,
        rightItemModel: SegmentedItemModel,
        percentage: CGFloat
    ) {
        /// If the itemWidth scaling animation is in progress and the user immediately scrolls the contentScrollView, the animation needs to be stopped.
        self.animator?.stop()
        if self.isItemWidthZoomEnabled && self.isItemTransitionEnabled {
            // Allow itemWidth scaling animation and item gradient transition
            leftItemModel.itemWidthCurrentZoomScale = interpolate(
                from: leftItemModel.itemWidthSelectedZoomScale,
                to: leftItemModel.itemWidthNormalZoomScale,
                percentage: percentage
            )
            leftItemModel.itemWidth = self.segmentedView(
                segmentedView,
                widthForItemAt: leftItemModel.index,
                isItemWidthZoomValid: true
            )
            rightItemModel.itemWidthCurrentZoomScale = interpolate(
                from: rightItemModel.itemWidthNormalZoomScale,
                to: rightItemModel.itemWidthSelectedZoomScale,
                percentage: percentage
            )
            rightItemModel.itemWidth = self.segmentedView(
                segmentedView,
                widthForItemAt: rightItemModel.index,
                isItemWidthZoomValid: true
            )
            segmentedView.collectionView.collectionViewLayout.invalidateLayout()
        }
        guard let leftModel = leftItemModel as? SegmentedTitleItemModel,
              let rightModel = rightItemModel as? SegmentedTitleItemModel else {
            return
        }
        if self.isTitleZoomEnabled && self.isItemTransitionEnabled {
            leftModel.titleCurrentZoomScale = interpolate(
                from: leftModel.titleSelectedZoomScale,
                to: leftModel.titleNormalZoomScale,
                percentage: percentage
            )
            rightModel.titleCurrentZoomScale = interpolate(
                from: rightModel.titleNormalZoomScale,
                to: rightModel.titleSelectedZoomScale,
                percentage: percentage
            )
        }
        
        if self.isTitleStrokeWidthEnabled && self.isItemTransitionEnabled {
            leftModel.titleCurrentStrokeWidth = interpolate(
                from: leftModel.titleSelectedStrokeWidth,
                to: leftModel.titleNormalStrokeWidth,
                percentage: percentage
            )
            rightModel.titleCurrentStrokeWidth = interpolate(
                from: rightModel.titleNormalStrokeWidth,
                to: rightModel.titleSelectedStrokeWidth,
                percentage: percentage
            )
        }
        
        if self.isTitleColorGradientEnabled && self.isItemTransitionEnabled {
            leftModel.titleCurrentColor = interpolateColor(
                from: leftModel.titleSelectedColor,
                to: leftModel.titleNormalColor,
                percentage: percentage
            )
            rightModel.titleCurrentColor = interpolateColor(
                from: rightModel.titleNormalColor,
                to: rightModel.titleSelectedColor,
                percentage: percentage
            )
        }
    }
    
    public func refreshItemModel(_ segmentedView: SegmentedView, _ itemModel: SegmentedItemModel, at index: Int, selectedIndex: Int) {
        guard let itemModel = itemModel as? SegmentedTitleItemModel else {
            return
        }
        self.preferredRefreshItemModel(itemModel, at: index, selectedIndex: selectedIndex)
    }
    
    private func preferredRefreshItemModel(
        _ itemModel: SegmentedTitleItemModel,
        at index: Int,
        selectedIndex: Int
    ) {
        itemModel.index = index
        itemModel.isItemTransitionEnabled = self.isItemTransitionEnabled
        itemModel.isSelectedAnimable = self.isSelectedAnimable
        itemModel.selectedAnimationDuration = self.selectedAnimationDuration
        itemModel.isItemWidthZoomEnabled = self.isItemWidthZoomEnabled
        itemModel.itemWidthNormalZoomScale = 1
        itemModel.itemWidthSelectedZoomScale = self.itemWidthSelectedZoomScale
        
        itemModel.title = self.titles[index]
        itemModel.textWidth = self.widthForItem(title: itemModel.title ?? "")
        itemModel.titleNumberOfLines = self.titleNumberOfLines
        itemModel.titleNormalColor = self.titleNormalColor
        itemModel.titleSelectedColor = self.titleSelectedColor
        itemModel.titleNormalFont = self.titleNormalFont
        if let selectedFont = self.titleSelectedFont {
            itemModel.titleSelectedFont = selectedFont
        } else {
            itemModel.titleSelectedFont = self.titleNormalFont
        }
        itemModel.isTitleZoomEnabled = self.isTitleZoomEnabled
        itemModel.isTitleStrokeWidthEnabled = self.isTitleStrokeWidthEnabled
        itemModel.isTitleMaskEnabled = self.isTitleMaskEnabled
        itemModel.titleNormalZoomScale = 1
        itemModel.titleSelectedZoomScale = self.titleSelectedZoomScale
        itemModel.titleSelectedStrokeWidth = self.titleSelectedStrokeWidth
        itemModel.titleNormalStrokeWidth = 0
        
        if index == selectedIndex {
            itemModel.isSelected = true
            itemModel.itemWidthCurrentZoomScale = itemModel.itemWidthSelectedZoomScale
            itemModel.titleCurrentColor = self.titleSelectedColor
            itemModel.titleCurrentZoomScale = self.titleSelectedZoomScale
            itemModel.titleCurrentStrokeWidth = self.titleSelectedStrokeWidth
        } else {
            itemModel.isSelected = false
            itemModel.itemWidthCurrentZoomScale = itemModel.itemWidthNormalZoomScale
            itemModel.titleCurrentColor = self.titleNormalColor
            itemModel.titleCurrentZoomScale = 1
            itemModel.titleCurrentStrokeWidth = 0
        }
    }
    
    private func widthForItem(title: String) -> CGFloat {
        if let closure = self.widthForTitleClosure {
            return closure(title)
        } else {
            let textWidth = title.calculateSize(font: self.titleNormalFont).width
            return CGFloat(ceil(textWidth))
        }
    }
    
    private func preferredSegmentedView(
        _ segmentedView: SegmentedView,
        widthForItemAt index: Int
    ) -> CGFloat {
        var itemWidth = self.itemWidthIncrement
        if itemContentWidth == SegmentedView.automaticDimension {
            itemWidth += self.dataSource[index].textWidth
        } else {
            itemWidth += self.itemContentWidth
        }
        return itemWidth
    }
    
    deinit {
        self.widthForTitleClosure = nil
        self.animator?.stop()
    }
}

/// The CollectionView inside the `SegmentedView` is responsible for horizontal scrolling, which holds indicators inside. Each of its cells holds a vertical list view at the bottom.
public class SegmentedCollectionView: UICollectionView {
    
    /// The indicators in the `SegmentedView`.
    public var indicators = [SegmentedIndicatorProtocol & UIView]() {
        willSet {
            for indicator in self.indicators {
                indicator.removeFromSuperview()
            }
        }
        didSet {
            for indicator in self.indicators {
                self.addSubview(indicator)
            }
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        for indicator in self.indicators {
            self.sendSubviewToBack(indicator)
        }
    }
}

/// Class for managing Sgemented Item.
public class SegmentedItemModel {
    
    /// The index of the current item
    public var index: Int = 0
    /// Whether the current item is selected
    public var isSelected: Bool = false
    /// The width of the current item
    public var itemWidth: CGFloat = 0
    /// Indicator view frame transitions to cell
    public var indicatorConvertToItemFrame: CGRect = .zero
    /// Whether to enable transition
    public var isItemTransitionEnabled: Bool = true
    /// Whether to enable animation selection
    public var isSelectedAnimable: Bool = false
    /// Select the duration of the animation
    public var selectedAnimationDuration: TimeInterval = 0
    /// Whether the transition animation in progress
    public var isTransitionAnimating: Bool = false
    /// Whether to enable item width scaling.
    public var isItemWidthZoomEnabled: Bool = false
    /// Item width normal scaling ratio
    public var itemWidthNormalZoomScale: CGFloat = 0
    /// Item width current scaling ratio
    public var itemWidthCurrentZoomScale: CGFloat = 0
    /// Item width selected scaling ratio
    public var itemWidthSelectedZoomScale: CGFloat = 0
    
    /// Initializer
    public init() { }
}

/// Segmented item base cell
public class SegmentedItemCell: UICollectionViewCell {
    
    /// Selected animation closure
    public typealias SelectedAnimationAction = ((CGFloat) -> Void)
    
    /// The model of the current cell
    public var itemModel: SegmentedItemModel?
    /// The animator of the current cell
    public var animator: SegmentedAnimator?
    
    private var selectedAnimationActions: [SelectedAnimationAction] = []
    
    /// Initializer
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        
        self.animator?.stop()
    }
    
    public func setup() { }
    
    /// Whether it possible to perform selection animation
    /// - Parameters:
    ///   - itemModel: The item model
    ///   - selectedType: Selected type
    /// - Returns: Whether it possible
    public func canStartSelectedAnimation(
        itemModel: SegmentedItemModel,
        selectedType: SegmentedViewItemSelectedType
    ) -> Bool {
        var isSelectedAnimatable = false
        if itemModel.isSelectedAnimable {
            if selectedType == .scrolling {
                // Scroll selection and no left-right transition, animation is allowed
                if !itemModel.isItemTransitionEnabled {
                    isSelectedAnimatable = true
                }
            } else if selectedType == .clicking || selectedType == .programmatically {
                // Click or programmatic selection, allow animation
                isSelectedAnimatable = true
            }
        }
        return isSelectedAnimatable
    }
    
    /// Add select animation action closure
    ///
    /// - Parameters:
    ///     - action: SelectedAnimationAction
    public func appendSelectedAnimationAction(_ action: @escaping SelectedAnimationAction) {
        self.selectedAnimationActions.append(action)
    }
    
    /// Start selecting animation, if allowed
    ///
    /// - Parameters:
    ///   - itemModel: The item model
    ///   - selectedType: Selected type
    public func startSelectedAnimationIfNeeded(
        itemModel: SegmentedItemModel,
        selectedType: SegmentedViewItemSelectedType
    ) {
        if itemModel.isSelectedAnimable && self.canStartSelectedAnimation(
            itemModel: itemModel,
            selectedType: selectedType
        ) {
            // Need to update isTransitionAnimating, which is used to prevent response clicks when filtering to avoid interface abnormalities.。
            itemModel.isTransitionAnimating = true
            self.animator?.progressClosure = { [weak self] percentage in
                guard let self else { return }
                for action in self.selectedAnimationActions {
                    action(percentage)
                }
            }
            self.animator?.completedClosure = { [weak self] in
                itemModel.isTransitionAnimating = false
                self?.selectedAnimationActions.removeAll()
            }
            self.animator?.start()
        }
    }
    
    /// Reload the item data
    /// - Parameters:
    ///   - itemModel: The item model
    ///   - selectedType: Selected type
    public func reloadData(itemModel: SegmentedItemModel, selectedType: SegmentedViewItemSelectedType) {
        self.itemModel = itemModel
        
        if itemModel.isSelectedAnimable {
            self.selectedAnimationActions.removeAll()
            if self.canStartSelectedAnimation(
                itemModel: itemModel,
                selectedType: selectedType
            ) {
                self.animator = SegmentedAnimator()
                self.animator?.duration = itemModel.selectedAnimationDuration
            } else {
                self.animator?.stop()
            }
        }
    }
    
    deinit {
        self.animator?.stop()
    }
}

/// Segmented title item cell.
public class SegmentedTitleItemCell: SegmentedItemCell {
    
    /// The title label
    public let titleLabel = UILabel()
    /// The mask title title label
    public let maskTitleLabel = UILabel()
    /// The title mask layer
    public let titleMaskLayer = CALayer()
    /// The mask title mask layer
    public let maskTitleMaskLayer = CALayer()
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        /// Why use `sizeThatFits` instead of `sizeToFit`?
        ///
        /// When numberOfLines is greater than 0, the label is set to the wrong size through `sizeToFit` when the cell is reused.
        ///
        /// As for the reason, using `sizeThatFits` can avoid this problem.
        let labelSize = self.titleLabel.sizeThatFits(self.contentView.bounds.size)
        let labelBounds = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
        self.titleLabel.bounds = labelBounds
        self.titleLabel.center = self.contentView.center
        
        self.maskTitleLabel.bounds = labelBounds
        self.maskTitleLabel.center = self.contentView.center
    }
    
    public override func setup() {
        super.setup()
        
        self.titleLabel.textAlignment = .center
        self.contentView.addSubview(self.titleLabel)
        
        self.maskTitleLabel.textAlignment = .center
        self.maskTitleLabel.isHidden = true
        self.contentView.addSubview(self.maskTitleLabel)
        
        self.titleMaskLayer.backgroundColor = UIColor.red.cgColor
        
        self.maskTitleMaskLayer.backgroundColor = UIColor.red.cgColor
        self.maskTitleLabel.layer.mask = self.maskTitleMaskLayer
    }
    
    public override func reloadData(itemModel: SegmentedItemModel, selectedType: SegmentedViewItemSelectedType) {
        super.reloadData(itemModel: itemModel, selectedType: selectedType )
        
        guard let model = itemModel as? SegmentedTitleItemModel else {
            return
        }
        
        self.titleLabel.numberOfLines = model.titleNumberOfLines
        self.maskTitleLabel.numberOfLines = model.titleNumberOfLines
        
        if model.isTitleZoomEnabled {
            /// First set the font to the maximum value of the scale, then reduce it to the minimum value, and finally update the scale according to the current `titleCurrentZoomScale` value.
            /// This will avoid font blur when transforming from small to large.
            let maxScaleFont = UIFont(
                descriptor: model.titleNormalFont.fontDescriptor,
                size: model.titleNormalFont.pointSize * CGFloat(model.titleSelectedZoomScale)
            )
            let baseScale = model.titleNormalFont.lineHeight / max(maxScaleFont.lineHeight, 1)
            
            if model.isSelectedAnimable && self.canStartSelectedAnimation(itemModel: itemModel, selectedType: selectedType) {
                // Allow animation and currently click
                let aciton = self.preferredTitleZoomAnimationAction(
                    itemModel: model,
                    baseScale: baseScale
                )
                self.appendSelectedAnimationAction(aciton)
            } else {
                self.titleLabel.font = maxScaleFont
                self.maskTitleLabel.font = maxScaleFont
                let currentTransform = CGAffineTransform(
                    scaleX: baseScale * CGFloat(model.titleCurrentZoomScale),
                    y: baseScale * CGFloat(model.titleCurrentZoomScale)
                )
                self.titleLabel.transform = currentTransform
                self.maskTitleLabel.transform = currentTransform
            }
        } else {
            if model.isSelected {
                self.titleLabel.font = model.titleSelectedFont
                self.maskTitleLabel.font = model.titleSelectedFont
            } else {
                self.titleLabel.font = model.titleNormalFont
                self.maskTitleLabel.font = model.titleNormalFont
            }
        }
        
        let title = model.title ?? ""
        let attrText = NSMutableAttributedString(string: title)
        if model.isTitleStrokeWidthEnabled {
            if model.isSelectedAnimable && self.canStartSelectedAnimation(
                itemModel: itemModel,
                selectedType: selectedType
            ) {
                // Allow animation and currently click
                let action = preferredTitleStrokeWidthAnimationAction(
                    itemModel: model,
                    attriText: attrText
                )
                self.appendSelectedAnimationAction(action)
            } else {
                attrText.addAttributes(
                    [NSAttributedString.Key.strokeWidth: model.titleCurrentStrokeWidth],
                    range: NSRange(location: 0, length: title.count)
                )
                self.titleLabel.attributedText = attrText
                self.maskTitleLabel.attributedText = attrText
            }
        } else {
            self.titleLabel.attributedText = attrText
            self.maskTitleLabel.attributedText = attrText
        }
        
        if model.isTitleMaskEnabled {
            /// Allow mask, maskTitleLabel is above titleLabel, maskTitleLabel is set to titleSelectedColor.
            /// titleLabel is set to `titleNormalColor`. To show the effect, double mask is used.
            /// That is, titleMaskLayer masks titleLabel, maskTitleMaskLayer masks maskTitleLabel.
            self.maskTitleLabel.isHidden = false
            self.titleLabel.textColor = model.titleNormalColor
            self.maskTitleLabel.textColor = model.titleSelectedColor
            let labelSize = self.maskTitleLabel.sizeThatFits(self.contentView.bounds.size)
            let labelBounds = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
            self.maskTitleLabel.bounds = labelBounds
            
            var topMaskFrame = model.indicatorConvertToItemFrame
            topMaskFrame.origin.y = 0
            var bottomMaskFrame = topMaskFrame
            var maskStartX: CGFloat = 0
            if self.maskTitleLabel.bounds.width >= self.bounds.width {
                topMaskFrame.origin.x -= (self.maskTitleLabel.bounds.width - self.bounds.width) / 2
                bottomMaskFrame.size.width = self.maskTitleLabel.bounds.width
                maskStartX = -(self.maskTitleLabel.bounds.width - bounds.width) / 2
            } else {
                topMaskFrame.origin.x -= (self.bounds.width - self.maskTitleLabel.bounds.width) / 2
                bottomMaskFrame.size.width = self.bounds.width
                maskStartX = 0
            }
            bottomMaskFrame.origin.x = topMaskFrame.origin.x
            if topMaskFrame.origin.x > maskStartX {
                bottomMaskFrame.origin.x = topMaskFrame.origin.x - bottomMaskFrame.width
            } else {
                bottomMaskFrame.origin.x = topMaskFrame.maxX
            }
            
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            if topMaskFrame.width > 0 && topMaskFrame.intersects(self.maskTitleLabel.frame) {
                self.titleLabel.layer.mask = self.titleMaskLayer
                self.titleMaskLayer.frame = bottomMaskFrame
                self.maskTitleMaskLayer.frame = topMaskFrame
            } else {
                self.titleLabel.layer.mask = nil
                self.maskTitleMaskLayer.frame = topMaskFrame
            }
            CATransaction.commit()
        } else {
            self.maskTitleLabel.isHidden = true
            self.titleLabel.layer.mask = nil
            if model.isSelectedAnimable && self.canStartSelectedAnimation(
                itemModel: itemModel,
                selectedType: selectedType
            ) {
                // Allow animation and currently click
                let action = self.preferredTitleColorAnimationAction(itemModel: model)
                self.appendSelectedAnimationAction(action)
            } else {
                self.titleLabel.textColor = model.titleCurrentColor
            }
        }
        
        self.startSelectedAnimationIfNeeded(itemModel: itemModel, selectedType: selectedType)
        self.setNeedsLayout()
    }
    
    /// Title zoom animation
    public func preferredTitleZoomAnimationAction(
        itemModel: SegmentedTitleItemModel,
        baseScale: CGFloat
    ) -> SelectedAnimationAction {
        return { [weak self] percentage in
            if itemModel.isSelected {
                // Will be selected, scale interpolated gradually from small to large
                itemModel.titleCurrentZoomScale = interpolate(
                    from: itemModel.titleNormalZoomScale,
                    to: itemModel.titleSelectedZoomScale,
                    percentage: percentage
                )
            } else {
                // To be unchecked, scale interpolated gradually from large to small
                itemModel.titleCurrentZoomScale = interpolate(
                    from: itemModel.titleSelectedZoomScale,
                    to: itemModel.titleNormalZoomScale,
                    percentage: percentage
                )
            }
            let currentTransform = CGAffineTransform(
                scaleX: baseScale*itemModel.titleCurrentZoomScale,
                y: baseScale*itemModel.titleCurrentZoomScale
            )
            self?.titleLabel.transform = currentTransform
            self?.maskTitleLabel.transform = currentTransform
        }
    }
    
    /// Title stroke animation
    public func preferredTitleStrokeWidthAnimationAction(
        itemModel: SegmentedTitleItemModel,
        attriText: NSMutableAttributedString
    ) -> SelectedAnimationAction {
        return { [weak self] percentage in
            if itemModel.isSelected {
                // Will be selected, StrokeWidth interpolated gradually from small to large
                itemModel.titleCurrentStrokeWidth = interpolate(
                    from: itemModel.titleNormalStrokeWidth,
                    to: itemModel.titleSelectedStrokeWidth,
                    percentage: percentage
                )
            } else {
                // To be unchecked, StrokeWidth interpolated gradually from large to small
                itemModel.titleCurrentStrokeWidth = interpolate(
                    from: itemModel.titleSelectedStrokeWidth,
                    to: itemModel.titleNormalStrokeWidth,
                    percentage: percentage
                )
            }
            attriText.addAttributes(
                [NSAttributedString.Key.strokeWidth: itemModel.titleCurrentStrokeWidth],
                range: NSRange(location: 0, length: attriText.string.count)
            )
            self?.titleLabel.attributedText = attriText
            self?.maskTitleLabel.attributedText = attriText
        }
    }
    
    /// Title color animation
    public func preferredTitleColorAnimationAction(itemModel: SegmentedTitleItemModel) -> SelectedAnimationAction {
        return { [weak self] percentage in
            if itemModel.isSelected {
                /// When it is about to be selected, the textColor interpolates from `titleNormalColor` to `titleSelectedColor`.
                itemModel.titleCurrentColor = interpolateColor(
                    from: itemModel.titleNormalColor,
                    to: itemModel.titleSelectedColor,
                    percentage: percentage
                )
            } else {
                /// When the selection is about to be cancelled, the textColor will be interpolated from `titleSelectedColor` to `titleNormalColor`.
                itemModel.titleCurrentColor = interpolateColor(
                    from: itemModel.titleSelectedColor,
                    to: itemModel.titleNormalColor,
                    percentage: percentage
                )
            }
            self?.titleLabel.textColor = itemModel.titleCurrentColor
        }
    }
}

/// The configuration of the indicator will assign different attributes in different situations. Please confirm according to the API instructions in different situations.
public class SegmentedIndicatorConfiguration {
    
    /// The contentSize of collectionView
    public var contentSize: CGSize = CGSize.zero
    /// Currently selected index
    public var currentSelectedIndex: Int = 0
    /// The currently selected cellFrame
    public var currentSelectedItemFrame: CGRect = CGRect.zero
    /// The two cells being transitioned, relative to the index of the cell on the left
    public var leftIndex: Int = 0
    /// The two cells being transitioned are relative to the frame of the cell on the left.
    public var leftItemFrame: CGRect = CGRect.zero
    /// The index of the cell on the right relative to the two cells being transitioned
    public var rightIndex: Int = 0
    /// The two cells being transitioned are relative to the frame of the cell on the right.
    public var rightItemFrame: CGRect = CGRect.zero
    /// The percentage of the two cells being transitioned from left to right
    public var percentage: CGFloat = 0
    /// Previously selected index
    public var lastSelectedIndex: Int = 0
    /// Selected Type
    public var selectedType: SegmentedViewItemSelectedType = .unselected
    
    public init() { }
}

/// The indicator base implementation class.
public class SegmentedIndicatorView: UIView, SegmentedIndicatorProtocol {
    
    /// The default is `SegmentedView.automaticDimension` (equal to the cell width).
    /// The actual value is obtained internally through the getIndicatorWidth method
    public var indicatorWidth: CGFloat = SegmentedView.automaticDimension
    
    /// The width increment of the indicator.
    /// For example, if the indicator width is 10 points greater than the cell width, then this property can be assigned a value of 10.
    /// The final indicator width = indicatorWidth + indicatorWidthIncrement.
    public var indicatorWidthIncrement: CGFloat = 0
    
    /// The default value is `SegmentedView.automaticDimension` (equal to the height of the cell).
    /// The actual value is obtained internally through the getIndicatorHeight method.
    public var indicatorHeight: CGFloat = SegmentedView.automaticDimension
    
    /// The default is `SegmentedView.automaticDimension` (equal to indicatorHeight / 2).
    /// The actual value is obtained internally through the getIndicatorCornerRadius method.
    public var indicatorCornerRadius: CGFloat = SegmentedView.automaticDimension
    
    /// Color of indicator
    public var indicatorColor: UIColor = .systemBlue
    
    /// The position of the indicator, top or bottom.
    public var indicatorPosition: SegmentedIndicatorPosition = .bottom
    
    /// Vertical offset. The indicator is attached to the bottom or top by default.
    /// The larger the verticalOffset, the closer it is to the center.
    public var verticalOffset: CGFloat = 0
    
    /// Whether scrolling is allowed when gesture scrolling or clicking to switch.
    public var isScrollEnabled: Bool = true
    
    /// Whether the frame of the current indicator needs to be converted to the cell.
    ///
    /// Used to assist the isTitleMaskEnabled property of `SegmentedTitleDataSource`.
    ///
    /// If multiple indicators are added, only one indicator can have `isIndicatorConvertToItemFrameEnabled` set to true.
    ///
    /// If multiple indicators have `isIndicatorConvertToItemFrameEnabled` set to true, the last indicator with `isIndicatorConvertToItemFrameEnabled` set to true will prevail.
    public var isIndicatorConvertToItemFrameEnabled: Bool = true
    
    /// Click the scroll animation duration when selected.
    public var scrollAnimationDuration: TimeInterval = 0.25
    
    /// Initializer
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Setup
    public func setup() { }
    
    /// Function to get the actual corner radius.
    public func getIndicatorCornerRadius(itemFrame: CGRect) -> CGFloat {
        if self.indicatorCornerRadius == SegmentedView.automaticDimension {
            return self.getIndicatorHeight(itemFrame: itemFrame) / 2
        }
        return self.indicatorCornerRadius
    }
    
    /// Function to get the actual width.
    public func getIndicatorWidth(itemFrame: CGRect) -> CGFloat {
        if self.indicatorWidth == SegmentedView.automaticDimension {
            return itemFrame.width + indicatorWidthIncrement
        }
        return self.indicatorWidth + self.indicatorWidthIncrement
    }
    
    /// Function to get the actual height.
    public func getIndicatorHeight(itemFrame: CGRect) -> CGFloat {
        if self.indicatorHeight == SegmentedView.automaticDimension {
            return itemFrame.height
        }
        return self.indicatorHeight
    }
    
    // MARK: - SegmentedIndicatorProtocol
    public func refreshIndicatorState(configuration: SegmentedIndicatorConfiguration) { }
    
    public func contentScrollViewDidScroll(configuration: SegmentedIndicatorConfiguration) { }
    
    public func selectItem(configuration: SegmentedIndicatorConfiguration) { }
}

/// Linear style indicator view.
public class SegmentedIndicatorLineView: SegmentedIndicatorView {
    
    /// The line style of indicator.
    public var lineStyle: SegmentedIndicatorLineStyle = .normal
    
    /// Used when lineStyle is lengthenOffset, the x offset when scrolling.
    public var lineScrollOffsetX: CGFloat = 10
    
    public override func setup() {
        super.setup()
        
        self.indicatorHeight = 3
    }
    
    public override func refreshIndicatorState(configuration: SegmentedIndicatorConfiguration) {
        super.refreshIndicatorState(configuration: configuration)
        
        self.backgroundColor = self.indicatorColor
        self.layer.cornerRadius = self.getIndicatorCornerRadius(
            itemFrame: configuration.currentSelectedItemFrame
        )
        let width = self.getIndicatorWidth(
            itemFrame: configuration.currentSelectedItemFrame
        )
        let height = self.getIndicatorHeight(
            itemFrame: configuration.currentSelectedItemFrame
        )
        let originX = configuration.currentSelectedItemFrame.minX + (configuration.currentSelectedItemFrame.width - width) / 2
        var originY = configuration.currentSelectedItemFrame.height - height - self.verticalOffset
        if self.indicatorPosition == .top {
            originY = self.verticalOffset
        }
        self.frame = CGRect(x: originX, y: originY, width: width, height: height)
    }
    
    public override func contentScrollViewDidScroll(configuration: SegmentedIndicatorConfiguration) {
        super.contentScrollViewDidScroll(configuration: configuration)
        
        if configuration.percentage == 0 || !self.isScrollEnabled {
            /// When configuration.percentage is equal to 0, no processing is required.
            /// The `selectItem(configuration:)` method will be called to process.
            /// If `isScrollEnabled` is false, no processing is required.
            return
        }
        
        let rightItemFrame = configuration.rightItemFrame
        let leftItemFrame = configuration.leftItemFrame
        let percentage = configuration.percentage
        var targetX: CGFloat = leftItemFrame.origin.x
        var targetWidth = getIndicatorWidth(itemFrame: leftItemFrame)
        
        let leftWidth = targetWidth
        let rightWidth = getIndicatorWidth(itemFrame: rightItemFrame)
        let leftX = leftItemFrame.origin.x + (leftItemFrame.width - leftWidth) / 2
        let rightX = rightItemFrame.origin.x + (rightItemFrame.width - rightWidth) / 2
        
        switch self.lineStyle {
        case .normal:
            targetX = interpolate(
                from: leftX,
                to: rightX,
                percentage: percentage
            )
            if indicatorWidth == SegmentedView.automaticDimension {
                targetWidth = interpolate(
                    from: leftWidth,
                    to: rightWidth,
                    percentage: percentage
                )
            }
            
        case .lengthen:
            // For the first 50%, only width is increased; for the second 50%, x is moved and width is decreased.
            let maxWidth = rightX - leftX + rightWidth
            if percentage <= 0.5 {
                targetX = leftX
                targetWidth = interpolate(
                    from: leftWidth,
                    to: maxWidth,
                    percentage: percentage * 2
                )
            } else {
                targetX = interpolate(
                    from: leftX,
                    to: rightX,
                    percentage: CGFloat((percentage - 0.5) * 2)
                )
                targetWidth = interpolate(
                    from: maxWidth,
                    to: rightWidth,
                    percentage: CGFloat((percentage - 0.5) * 2)
                )
            }
            
        case .lengthenOffset:
            // For the first 50%, increase width and move x a little bit; for the second 50%, move x a little bit and reduce width.
            let maxWidth = rightX - leftX + rightWidth - lineScrollOffsetX * 2
            if percentage <= 0.5 {
                targetX = interpolate(
                    from: leftX,
                    to: leftX + self.lineScrollOffsetX,
                    percentage: CGFloat(percentage * 2)
                )
                targetWidth = interpolate(
                    from: leftWidth,
                    to: maxWidth,
                    percentage: CGFloat(percentage * 2)
                )
            } else {
                targetX = interpolate(
                    from:leftX + self.lineScrollOffsetX,
                    to: rightX,
                    percentage: CGFloat((percentage - 0.5) * 2)
                )
                targetWidth = interpolate(
                    from: maxWidth,
                    to: rightWidth,
                    percentage: CGFloat((percentage - 0.5) * 2)
                )
            }
        }
        
        self.frame.origin.x = targetX
        self.frame.size.width = targetWidth
    }
    
    public override func selectItem(configuration: SegmentedIndicatorConfiguration) {
        super.selectItem(configuration: configuration)
        
        let targetWidth = self.getIndicatorWidth(
            itemFrame: configuration.currentSelectedItemFrame
        )
        var toFrame = self.frame
        toFrame.origin.x = configuration.currentSelectedItemFrame.origin.x +
        (configuration.currentSelectedItemFrame.width - targetWidth) / 2
        toFrame.size.width = targetWidth
        if self.isScrollEnabled &&
            (configuration.selectedType == .clicking || configuration.selectedType == .programmatically) {
            // Allow scrolling and select type is click or code selection, then animation transition will be performed
            UIView.animate(
                withDuration: self.scrollAnimationDuration,
                delay: 0,
                options: .curveEaseOut,
                animations: {
                    self.frame = toFrame
                }
            )
        } else {
            frame = toFrame
        }
    }
}

/// Segmented item animator.
public class SegmentedAnimator {
    
    /// The animation duration
    public var duration: TimeInterval = 0.25
    /// Progress callback
    public var progressClosure: ((CGFloat) -> Void)?
    /// Completed callback
    public var completedClosure: (() -> Void)?
    
    private var displayLink: CADisplayLink!
    private var firstTimestamp: CFTimeInterval?
    
    /// Initializer
    public init() {
        self.displayLink = CADisplayLink(
            target: self,
            selector: #selector(processDisplayLink(sender:))
        )
    }
    
    /// Start the animation
    public func start() {
        self.displayLink.add(to: RunLoop.main, forMode: RunLoop.Mode.common)
    }
    
    /// Stop the animation
    public func stop() {
        self.progressClosure?(1)
        self.displayLink.invalidate()
        self.completedClosure?()
    }
    
    @objc
    private func processDisplayLink(sender: CADisplayLink) {
        if self.firstTimestamp == nil {
            self.firstTimestamp = sender.timestamp
        }
        guard let timestamp = self.firstTimestamp, self.duration > 0 else {
            return
        }
        let percent = (sender.timestamp - timestamp) / self.duration
        if percent >= 1 {
            self.progressClosure?(1)
            self.displayLink.invalidate()
            self.completedClosure?()
        } else {
            self.progressClosure?(CGFloat(percent))
        }
    }
    
    deinit {
        self.progressClosure = nil
        self.completedClosure = nil
    }
}

/// A protocol representing a list embedded in a `SegmentedView` view.
public protocol SegmentedViewListProtocol: AnyObject {
    
    /// Returns listView. If it is wrapped by `UIViewController`, it's view, if it is wrapped by a custom view, it is the custom view itself.
    func listView() -> UIView
    
    /// Life Cycle Method: Called when the listView will be appear.`.
    func listWillAppear()
    /// Life Cycle Method: Called when the listView has been appeared.
    func listDidAppear()
    /// Life Cycle Method: Called when the listView will be disappear.
    func listWillDisappear()
    /// Life Cycle Method: Called when the listView has been disappeared.
    func listDidDisappear()
}

/// A protocol representing a list embedded in a `SegmentedView` view.
public protocol SegmentedViewContainerDataSource: AnyObject {
    
    /// Returns the number of lists
    func numberOfLists(in listContainerView: SegmentedListContainerView) -> Int
    
    /// Initialize a corresponding list instance according to index. 
    ///
    /// The object must comply with the `SegmentedViewListProtocol` protocol.
    /// If the list is encapsulated by a custom UIView, let the custom UIView comply with the `SegmentedViewListProtocol` protocol. The method can return the custom UIView. If the list is encapsulated by a custom UIViewController, let the custom UIViewController comply with the `SegmentedViewListProtocol` protocol. The method can return the custom UIViewController.
    ///
    /// - Note: It must be a newly generated instance! ! !
    /// - Parameters: 
    ///  - listContainerView: SegmentedListContainerView
    ///  - index: target index
    ///  - Returns: Instance that complies with the `SegmentedViewListProtocol`
    func listContainerView(_ listContainerView: SegmentedListContainerView, initListAt index: Int) -> SegmentedViewListProtocol
    
    /// Controls whether the list of the corresponding index can be initialized.
    ///
    /// Some business requirements require that certain lists be initialized only in certain situations, and this control is achieved through this proxy.
    func listContainerView(_ listContainerView: SegmentedListContainerView, canInitListAt index: Int) -> Bool
}

/// Segmented list view
public class SegmentedListContainerView: UIView, SegmentedViewListContainer, UIScrollViewDelegate {
    
    /// The dataSource of `SegmentedListContainerView`
    public weak var dataSource: SegmentedViewContainerDataSource?
    
    /// The internal scrollView
    public private(set) var scrollView = UIScrollView()
    
    /// The list dictionary that has been loaded. The key is the index and the value is the corresponding list.
    public private(set) var validListDict: [Int: SegmentedViewListProtocol] = [:]
    
    /// When scrolling, the scroll distance exceeds a certain percentage of a page to trigger the initialization of the list. The default value is 0.01 (that is, the list is loaded when it is displayed a little). The range is 0~1, and the open interval does not include 0 and 1
    public var initListPercent: CGFloat = 0.01 {
        didSet {
            if initListPercent <= 0 || initListPercent >= 1 {
                assertionFailure("The value range is an open interval (0,1), which does not include 0 and 1")
            }
        }
    }
    
    /// The list cell backgroundColor
    public var listCellBackgroundColor: UIColor = .white
    
    /// Needs to be consistent with segmentedView.defaultSelectedIndex to trigger the loading of the default index list
    public var defaultSelectedIndex: Int = 0 {
        didSet {
            self.currentIndex = self.defaultSelectedIndex
        }
    }
    
    private var currentIndex: Int = 0
    
    private lazy var containerVC = SegmentedListContainerViewController()
    private var willAppearIndex: Int = -1
    private var willDisappearIndex: Int = -1
    
    var willBeginDraggingHandler: (() -> Void)?
    
    /// Initializer
    public init(dataSource: SegmentedViewContainerDataSource? = nil) {
        self.dataSource = dataSource
        
        super.init(frame: .zero)
        
        self.setup()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setup() {
        self.containerVC.view.backgroundColor = .clear
        self.addSubview(self.containerVC.view)
        
        self.containerVC.viewWillAppearClosure = { [weak self] in
            self?.listWillAppear(at: self?.currentIndex ?? 0)
        }
        
        self.containerVC.viewDidAppearClosure = { [weak self] in
            self?.listDidAppear(at: self?.currentIndex ?? 0)
        }
        
        self.containerVC.viewWillDisappearClosure = { [weak self] in
            self?.listWillDisappear(at: self?.currentIndex ?? 0)
        }
        
        self.containerVC.viewDidDisappearClosure = { [weak self] in
            self?.listDidDisappear(at: self?.currentIndex ?? 0)
        }
        
        self.scrollView.delegate = self
        self.scrollView.isPagingEnabled = true
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.scrollsToTop = false
        self.scrollView.bounces = false
        self.scrollView.contentInsetAdjustmentBehavior = .never
        self.containerVC.view.addSubview(self.scrollView)
    }
    
    public override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        var next: UIResponder? = newSuperview
        while next != nil {
            if let vc = next as? UIViewController{
                vc.addChild(self.containerVC)
                break
            }
            next = next?.next
        }
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        self.containerVC.view.frame = self.bounds
        guard let count = self.dataSource?.numberOfLists(in: self) else {
            return
        }
        if self.scrollView.frame == .zero || self.scrollView.bounds.size != self.bounds.size {
            self.scrollView.frame = self.bounds
            self.scrollView.contentSize = CGSize(
                width: self.scrollView.bounds.width * CGFloat(count),
                height: self.scrollView.bounds.height
            )
            for (index, list) in self.validListDict {
                list.listView().frame = CGRect(
                    x: CGFloat(index) * self.scrollView.bounds.width,
                    y: 0,
                    width: self.scrollView.bounds.width,
                    height: self.scrollView.bounds.height)
            }
            self.scrollView.contentOffset = CGPoint(
                x: CGFloat(self.currentIndex) * self.scrollView.bounds.width,
                y: 0
            )
        } else {
            self.scrollView.frame = self.bounds
            self.scrollView.contentSize = CGSize(
                width: self.scrollView.bounds.width * CGFloat(count),
                height: self.scrollView.bounds.height
            )
        }
    }
    
    // MARK: - SegmentedViewListContainer
    public func contentScrollView() -> UIScrollView {
        return self.scrollView
    }
    
    public func scrolling(from leftIndex: Int, to rightIndex: Int, percentage: CGFloat, selectedIndex: Int) {
    }
    
    public func didClickSelectedItem(at index: Int) {
        guard self.checkIndexValid(index) else {
            return
        }
        self.willAppearIndex = -1
        self.willDisappearIndex = -1
        if self.currentIndex != index {
            self.listWillDisappear(at: self.currentIndex)
            self.listWillAppear(at: index)
            self.listDidDisappear(at: self.currentIndex)
            self.listDidAppear(at: index)
        }
    }
    
    public func reloadData() {
        guard let dataSource = self.dataSource else { return }
        if self.currentIndex < 0 || self.currentIndex >= dataSource.numberOfLists(in: self) {
            self.defaultSelectedIndex = 0
            self.currentIndex = 0
        }
        self.validListDict.values.forEach { (list) in
            if let listVC = list as? UIViewController {
                listVC.removeFromParent()
            }
            list.listView().removeFromSuperview()
        }
        self.validListDict.removeAll()
        self.scrollView.contentSize = CGSize(
            width: self.scrollView.bounds.width * CGFloat(dataSource.numberOfLists(in: self)),
            height: self.scrollView.bounds.height
        )
        self.listWillAppear(at: self.currentIndex)
        self.listDidAppear(at: self.currentIndex)
    }
    
    // MARK: - Privates
    private func initListIfNeeded(at index: Int) {
        guard let dataSource = self.dataSource else { return }
        if dataSource.listContainerView(self, canInitListAt: index) == false {
            return
        }
        var existedList = self.validListDict[index]
        if existedList != nil {
            return
        }
        existedList = dataSource.listContainerView(self, initListAt: index)
        guard let list = existedList else {
            return
        }
        if let vc = list as? UIViewController {
            self.containerVC.addChild(vc)
        }
        self.validListDict[index] = list
        list.listView().frame = CGRect(
            x: CGFloat(index) * self.scrollView.bounds.width,
            y: 0,
            width: self.scrollView.bounds.width,
            height: self.scrollView.bounds.height
        )
        self.scrollView.addSubview(list.listView())
    }
    
    private func listWillAppear(at index: Int) {
        guard let dataSource = self.dataSource else { return }
        guard self.checkIndexValid(index) else {
            return
        }
        var existedList = self.validListDict[index]
        if existedList != nil {
            existedList?.listWillAppear()
            if let vc = existedList as? UIViewController {
                vc.beginAppearanceTransition(true, animated: false)
            }
        } else {
            // The current list has not been created (the page is initialized or listWillAppear is triggered by a click)
            guard dataSource.listContainerView(self, canInitListAt: index) != false else {
                return
            }
            existedList = dataSource.listContainerView(self, initListAt: index)
            guard let list = existedList else {
                return
            }
            if let vc = list as? UIViewController {
                self.containerVC.addChild(vc)
            }
            self.validListDict[index] = list
            if list.listView().superview == nil {
                list.listView().frame = CGRect(
                    x: CGFloat(index) * self.scrollView.bounds.width,
                    y: 0,
                    width: self.scrollView.bounds.width,
                    height: self.scrollView.bounds.height
                )
                self.scrollView.addSubview(list.listView())
            }
            list.listWillAppear()
            if let vc = list as? UIViewController {
                vc.beginAppearanceTransition(true, animated: false)
            }
        }
    }
    
    private func listDidAppear(at index: Int) {
        guard self.checkIndexValid(index) else {
            return
        }
        self.currentIndex = index
        let list = self.validListDict[index]
        list?.listDidAppear()
        if let vc = list as? UIViewController {
            vc.endAppearanceTransition()
        }
    }
    
    private func listWillDisappear(at index: Int) {
        guard self.checkIndexValid(index) else {
            return
        }
        let list = self.validListDict[index]
        list?.listWillDisappear()
        if let vc = list as? UIViewController {
            vc.beginAppearanceTransition(false, animated: false)
        }
    }
    
    private func listDidDisappear(at index: Int) {
        guard self.checkIndexValid(index) else {
            return
        }
        let list = self.validListDict[index]
        list?.listDidDisappear()
        if let vc = list as? UIViewController {
            vc.endAppearanceTransition()
        }
    }
    
    private func checkIndexValid(_ index: Int) -> Bool {
        guard let dataSource = self.dataSource else { return false }
        let count = dataSource.numberOfLists(in: self)
        if count <= 0 || index >= count {
            return false
        }
        return true
    }
    
    private func listDidAppearOrDisappear(scrollView: UIScrollView) {
        let currentIndexPercent = scrollView.contentOffset.x / max(scrollView.bounds.width, 1)
        if self.willAppearIndex != -1 || self.willDisappearIndex != -1 {
            let disappearIndex = self.willDisappearIndex
            let appearIndex = self.willAppearIndex
            if self.willAppearIndex > self.willDisappearIndex {
                // The list that will appear is on the right
                if currentIndexPercent >= CGFloat(self.willAppearIndex) {
                    self.willDisappearIndex = -1
                    self.willAppearIndex = -1
                    self.listDidDisappear(at: disappearIndex)
                    self.listDidAppear(at: appearIndex)
                }
            } else {
                // The list that will appear is on the left
                if currentIndexPercent <= CGFloat(self.willAppearIndex) {
                    self.willDisappearIndex = -1
                    self.willAppearIndex = -1
                    self.listDidDisappear(at: disappearIndex)
                    self.listDidAppear(at: appearIndex)
                }
            }
        }
    }
    
    // MARK: - UIScrollViewDelegate
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.willBeginDraggingHandler?()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard scrollView.isTracking || scrollView.isDragging else {
            return
        }
        let percent = scrollView.contentOffset.x / max(scrollView.bounds.width, 1)
        let maxCount = Int(round(scrollView.contentSize.width / max(scrollView.bounds.width, 1)))
        var leftIndex = Int(floor(Double(percent)))
        leftIndex = max(0, min(maxCount - 1, leftIndex))
        let rightIndex = leftIndex + 1;
        if percent < 0 || rightIndex >= maxCount {
            self.listDidAppearOrDisappear(scrollView: scrollView)
            return
        }
        let remainderRatio = percent - CGFloat(leftIndex)
        if rightIndex == self.currentIndex {
            // The currently selected item is on the ri`ght, and the user is sliding from the right to the left.
            if self.validListDict[leftIndex] == nil && remainderRatio < (1 - self.initListPercent) {
                self.initListIfNeeded(at: leftIndex)
            } else if self.validListDict[leftIndex] != nil {
                if self.willAppearIndex == -1 {
                    self.willAppearIndex = leftIndex;
                    self.listWillAppear(at: self.willAppearIndex)
                }
            }
            
            if self.willDisappearIndex == -1 {
                self.willDisappearIndex = rightIndex
                self.listWillDisappear(at: self.willDisappearIndex)
            }
        } else {
            // The currently selected item is on the left, and the user is sliding from left to right
            if self.validListDict[rightIndex] == nil && remainderRatio > self.initListPercent {
                self.initListIfNeeded(at: rightIndex)
            } else if self.validListDict[rightIndex] != nil {
                if self.willAppearIndex == -1 {
                    self.willAppearIndex = rightIndex
                    self.listWillAppear(at: self.willAppearIndex)
                }
            }
            if self.willDisappearIndex == -1 {
                self.willDisappearIndex = leftIndex
                self.listWillDisappear(at: self.willDisappearIndex)
            }
        }
        self.listDidAppearOrDisappear(scrollView: scrollView)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // Slide halfway and then cancel the slide process
        if self.willAppearIndex != -1 || self.willDisappearIndex != -1 {
            self.listWillDisappear(at: self.willAppearIndex)
            self.listWillAppear(at: self.willDisappearIndex)
            self.listDidDisappear(at: self.willAppearIndex)
            self.listDidAppear(at: self.willDisappearIndex)
            self.willDisappearIndex = -1
            self.willAppearIndex = -1
        }
    }
}

private class SegmentedListContainerViewController: UIViewController {
    
    var viewWillAppearClosure: (() -> Void)?
    var viewDidAppearClosure: (() -> Void)?
    var viewWillDisappearClosure: (() -> Void)?
    var viewDidDisappearClosure: (() -> Void)?
    
    override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.viewWillAppearClosure?()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.viewDidAppearClosure?()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.viewWillDisappearClosure?()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        self.viewDidDisappearClosure?()
    }
}

/// Sample segmented view
public class SegmentedView: UIView, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    /// A constant representing the default value for a given dimension.
    public static let automaticDimension: CGFloat = -1
    
    /// A proxy protocol used to provide data sources for `SegmentedView`.
    public weak var dataSource: SegmentedViewDataSource? {
        didSet {
            self.dataSource?.reloadData(selectedIndex: self.selectedIndex)
        }
    }
    
    /// A proxy protocol used to provide user interactions with items for `SegmentedView`.
    public weak var delegate: SegmentedViewDelegate?
    
    /// Responsible for horizontal scrolling for `SegmentedView`.
    public private(set) lazy var collectionView: SegmentedCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return SegmentedCollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    // Current contentScrollView.contentOffset observation.
    private var scrollViewObservation: NSKeyValueObservation?
    
    /// The current embeded vertical UIScrollView.
    public var contentScrollView: UIScrollView? {
        willSet {
            self.scrollViewObservation?.invalidate()
        }
        didSet {
            self.contentScrollView?.scrollsToTop = false
            self.scrollViewObservation = self.contentScrollView?.observe(
                \.contentOffset,
                 options: .new,
                 changeHandler: { [weak self] scrollView, change in
                     guard let self, let newOffset =  change.newValue else {
                         return
                     }
                     self.observeContentOffset(scrollView, newOffset: newOffset)
                 }
            )
            if let collectionView = self.contentScrollView as? PagingCollectionView {
                collectionView.willBeginDraggingHandler = { [weak self] in
                    guard let self else { return }
                    
                    self.segmentedInitialContentOffsetX = self.collectionView.contentOffset.x
                }
            }
        }
    }
    
    /// Current list container.
    public var listContainer: SegmentedViewListContainer? {
        didSet {
            self.listContainer?.defaultSelectedIndex = self.defaultSelectedIndex
            self.contentScrollView = self.listContainer?.contentScrollView()
            if let containerView = self.listContainer as? SegmentedListContainerView {
                containerView.willBeginDraggingHandler = { [weak self] in
                    guard let self else { return }
                    
                    self.segmentedInitialContentOffsetX = self.collectionView.contentOffset.x
                }
            }
        }
    }
    
    /// The elements of indicators must be UIView or its subclasses that conform to the `SegmentedIndicatorProtocol` protocol.
    public var indicators = [SegmentedIndicatorProtocol & UIView]() {
        didSet {
            self.collectionView.indicators = self.indicators
        }
    }
    
    /// Set during initialization or before reloadData to specify the default index.
    public var defaultSelectedIndex: Int = 0 {
        didSet {
            selectedIndex = defaultSelectedIndex
            if listContainer != nil {
                listContainer?.defaultSelectedIndex = defaultSelectedIndex
            }
        }
    }
    
    /// Current selected index.
    public private(set) var selectedIndex: Int = 0
    
    /// Whether to scroll synchronously when scrolling the list container.
    public var isSyncScrollingWhenScrollListContainer: Bool = true
    
    /// The left margin of the overall content, default `SegmentedView.automaticDimension` (equal to itemSpacing).
    public var contentEdgeInsetLeft: CGFloat = SegmentedView.automaticDimension
    
    /// The right margin of the overall content, default `SegmentedView.automaticDimension` (equal to itemSpacing).
    public var contentEdgeInsetRight: CGFloat = SegmentedView.automaticDimension
    
    /// When clicking to selected, does the contentScrollView switch need animation.
    public var isContentScrollViewClickTransitionAnimationEnabled: Bool = true
    
    // Item data sources.
    private var itemDataSource: [SegmentedItemModel] = []
    // Inner item spacing.
    private var innerItemSpacing: CGFloat = 0
    /// Used to record the latest contentoffset.
    private var lastContentOffset: CGPoint = .zero
    /// The target index being scrolled. This is used to handle the situation where clicking an item immediately while the list is scrolling will cause the interface to display abnormally.
    private var scrollingTargetIndex: Int = -1
    /// It's used to mark whether it is the first layout view.
    private var isFirstLayoutSubviews = true
    /// Used to record the latest contentOffset.x.
    private var segmentedInitialContentOffsetX: CGFloat?
    
    /// Initializer
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        /// In order to adapt to different device screen sizes, some users require the aspect ratio of SegmentedView to remain the same.
        ///
        /// Therefore, its height will be different for different screen widths. The calculated height may sometimes be a floating point number with a long number of digits.
        ///
        /// If this height is set to UICollectionView, an internal error will be triggered. Therefore, in order to avoid this problem, the height is uniformly rounded down here.
        ///
        /// If rounding down causes your page to be abnormal, please reset the height of SegmentedView yourself to ensure that it is an integer.
        let targetFrame = CGRect(
            x: 0,
            y: 0,
            width: self.bounds.width,
            height: floor(self.bounds.height)
        )
        if self.isFirstLayoutSubviews {
            self.isFirstLayoutSubviews = false
            self.collectionView.frame = targetFrame
            self.reloadDataWithoutListContainer()
        } else {
            if self.collectionView.frame != targetFrame {
                self.collectionView.frame = targetFrame
                self.collectionView.collectionViewLayout.invalidateLayout()
                self.collectionView.reloadData()
            }
        }
    }
    
    // MARK: - Public
    
    /// Dequeue a wrapping the list view cell
    public func dequeueReusableCell(withReuseIdentifier identifier: String, at index: Int) -> SegmentedItemCell {
        let indexPath = IndexPath(item: index, section: 0)
        guard let cell = self.collectionView.dequeueReusableCell(
            withReuseIdentifier: identifier,
            for: indexPath
        ) as? SegmentedItemCell else {
            fatalError("Cell class must be subclass of SegmentedItemCell")
        }
        return cell
    }
    
    /// Reload the `SegmentedView`.
    public func reloadData() {
        self.reloadDataWithoutListContainer()
        self.listContainer?.reloadData()
    }
    
    /// Reload the `SegmentedView` excluding list container.
    public func reloadDataWithoutListContainer() {
        self.dataSource?.reloadData(selectedIndex: self.selectedIndex)
        self.dataSource?.registerCellClass(in: self)
        if let itemSource = self.dataSource?.itemDataSource(in: self) {
            self.itemDataSource = itemSource
        }
        if self.selectedIndex < 0 || self.selectedIndex >= self.itemDataSource.count {
            self.defaultSelectedIndex = 0
            self.selectedIndex = 0
        }
        
        self.innerItemSpacing = self.dataSource?.itemSpacing ?? 0
        var totalItemWidth: CGFloat = 0
        var totalContentWidth: CGFloat = self.getContentEdgeInsetLeft()
        for (index, itemModel) in self.itemDataSource.enumerated() {
            itemModel.index = index
            itemModel.itemWidth = (self.dataSource?.segmentedView(
                self,
                widthForItemAt: index,
                isItemWidthZoomValid: true
            ) ?? 0)
            itemModel.isSelected = (index == self.selectedIndex)
            totalItemWidth += itemModel.itemWidth
            if index == self.itemDataSource.count - 1 {
                totalContentWidth += itemModel.itemWidth + self.getContentEdgeInsetRight()
            } else {
                totalContentWidth += itemModel.itemWidth + self.innerItemSpacing
            }
        }
        
        if self.dataSource?.isItemSpacingEquallyEnabled == true &&
            totalContentWidth < self.bounds.width {
            var itemSpacingCount = self.itemDataSource.count - 1
            var totalItemSpacingWidth = self.bounds.width - totalItemWidth
            if self.contentEdgeInsetLeft == SegmentedView.automaticDimension {
                itemSpacingCount += 1
            } else {
                totalItemSpacingWidth -= self.contentEdgeInsetLeft
            }
            if self.contentEdgeInsetRight == SegmentedView.automaticDimension {
                itemSpacingCount += 1
            } else {
                totalItemSpacingWidth -= self.contentEdgeInsetRight
            }
            if itemSpacingCount > 0 {
                self.innerItemSpacing = totalItemSpacingWidth / CGFloat(itemSpacingCount)
            }
        }
        
        var selectedItemFrameX = self.innerItemSpacing
        var selectedItemWidth: CGFloat = 0
        totalContentWidth = self.getContentEdgeInsetLeft()
        for (index, itemModel) in self.itemDataSource.enumerated() {
            if index < self.selectedIndex {
                selectedItemFrameX += itemModel.itemWidth + self.innerItemSpacing
            } else if index == self.selectedIndex {
                selectedItemWidth = itemModel.itemWidth
            }
            if index == self.itemDataSource.count - 1 {
                totalContentWidth += itemModel.itemWidth + self.getContentEdgeInsetRight()
            } else {
                totalContentWidth += itemModel.itemWidth + self.innerItemSpacing
            }
        }
        
        let minX: CGFloat = 0
        let maxX = totalContentWidth - self.bounds.width
        let targetX = selectedItemFrameX - self.bounds.width / 2 + selectedItemWidth / 2
        self.collectionView.setContentOffset(
            CGPoint(x: max(min(maxX, targetX), minX), y: 0),
            animated: false
        )
        
        if let scrollView = self.contentScrollView {
            if scrollView.frame.equalTo(.zero) && scrollView.superview != nil {
                /// In some cases, the system will layout SegmentedView first and contentScrollView later.
                /// This will cause the defaultSelectedIndex specified below to fail.
                /// So when the frame of contentScrollView is zero, the layoutSubviews method of a parent view that already has a frame in its parent view chain is forcibly triggered.
                ///
                /// For example, SegmentedListContainerView will wrap contentScrollView for use. In this case, SegmentedListContainerView.superView is required to trigger layout updates.
                var parentView = scrollView.superview
                while parentView != nil && parentView?.frame.equalTo(.zero) == true {
                    parentView = parentView?.superview
                }
                parentView?.setNeedsLayout()
                parentView?.layoutIfNeeded()
            }
            
            scrollView.setContentOffset(
                CGPoint(x: CGFloat(self.selectedIndex) * scrollView.bounds.width, y: 0),
                animated: false
            )
        }
        
        for indicator in self.indicators {
            if self.itemDataSource.isEmpty {
                indicator.isHidden = true
            } else {
                indicator.isHidden = false
                let configuration = SegmentedIndicatorConfiguration()
                configuration.contentSize = CGSize(width: totalContentWidth, height: self.bounds.height)
                configuration.currentSelectedIndex = self.selectedIndex
                let selectedItemFrame = self.getItemFrame(at: self.selectedIndex)
                configuration.currentSelectedItemFrame = selectedItemFrame
                indicator.refreshIndicatorState(configuration: configuration)
                
                if indicator.isIndicatorConvertToItemFrameEnabled {
                    var convertedFrame = indicator.frame
                    convertedFrame.origin.x -= selectedItemFrame.origin.x
                    self.itemDataSource[self.selectedIndex].indicatorConvertToItemFrame = convertedFrame
                }
            }
        }
        self.collectionView.reloadData()
        self.collectionView.collectionViewLayout.invalidateLayout()
    }
    
    /// Reload a segmented item.
    /// - Parameter index: Specified index
    public func reloadItem(at index: Int) {
        guard index >= 0 && index < self.itemDataSource.count else {
            return
        }
        
        self.dataSource?.refreshItemModel(
            self,
            self.itemDataSource[index],
            at: index,
            selectedIndex: self.selectedIndex
        )
        guard let cell = self.collectionView.cellForItem(
            at: IndexPath(item: index, section: 0)
        ) as? SegmentedItemCell else {
            return
        }
        cell.reloadData(itemModel: self.itemDataSource[index], selectedType: .unselected)
    }
    
    /// Select the specified index segmented item programmatically.
    ///
    /// If you want to trigger the loading of the list corresponding to the index of the list container at the same time, please call the `listContainerView.didClickSelectedItem(at: index)` function.
    ///
    /// - Parameter index: Specified index
    public func selectItem(at index: Int) {
        selectItem(at: index, selectedType: .programmatically)
    }
    
    // MARK: - KVO
    private func observeContentOffset(_ scrollView: UIScrollView, newOffset: CGPoint) {
        if scrollView.isTracking == true || scrollView.isDecelerating == true {
            /// Only contentOffset changes caused by user scrolling are processed.
            var progress = newOffset.x / max(scrollView.bounds.width, 1)
            if Int(progress) > self.itemDataSource.count - 1 || progress < 0 {
                // Exceeded the boundary, no processing required
                return
            }
            if newOffset.x == 0 && self.selectedIndex == 0 && self.lastContentOffset.x == 0 {
                /// Scroll to the far left, the first item has been selected, and the previous contentOffset.x is 0
                return
            }
            let maxOffsetX = scrollView.contentSize.width - scrollView.bounds.width
            if newOffset.x == maxOffsetX &&
                self.selectedIndex == self.itemDataSource.count - 1 &&
                self.lastContentOffset.x == maxOffsetX {
                /// Scroll to the far right, the last item has been selected, and the previous contentOffset.x is maxOffsetX
                return
            }
            
            progress = max(0, min(CGFloat(self.itemDataSource.count - 1), progress))
            let baseIndex = Int(floor(progress))
            let remainderProgress = progress - CGFloat(baseIndex)
            
            let leftItemFrame = self.getItemFrame(at: baseIndex)
            let rightItemFrame = self.getItemFrame(at: baseIndex + 1)
            
            let configuration = SegmentedIndicatorConfiguration()
            configuration.currentSelectedIndex = self.selectedIndex
            configuration.leftIndex = baseIndex
            configuration.leftItemFrame = leftItemFrame
            configuration.rightIndex = baseIndex + 1
            configuration.rightItemFrame = rightItemFrame
            configuration.percentage = remainderProgress
            
            if remainderProgress == 0 {
                /// Slide to turn the page, the selected state needs to be updated
                ///
                /// Slide a short distance, then release to return to the original position, the same value of contentOffset will be called back multiple times.
                ///
                /// For example, when index is 1, slide and release to return to the original position, contentOffset will call back CGPoint(width, 0) multiple times
                if !(self.lastContentOffset.x == newOffset.x && self.selectedIndex == baseIndex) {
                    self.scrollSelectItem(at: baseIndex)
                }
            } else {
                /// Quickly slide to turn the page. When the remainderRatio does not become 0, but the page has been turned, the following judgment is needed to trigger the selection.
                if abs(progress - CGFloat(self.selectedIndex)) > 1 {
                    var targetIndex = baseIndex
                    if progress < CGFloat(self.selectedIndex) {
                        targetIndex = baseIndex + 1
                    }
                    self.scrollSelectItem(at: targetIndex)
                }
                
                if self.selectedIndex == baseIndex {
                    self.scrollingTargetIndex = baseIndex + 1
                } else {
                    self.scrollingTargetIndex = baseIndex
                }
                
                self.dataSource?.refreshItemModel(
                    self,
                    leftItemModel: self.itemDataSource[baseIndex],
                    rightItemModel: self.itemDataSource[baseIndex + 1],
                    percentage: remainderProgress
                )
                
                if self.isSyncScrollingWhenScrollListContainer {
                   let itemMaxOffsetX = self.collectionView.contentSize.width - self.collectionView.bounds.width
                    if itemMaxOffsetX > 0.5,
                       let initialOffsetX = self.segmentedInitialContentOffsetX {
                        let leftToRight = self.selectedIndex == baseIndex
                        let moveX = rightItemFrame.midX - leftItemFrame.midX
                        let lastOffsetX = leftItemFrame.midX - self.collectionView.frame.midX
                        
                        var clampedOffsetX: CGFloat = 0
                        if lastOffsetX < 0 {
                            clampedOffsetX = (lastOffsetX + moveX) * remainderProgress
                        } else if lastOffsetX + moveX > itemMaxOffsetX {
                            clampedOffsetX = lastOffsetX + (itemMaxOffsetX - lastOffsetX) * remainderProgress
                        } else {
                            clampedOffsetX = lastOffsetX + moveX * remainderProgress
                        }
                        if leftToRight {
                            clampedOffsetX += (initialOffsetX - clampedOffsetX) * (1 - remainderProgress)
                        } else {
                            clampedOffsetX += (initialOffsetX - clampedOffsetX) * remainderProgress
                        }
                        let offsetX = min(max(clampedOffsetX, 0), itemMaxOffsetX)
                        self.collectionView.setContentOffset(
                            CGPoint(x: offsetX, y: self.collectionView.contentOffset.y),
                            animated: false
                        )
                    }
                }
                
                for indicator in self.indicators {
                    indicator.contentScrollViewDidScroll(configuration: configuration)
                    if indicator.isIndicatorConvertToItemFrameEnabled {
                        var leftConvertedFrame = indicator.frame
                        leftConvertedFrame.origin.x -= leftItemFrame.origin.x
                        self.itemDataSource[baseIndex].indicatorConvertToItemFrame = leftConvertedFrame
                        
                        var rightConvertedFrame = indicator.frame
                        rightConvertedFrame.origin.x -= rightItemFrame.origin.x
                        self.itemDataSource[baseIndex + 1].indicatorConvertToItemFrame = rightConvertedFrame
                    }
                }
                
                let leftCell = self.collectionView.cellForItem(
                    at: IndexPath(item: baseIndex, section: 0)
                ) as? SegmentedItemCell
                leftCell?.reloadData(
                    itemModel: self.itemDataSource[baseIndex],
                    selectedType: .unselected
                )
                
                let rightCell = self.collectionView.cellForItem(
                    at: IndexPath(item: baseIndex + 1, section: 0)
                ) as? SegmentedItemCell
                rightCell?.reloadData(
                    itemModel: self.itemDataSource[baseIndex + 1],
                    selectedType: .unselected
                )
                
                self.listContainer?.scrolling(
                    from: baseIndex,
                    to: baseIndex + 1,
                    percentage: remainderProgress,
                    selectedIndex: self.selectedIndex
                )
                self.delegate?.segmentedView(
                    self,
                    scrollingFrom: baseIndex,
                    to: baseIndex + 1,
                    percentage: remainderProgress
                )
            }
        }
        self.lastContentOffset = newOffset
    }
    
    // MARK: - Privates
    private func setup() {
        
        self.collectionView.backgroundColor = .clear
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.scrollsToTop = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.isPrefetchingEnabled = false
        self.collectionView.contentInsetAdjustmentBehavior = .never
        self.addSubview(self.collectionView)
    }
    
    private func clickSelectItem(at index: Int) {
        guard self.delegate?.segmentedView(self, canClickItemAt: index) != false else {
            return
        }
        self.selectItem(at: index, selectedType: .clicking)
    }
    
    private func scrollSelectItem(at index: Int) {
        self.selectItem(at: index, selectedType: .scrolling)
    }
    
    private func selectItem(at index: Int, selectedType: SegmentedViewItemSelectedType) {
        guard index >= 0 && index < self.itemDataSource.count else {
            return
        }
        
        if index == self.selectedIndex {
            if selectedType == .programmatically {
                self.listContainer?.didClickSelectedItem(at: index)
            } else if selectedType == .clicking {
                self.delegate?.segmentedView(self, didClickSelectedItemAt: index)
                self.listContainer?.didClickSelectedItem(at: index)
            } else if selectedType == .scrolling {
                self.delegate?.segmentedView(self, didScrollSelectedItemAt: index)
            }
            self.delegate?.segmentedView(self, didSelectedItemAt: index)
            self.scrollingTargetIndex = -1
            return
        }
        
        let currentSelectedItemModel = self.itemDataSource[self.selectedIndex]
        let willSelectedItemModel = self.itemDataSource[index]
        self.dataSource?.refreshItemModel(
            self,
            currentSelectedItemModel: currentSelectedItemModel,
            willSelectedItemModel: willSelectedItemModel,
            selectedType: selectedType
        )
        
        let currentSelectedCell = self.collectionView.cellForItem(
            at: IndexPath(item: self.selectedIndex, section: 0)
        ) as? SegmentedItemCell
        currentSelectedCell?.reloadData(
            itemModel: currentSelectedItemModel,
            selectedType: selectedType
        )
        
        let willSelectedCell = self.collectionView.cellForItem(
            at: IndexPath(item: index, section: 0)
        ) as? SegmentedItemCell
        willSelectedCell?.reloadData(
            itemModel: willSelectedItemModel,
            selectedType: selectedType
        )
        
        if self.scrollingTargetIndex != -1 && self.scrollingTargetIndex != index {
            let scrollingTargetItemModel = self.itemDataSource[self.scrollingTargetIndex]
            scrollingTargetItemModel.isSelected = false
            self.dataSource?.refreshItemModel(
                self,
                currentSelectedItemModel: scrollingTargetItemModel,
                willSelectedItemModel: willSelectedItemModel,
                selectedType: selectedType
            )
            let scrollingTargetCell = self.collectionView.cellForItem(
                at: IndexPath(item: self.scrollingTargetIndex, section: 0)
            ) as? SegmentedItemCell
            scrollingTargetCell?.reloadData(
                itemModel: scrollingTargetItemModel,
                selectedType: selectedType
            )
        }
        
        if self.dataSource?.isItemWidthZoomEnabled == true {
            if selectedType == .clicking || selectedType == .programmatically {
                /// In order to solve the cell.width change, click the last few cells, and scrollToItem will appear a position offset.
                ///
                /// You need to wait for the cell.width animation gradient to end before scrolling to the cell position of index.
                let milliseconds = Int((self.dataSource?.selectedAnimationDuration ?? 0) * 1_000)
                DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(milliseconds)) {
                    self.collectionView.scrollToItem(
                        at: IndexPath(item: index, section: 0),
                        at: .centeredHorizontally,
                        animated: true
                    )
                }
            } else if selectedType == .scrolling {
                // Scroll selected direct processing
                self.collectionView.scrollToItem(
                    at: IndexPath(item: index, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
            }
        } else {
            if !self.isSyncScrollingWhenScrollListContainer {
                self.collectionView.scrollToItem(
                    at: IndexPath(item: index, section: 0),
                    at: .centeredHorizontally,
                    animated: true
                )
            }
        }
        
        if let scrollView = self.contentScrollView,
           (selectedType == .clicking || selectedType == .programmatically) {
            scrollView.setContentOffset(
                CGPoint(x: scrollView.bounds.width * CGFloat(index), y: 0),
                animated: self.isContentScrollViewClickTransitionAnimationEnabled
            )
        }
        
        let lastSelectedIndex = self.selectedIndex
        self.selectedIndex = index
        
        let currentSelectedItemFrame = self.getItemFrame(at: self.selectedIndex)
        for indicator in self.indicators {
            let configuration = SegmentedIndicatorConfiguration()
            configuration.lastSelectedIndex = lastSelectedIndex
            configuration.currentSelectedIndex = self.selectedIndex
            configuration.currentSelectedItemFrame = currentSelectedItemFrame
            configuration.selectedType = selectedType
            indicator.selectItem(configuration: configuration)
            
            if indicator.isIndicatorConvertToItemFrameEnabled {
                var convertedFrame = indicator.frame
                convertedFrame.origin.x -= currentSelectedItemFrame.origin.x
                itemDataSource[selectedIndex].indicatorConvertToItemFrame = convertedFrame
                willSelectedCell?.reloadData(
                    itemModel: willSelectedItemModel,
                    selectedType: selectedType
                )
            }
        }
        
        self.scrollingTargetIndex = -1
        if selectedType == .programmatically {
            self.listContainer?.didClickSelectedItem(at: index)
        } else if selectedType == .clicking {
            self.delegate?.segmentedView(self, didClickSelectedItemAt: index)
            self.listContainer?.didClickSelectedItem(at: index)
        } else if selectedType == .scrolling {
            self.delegate?.segmentedView(self, didScrollSelectedItemAt: index)
        }
        self.delegate?.segmentedView(self, didSelectedItemAt: index)
    }
    
    private func getItemFrame(at index: Int) -> CGRect {
        guard index < self.itemDataSource.count else {
            return .zero
        }
        var originX = self.getContentEdgeInsetLeft()
        for offset in 0..<index {
            let itemModel = self.itemDataSource[offset]
            var itemWidth: CGFloat = 0
            if itemModel.isTransitionAnimating && itemModel.isItemWidthZoomEnabled {
                /// When an animation is in progress, `itemWidthCurrentZoomScale` changes gradually with the animation instead of updating to the target value immediately.
                if itemModel.isSelected {
                    itemWidth = (self.dataSource?.segmentedView(
                        self,
                        widthForItemAt: itemModel.index,
                        isItemWidthZoomValid: false
                    ) ?? 0) * itemModel.itemWidthSelectedZoomScale
                } else {
                    itemWidth = (self.dataSource?.segmentedView(
                        self,
                        widthForItemAt: itemModel.index,
                        isItemWidthZoomValid: false) ?? 0
                    ) * itemModel.itemWidthNormalZoomScale
                }
            } else {
                itemWidth = itemModel.itemWidth
            }
            originX += itemWidth + self.innerItemSpacing
        }
        var width: CGFloat = 0
        let selectedItemModel = self.itemDataSource[index]
        if selectedItemModel.isTransitionAnimating && selectedItemModel.isItemWidthZoomEnabled {
            width = (self.dataSource?.segmentedView(
                self,
                widthForItemAt: selectedItemModel.index,
                isItemWidthZoomValid: false) ?? 0
            ) * selectedItemModel.itemWidthSelectedZoomScale
        } else {
            width = selectedItemModel.itemWidth
        }
        return CGRect(x: originX, y: 0, width: width, height: self.bounds.height)
    }
    
    private func getContentEdgeInsetLeft() -> CGFloat {
        if self.contentEdgeInsetLeft == SegmentedView.automaticDimension {
            return self.innerItemSpacing
        } else {
            return self.contentEdgeInsetLeft
        }
    }
    
    private func getContentEdgeInsetRight() -> CGFloat {
        if self.contentEdgeInsetRight == SegmentedView.automaticDimension {
            return self.innerItemSpacing
        } else {
            return self.contentEdgeInsetRight
        }
    }
}

extension SegmentedView {
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.itemDataSource.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = self.dataSource?.segmentedView(self, cellForItemAt: indexPath.item) {
            cell.reloadData(itemModel: self.itemDataSource[indexPath.item], selectedType: .unselected)
            return cell
        } else {
            return UICollectionViewCell(frame: .zero)
        }
    }
}

extension SegmentedView {
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var isTransitionAnimating = false
        for itemModel in self.itemDataSource {
            if itemModel.isTransitionAnimating {
                isTransitionAnimating = true
                break
            }
        }
        if !isTransitionAnimating {
            // There is no item being transitioned at the moment, so click to select is allowed.
            self.clickSelectItem(at: indexPath.item)
        }
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        insetForSectionAt section: Int
    ) -> UIEdgeInsets {
        return UIEdgeInsets(
            top: 0,
            left: self.getContentEdgeInsetLeft(),
            bottom: 0,
            right: self.getContentEdgeInsetRight()
        )
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return CGSize(
            width: self.itemDataSource[indexPath.item].itemWidth,
            height: collectionView.bounds.height
        )
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumLineSpacingForSectionAt section: Int
    ) -> CGFloat {
        return self.innerItemSpacing
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt section: Int
    ) -> CGFloat {
        return self.innerItemSpacing
    }
}

/// Provides a default implementations of `SegmentedViewDelegate` so that all delegate methods are optional for classes that conform to `SegmentedViewDelegate`.
extension SegmentedViewDelegate {
    
    /// Nothing to do
    public func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) { }
    /// Nothing to do
    public func segmentedView(_ segmentedView: SegmentedView, didClickSelectedItemAt index: Int) { }
    /// Nothing to do
    public func segmentedView(_ segmentedView: SegmentedView, didScrollSelectedItemAt index: Int) { }
    /// Nothing to do
    public func segmentedView(_ segmentedView: SegmentedView, scrollingFrom leftIndex: Int, to rightIndex: Int, percentage: CGFloat) { }
    /// Nothing to do
    public func segmentedView(_ segmentedView: SegmentedView, canClickItemAt index: Int) -> Bool { return true }
}

/// Provides a default implementations of `SegmentedViewListProtocol` so that all delegate methods are optional for classes that conform to `SegmentedViewListProtocol`.
extension SegmentedViewListProtocol {
    
    /// Nothing to do
    public func listWillAppear() { }
    /// Nothing to do
    public func listDidAppear() { }
    /// Nothing to do
    public func listWillDisappear() { }
    /// Nothing to do
    public func listDidDisappear() { }
}

/// Provides a default implementations of `SegmentedViewContainerDataSource` so that all delegate methods are optional for classes that conform to `SegmentedViewContainerDataSource`.
extension SegmentedViewContainerDataSource {
    
    /// Nothing to do
    public func listContainerView(_ listContainerView: SegmentedListContainerView, canInitListAt index: Int) -> Bool {
        return true
    }
}

extension String {
    
    /// Calculate text size.
    /// - Parameters:
    ///   - width: Calculate the height by giving the width.
    ///   - height: Calculate the width by giving the height.
    ///   - maxLines: Maximum number of lines of text, 0 means no limits.
    /// - Returns: The text size.
    public func calculateSize(
        font: UIFont,
        width: CGFloat = .greatestFiniteMagnitude,
        height: CGFloat = .greatestFiniteMagnitude,
        maxLines: Int = 0
    ) -> CGSize {
        guard !self.isEmpty else {
            return .zero
        }
        let textStorage = NSTextStorage(string: self)
        textStorage.addAttributes(
            [NSAttributedString.Key.font: font],
            range: NSRange(location: 0, length: textStorage.length)
        )
        
        let maxSize = CGSize(width: width, height: height)
        let textContainer = NSTextContainer(size: maxSize)
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = maxLines
        
        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        layoutManager.glyphRange(for: textContainer)
        let textBounds = layoutManager.usedRect(for: textContainer)
        return textBounds.size
    }
}

extension UIColor {
    
    fileprivate var rgba: (CGFloat, CGFloat, CGFloat, CGFloat) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        self.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}

private func interpolate<T: SignedNumeric & Comparable>(from: T, to:  T, percentage:  T) ->  T {
    let fixedPercentage = max(0, min(1, percentage))
    return from + (to - from) * fixedPercentage
}

private func interpolateColor(from: UIColor, to: UIColor, percentage: CGFloat) -> UIColor {
    let (fromRed, fromGreen, fromBlue, fromAlpha) = from.rgba
    let (toRed, toGreen, toBlue, toAlpha) = to.rgba
    let red = interpolate(from: fromRed, to: toRed, percentage: percentage)
    let green = interpolate(from: fromGreen, to: toGreen, percentage: percentage)
    let blue = interpolate(from: fromBlue, to: toBlue, percentage: percentage)
    let alpha = interpolate(from: fromAlpha, to: toAlpha, percentage: percentage)
    return UIColor(red: red, green: green, blue: blue, alpha: alpha)
}

private func interpolateColors(from: [CGColor], to: [CGColor], percentage: CGFloat) -> [CGColor] {
    var resultColors = [CGColor]()
    for index in 0..<from.count {
        let fromColor = UIColor(cgColor: from[index])
        let toColor = UIColor(cgColor: to[index])
        let (fromRed, fromGreen, fromBlue, fromAlpha) = fromColor.rgba
        let (toRed, toGreen, toBlue, toAlpha) = toColor.rgba
        let red = interpolate(from: fromRed, to: toRed, percentage: percentage)
        let green = interpolate(from: fromGreen, to: toGreen, percentage: percentage)
        let blue = interpolate(from: fromBlue, to: toBlue, percentage: percentage)
        let alpha = interpolate(from: fromAlpha, to: toAlpha, percentage: percentage)
        resultColors.append(UIColor(red: red, green: green, blue: blue, alpha: alpha).cgColor)
    }
    return resultColors
}
