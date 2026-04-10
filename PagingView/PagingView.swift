//
//  PagingView.swift
//  PagingView
//
//  Created by Sun on 2024/7/26.
//

import UIKit

/// A protocol representing a list embedded in a `PagingView` view.
public protocol PagingViewListProtocol: AnyObject {
    
    /// Returns listView. If it is wrapped by `UIViewController`, it's view, if it is wrapped by a custom view, it is the custom view itself.
    func listView() -> UIView
    
    /// Returns the UIScrollView or its subclasses held by `PagingViewListProtocol`.
    func listScrollView() -> UIScrollView
    
    /// Life Cycle Method: Called when the listView will be appear.
    func listViewWillAppear(_ index: Int)
    
    /// Life Cycle Method: Called when the listView has been appeared.
    func listViewDidAppear(_ index: Int)
    
    /// Life Cycle Method: Called when the listView will be disappear.
    func listViewWillDisappear(_ index: Int)
    
    /// Life Cycle Method: Called when the listView has been disappeared.
    func listViewDidDisappear(_ index: Int)
}

/// An implementation of the `PagingViewDataSource` protocol used to provide header and list.
public protocol PagingViewDataSource: AnyObject {
    
    /// Returns the height of the header view, default is automaticDimension.
    func heightForHeaderView(in pagingView: PagingView) -> CGFloat
    
    /// Returns the height of the header view.
    func headerView(in pagingView: PagingView) -> UIView
    
    /// Returns the height of the header view.
    func heightForSegmentedView(in pagingView: PagingView) -> CGFloat
    
    /// Returns the additional vertical offset of the segmented view.
    func offsetYForSegmentedView(in pagingView: PagingView) -> CGFloat
    
    /// Return to pinned view.
    func segmentedView(in pagingView: PagingView) -> UIView
    
    /// Returns the number of lists.
    func numberOfLists(in pagingView: PagingView) -> Int
    
    /// Initialize a corresponding list instance according to the index.
    ///
    /// The object must conform the `PagingViewListProtocol` protocol.
    ///
    /// If the list is encapsulated by a custom UIView, let the custom UIView conform the `PagingViewListProtocol` protocol, and the method can return the custom UIView.
    ///
    /// If the list is encapsulated by a custom UIViewController, let the custom UIViewController conform the `PagingViewListProtocol` protocol, and the method can return the custom UIViewController.
    func pagingView(_ pagingView: PagingView, initListAtIndex index: Int) -> PagingViewListProtocol
}

public protocol PagingViewDelegate: AnyObject {
    
    /// Tells the delegate when the user scrolls the `PagingView`.
    ///
    /// - Parameters:
    ///    - pagingView: The PagingView.
    ///    - horizontalScrollView: The internal collectionView with horizontal scrolling.
    func pagingViewDidScroll(_ pagingView: PagingView, horizontalScrollView: PagingCollectionView)
    
    /// Tells the delegate when the user scrolls current list scrollView.
    ///
    /// - Parameters:
    ///   - pagingView: The PagingView.
    ///   - scrollView: Current list scrollView.
    ///   - contentOffset: The converted contentOffset.
    func pagingViewCurrentListViewDidScroll(_ pagingView: PagingView, scrollView: UIScrollView, contentOffset: CGPoint)
}

/// Horizontally sliding CollectionView in `PagingView`.
public class PagingCollectionView: UICollectionView, UIGestureRecognizerDelegate {
    
    /// A containerView of header view in `PagingView`.
    public var headerContainerView: UIView?
    
    /// Called when the list container starts scrolling
    public var willBeginDraggingHandler: (() -> Void)?
    
    /// UIGestureRecognizerDelegate
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: self.headerContainerView)
        if self.headerContainerView?.bounds.contains(point) == true {
            return false
        }
        return true
    }
}

/// A view that contains a header and a horizontally pager list.
/// The list can scroll vertically, and the header can be pinned the top.
public class PagingView: UIView, UIGestureRecognizerDelegate {
    
    /// A constant representing the default value for a given dimension.
    public static let automaticDimension: CGFloat = -1
    
    /// The internal collectionView with horizontal scrolling.
    public private(set) var listCollectionView: PagingCollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        return PagingCollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    /// The list dictionary that has been loaded.
    /// The key is the index and the value is the corresponding list.
    public private(set) var listDict: [Int: PagingViewListProtocol] = [:]
    
    /// The header dictionary that has been loaded.
    /// The key is the index and the value is the corresponding header.
    public private(set) var listHeaderDict: [Int: UIView] = [:]
    
    /// A proxy protocol used to provide paging view events.
    public weak var dataSource: PagingViewDataSource?
    
    // A proxy protocol used to provide header and list.
    public weak var delegate: PagingViewDelegate?
    
    /// Current list scrollView.
    public private(set) var currentListScrollView: UIScrollView?
    
    /// Default selected index.
    public var defaultSelectedIndex: Int = 0 {
        didSet {
            self.currentIndex = self.defaultSelectedIndex
        }
    }
    
    /// Whether to automatically fill the contentSize of scrollView
    ///
    /// If true, when the contentSize of scrollView is insufficient, the contentSize of scrollView will be modified so that it can scroll to the pinned state.
    ///
    /// Othewise, when the contentSize is not enough to scroll to the pinned state, the header and segmented will automatically scroll down.
    public var isFillContentSizeAutomatically: Bool = true
    
    /// Current selected index.
    public private(set) var currentIndex: Int = 0
    
    /// The height of the header container
    public private(set) var headerContainerHeight: CGFloat = 0
    
    /// The vertical offset of the segmented view when it pinned.
    public var pinnedOffsetY: CGFloat {
        self.headerContainerHeight - self.segmentedHeight - self.segmentedOffsetY
    }
    
    // Saving KVO Information.
    private var scrollViewObservations: [NSKeyValueObservation] = []
    // Header container
    private lazy var headerContainerView = UIView()
    /// Header view
    public private(set) var headerView: UIView?
    /// Segmented view
    public private(set) var segmentedView: UIView?
    // Flag whether to enable sync list content offset
    private var isSyncListContentOffsetEnabled: Bool = false
    // Current paging header view min y
    private var currentHeaderContainerViewY: CGFloat = 0
    /// Header view height
    public private(set) var headerHeight: CGFloat = 0
    /// Segmented view height
    public private(set) var segmentedHeight: CGFloat = 0
    /// The additional vertical offset of the segmented view.
    public private(set) var segmentedOffsetY: CGFloat = 0
    // Current list initialize contentOffset.y
    private var currentListInitailzeContentOffsetY: CGFloat = 0
    // Flag whether the list loaded
    private var isListLoaded: Bool = false
    // Whether it is in horizontal scrolling
    private var isHorizontalScrolling: Bool = false
    // Flag the index of the list will appear
    private var willAppearIndex: Int = -1
    // Flag the index of the list will disappear
    private var willDisappearIndex: Int = -1
    // Whether it is in changing horizontal contentOffset
    private var isChangingHorizontalOffset: Bool = false
    
    /// Initializer
    public init(dataSource: PagingViewDataSource? = nil) {
        self.dataSource = dataSource
        
        super.init(frame: .zero)
        
        self.setup()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        if self.listCollectionView.frame != bounds {
            self.listCollectionView.frame = bounds
            self.reloadData()
        }
        self.reloadListView(bounds)
    }
    
    /// Reload paging view.
    public func reloadData() {
        self.currentListScrollView = nil
        self.currentHeaderContainerViewY = 0
        self.isSyncListContentOffsetEnabled = false
        self.isListLoaded = true
        
        self.listHeaderDict.values.forEach { $0.removeFromSuperview() }
        self.listHeaderDict.removeAll()
        self.listDict.values.forEach { list in
            list.listView().removeFromSuperview()
        }
        self.listDict.removeAll()
        self.scrollViewObservations.forEach { observation in
            observation.invalidate()
        }
        self.scrollViewObservations.removeAll()
        self.reloadHeaderView()
        self.listCollectionView.setContentOffsetIfNeeded(
            CGPoint(x: self.bounds.width * CGFloat(self.currentIndex), y: 0)
        )
        self.listCollectionView.reloadData()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            self.listWillAppear(at: self.currentIndex)
            self.listDidAppear(at: self.currentIndex)
        }
    }
    
    /// Reload headerView, called when headerView height changes.
    public func reloadHeaderView() {
        self.headerView?.removeFromSuperview()
        self.segmentedView?.removeFromSuperview()
        self.headerView = self.dataSource?.headerView(in: self)
        self.segmentedView = self.dataSource?.segmentedView(in: self)
        if let headerView = self.headerView {
            self.headerContainerView.addSubview(headerView)
        }
        if let segmentedView = self.segmentedView {
            self.headerContainerView.addSubview(segmentedView)
        }
        self.reloadHeaderHeights()
        self.reloadHeaderContainerView()
    }
    
    /// Reload segmentedView, called when segmentedView height changes.
    public func reloadSegmentedView() {
        self.segmentedView = self.dataSource?.segmentedView(in: self)
        if let segmentedView = self.segmentedView {
            self.headerContainerView.addSubview(segmentedView)
        }
        self.reloadHeaderHeights()
        self.reloadHeaderContainerView()
    }
    
    /// Scroll to idle
    public func scrollToIdle(_ animated: Bool = true) {
        self.currentListScrollView?.setContentOffset(
            CGPoint(x: 0, y: -self.headerContainerHeight),
            animated: animated
        )
    }
    
    /// Scroll to pinned position
    public func scrollToPinned(_ animated: Bool = true) {
        self.currentListScrollView?.setContentOffset(
            CGPoint(x: 0, y: -(self.segmentedHeight + self.segmentedOffsetY)),
            animated: animated
        )
    }
    
    // MARK: - Privates
    private func setup() {
        self.listCollectionView.dataSource = self
        self.listCollectionView.delegate = self
        self.listCollectionView.isPagingEnabled = true
        self.listCollectionView.bounces = false
        self.listCollectionView.showsHorizontalScrollIndicator = false
        self.listCollectionView.showsVerticalScrollIndicator = false
        self.listCollectionView.scrollsToTop = false
        self.listCollectionView.isPrefetchingEnabled = false
        self.listCollectionView.contentInsetAdjustmentBehavior = .never
        self.listCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        self.listCollectionView.headerContainerView = self.headerContainerView
        self.addSubview(self.listCollectionView)
        self.addSubview(self.headerContainerView)
    }
    
    private func observeContentOffset(_ scrollView: UIScrollView, newOffset: CGPoint) {
        guard scrollView.window != nil else {
            return
        }
        self.listDidScroll(scrollView: scrollView)
    }
    
    private func observeContentSize(_ scrollView: UIScrollView, newSize: CGSize) {
        guard scrollView.window != nil else {
            return
        }
        let minContentHeight = self.bounds.height - self.segmentedHeight - self.segmentedOffsetY
        let contentHeight = scrollView.contentSize.height
        if minContentHeight > contentHeight && self.isFillContentSizeAutomatically {
            scrollView.contentSize = CGSize(
                width: scrollView.contentSize.width,
                height: minContentHeight
            )
            // Reset contentOffset when the new scrollView is first loaded
            if let listScrollView = self.currentListScrollView {
                if scrollView != listScrollView && scrollView.contentSize != .zero {
                    scrollView.setContentOffsetIfNeeded(
                        CGPoint(x: 0, y: self.currentListInitailzeContentOffsetY)
                    )
                }
            }
        } else {
            if minContentHeight > contentHeight {
                scrollView.setContentOffsetIfNeeded(
                    CGPoint(x: scrollView.contentOffset.x, y: -self.headerContainerHeight)
                )
                self.listDidScroll(scrollView: scrollView)
            }
        }
    }
    
    private func listDidScroll(scrollView: UIScrollView) {
        if listCollectionView.isDragging || listCollectionView.isDecelerating { return }
        let index = self.listIndex(for: scrollView)
        guard index == self.currentIndex else {
            return
        }
        self.currentListScrollView = scrollView
        let contentOffsetY = scrollView.contentOffset.y + self.headerContainerHeight
        if contentOffsetY < (self.headerHeight - self.segmentedOffsetY) {
            self.isSyncListContentOffsetEnabled = true
            self.currentHeaderContainerViewY = -contentOffsetY
            self.listDict.values.forEach { list in
                let listScrollView = list.listScrollView()
                if listScrollView != scrollView {
                    listScrollView.setContentOffsetIfNeeded(scrollView.contentOffset)
                }
                if listScrollView.showsVerticalScrollIndicator {
                    let contentOffsetY = listScrollView.contentOffset.y + self.headerContainerHeight
                    var indicatorInsets = listScrollView.verticalScrollIndicatorInsets
                    indicatorInsets.top = listScrollView.contentInset.top - contentOffsetY
                    listScrollView.verticalScrollIndicatorInsets = indicatorInsets
                }
            }
            let header = self.listHeader(for: scrollView)
            if self.headerContainerView.superview != header {
                self.headerContainerView.frame.origin.y = 0
                header?.addSubview(self.headerContainerView)
            }
        } else {
            if self.headerContainerView.superview != self {
                self.headerContainerView.frame.origin.y = -(self.headerHeight - self.segmentedOffsetY)
                self.addSubview(self.headerContainerView)
            }
            if self.isSyncListContentOffsetEnabled {
                self.isSyncListContentOffsetEnabled = false
                self.currentHeaderContainerViewY = -(self.headerHeight - self.segmentedOffsetY)
                self.listDict.values.forEach { list in
                    if list.listScrollView() != self.currentListScrollView {
                        list.listScrollView().setContentOffsetIfNeeded(
                            CGPoint(x: 0, y: -(self.segmentedHeight + self.segmentedOffsetY))
                        )
                    }
                }
            }
        }
        
        let contentOffset = CGPoint(x: scrollView.contentOffset.x, y: contentOffsetY)
        self.delegate?.pagingViewCurrentListViewDidScroll(
            self,
            scrollView: scrollView,
            contentOffset: contentOffset
        )
    }
    
    private func reloadHeaderContainerView() {
        let bounds = self.bounds
        self.headerContainerView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: self.headerContainerHeight
        )
        self.headerView?.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: self.headerHeight
        )
        self.segmentedView?.frame = CGRect(
            x: 0,
            y: self.headerHeight,
            width: bounds.width,
            height: self.segmentedHeight
        )
        
        self.listDict.values.forEach { list in
            let listScrollView = list.listScrollView()
            var insets = listScrollView.contentInset
            insets.top = self.headerContainerHeight
            listScrollView.contentInset = insets
            listScrollView.setContentOffsetIfNeeded(
                CGPoint(x: 0, y: -self.headerContainerHeight)
            )
        }
    }
    
    private func reloadHeaderHeights() {
        if let headerView = self.headerView {
            let heightForHeader = self.dataSource?.heightForHeaderView(in: self)
            if heightForHeader == PagingView.automaticDimension {
                headerView.setNeedsLayout()
                headerView.layoutIfNeeded()
                let targetSize = CGSize(
                    width:  self.bounds.width,
                    height: UIView.layoutFittingCompressedSize.height
                )
                self.headerHeight = headerView.systemLayoutSizeFitting(targetSize).height
            } else {
                self.headerHeight = heightForHeader ?? 0
            }
        } else {
            self.headerHeight = 0
        }
        if let segmentedView = self.segmentedView {
            let heightForSegmented = self.dataSource?.heightForSegmentedView(in: self)
            self.segmentedHeight = heightForSegmented ?? segmentedView.bounds.height
        } else {
            self.segmentedHeight = 0
        }
        self.headerContainerHeight = self.headerHeight + self.segmentedHeight
        self.segmentedOffsetY = self.dataSource?.offsetYForSegmentedView(in: self) ?? 0
    }
    
    private func reloadListView(_ bounds: CGRect) {
        self.listDict.values.forEach { list in
            var listFrame = list.listView().frame
            if listFrame.size != bounds.size {
                listFrame.size = bounds.size
                list.listView().frame = listFrame
            }
        }
        self.listHeaderDict.values.forEach { header in
            var headerFrame = header.frame
            headerFrame.origin.y = -self.headerContainerHeight
            headerFrame.size.height = self.headerContainerHeight
            header.frame = headerFrame
        }
    }
    
    private func horizontalScrollDidEnd(at index: Int) {
        self.currentIndex = index
        guard let listHeader = self.listHeaderDict[index],
              let listScrollView = self.listDict[index]?.listScrollView() else {
            return
        }
        self.currentListScrollView = listScrollView
        self.listDict.values.forEach { list in
            list.listScrollView().scrollsToTop = (list.listScrollView() == listScrollView)
        }
        if listScrollView.contentOffset.y <= -(self.segmentedHeight + self.segmentedOffsetY) {
            self.headerContainerView.frame.origin.y = 0
            listHeader.addSubview(self.headerContainerView)
        }
        let minContentSizeHeight = self.bounds.height - self.segmentedHeight - self.segmentedOffsetY
        if minContentSizeHeight > listScrollView.contentSize.height &&
            !self.isFillContentSizeAutomatically {
            listScrollView.setContentOffsetIfNeeded(
                CGPoint(x: listScrollView.contentOffset.x, y: -self.headerContainerHeight)
            )
            self.listDidScroll(scrollView: listScrollView)
        }
    }
    
    private func listHeader(for listScrollView: UIScrollView) -> UIView? {
        for (index, list) in self.listDict {
            if list.listScrollView() == listScrollView {
                return self.listHeaderDict[index]
            }
        }
        return nil
    }
    
    private func listIndex(for listScrollView: UIScrollView) -> Int {
        for (index, list) in self.listDict {
            if list.listScrollView() == listScrollView {
                return index
            }
        }
        return 0
    }
    
    private func listWillAppear(at index: Int) {
        guard self.isValidIndex(index) else { return }
        let list = self.listDict[index]
        list?.listViewWillAppear(index)
    }
      
    private func listDidAppear(at index: Int) {
        guard self.isValidIndex(index) else { return }
        self.currentIndex = index
        let list = self.listDict[index]
        list?.listViewDidAppear(index)
        if let listScrollView = list?.listScrollView(),
           listScrollView.showsVerticalScrollIndicator {
            listScrollView.flashScrollIndicators()
        }
    }
    
    private func listWillDisappear(at index: Int) {
        guard self.isValidIndex(index) else { return }
        let list = self.listDict[index]
        list?.listViewWillDisappear(index)
    }
    
    private func listDidDisappear(at index: Int) {
        guard self.isValidIndex(index) else { return }
        let list = self.listDict[index]
        list?.listViewDidDisappear(index)
    }
    
    private func isValidIndex(_ index: Int) -> Bool {
        guard let dataSource = self.dataSource else { return false }
        let count = dataSource.numberOfLists(in: self)
        if count <= 0 || index >= count {
            return false
        }
        return true
    }
    
    private func listDidAppearOrDidDisappear(_ scrollView: UIScrollView) {
        let currentIndexPercent = scrollView.contentOffset.x / max(scrollView.bounds.width, 1)
        if self.willAppearIndex != -1 && self.willDisappearIndex != -1 {
            let appearIndex = self.willAppearIndex
            let disappearIndex = self.willDisappearIndex
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
}

extension PagingView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else {
            return 0
        }
        return self.isListLoaded ? dataSource.numberOfLists(in: self) : 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = self.dataSource else {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        var list = self.listDict[indexPath.item]
        if list == nil {
            list = dataSource.pagingView(self, initListAtIndex: indexPath.item)
            if let listVC = list as? UIViewController {
                var next: UIResponder? = self.superview
                while next != nil {
                    if let vc = next as? UIViewController {
                        vc.addChild(listVC)
                        break
                    }
                    next = next?.next
                }
            }
            guard let list else {
                return UICollectionViewCell()
            }
            self.listDict[indexPath.item] = list
            list.listView().setNeedsLayout()
            
            let listScrollView = list.listScrollView()
            listScrollView.contentInsetAdjustmentBehavior = .never
            listScrollView.automaticallyAdjustsScrollIndicatorInsets = false
            
            let minContentHeight = bounds.height - self.segmentedHeight - self.segmentedOffsetY
            if listScrollView.contentSize.height < minContentHeight && self.isFillContentSizeAutomatically {
                listScrollView.contentSize = CGSize(width: self.bounds.width, height: minContentHeight)
            }
            
            var insets = listScrollView.contentInset
            insets.top = self.headerContainerHeight
            listScrollView.contentInset = insets
            self.currentListInitailzeContentOffsetY = -self.headerContainerHeight + min(-self.currentHeaderContainerViewY, (self.headerHeight - self.segmentedOffsetY))
            listScrollView.setContentOffsetIfNeeded(
                CGPoint(x: 0, y: self.currentListInitailzeContentOffsetY)
            )
            let listHeader = UIView(
                frame: CGRect(
                    x: 0,
                    y: -self.headerContainerHeight,
                    width: self.bounds.width,
                    height: self.headerContainerHeight
                )
            )
            listScrollView.addSubview(listHeader)
            
            if self.headerContainerView.superview == nil {
                listHeader.addSubview(self.headerContainerView)
            }
            self.listHeaderDict[indexPath.item] = listHeader
            let offsetObservation = listScrollView.observe(
                \.contentOffset,
                 options: .new,
                 changeHandler: { [weak self] scrollView, change in
                     guard let self, let newOffset = change.newValue else { return }
                     
                     self.observeContentOffset(scrollView, newOffset: newOffset)
                 }
            )
            let sizeObservation = listScrollView.observe(
                \.contentSize,
                 options: .new,
                 changeHandler: { [weak self] scrollView, change in
                     guard let self, let newSize = change.newValue else { return }
                     
                     self.observeContentSize(scrollView, newSize: newSize)
                 }
            )
            self.scrollViewObservations.append(contentsOf: [
                offsetObservation,
                sizeObservation
            ])
            listScrollView.contentOffset = listScrollView.contentOffset
            if listScrollView.showsVerticalScrollIndicator {
                let contentOffsetY = listScrollView.contentOffset.y + self.headerContainerHeight
                var indicatorInsets = listScrollView.verticalScrollIndicatorInsets
                indicatorInsets.top = listScrollView.contentInset.top - contentOffsetY
                listScrollView.verticalScrollIndicatorInsets = indicatorInsets
            }
        }
        self.listDict.values.forEach { cachedList in
            cachedList.listScrollView().scrollsToTop = (cachedList === list)
        }
        if let listView = list?.listView(), listView.superview != cell.contentView {
            cell.contentView.subviews.forEach { $0.removeFromSuperview() }
            listView.frame = cell.bounds
            cell.contentView.addSubview(listView)
        }
        return cell
    }
    
    public func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        return collectionView.bounds.size
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.listCollectionView.willBeginDraggingHandler?()
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.delegate?.pagingViewDidScroll(self, horizontalScrollView: self.listCollectionView)
        let indexPercent = scrollView.contentOffset.x / max(scrollView.bounds.width, 1)
        let index = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        self.isHorizontalScrolling = true
        
        let listScrollView = self.listDict[index]?.listScrollView()
        if index != self.currentIndex &&
            (indexPercent - CGFloat(index) == 0) &&
            !(scrollView.isTracking || scrollView.isDecelerating) &&
            listScrollView?.contentOffset.y ?? 0 <= -(self.segmentedHeight + self.segmentedOffsetY) {
            self.horizontalScrollDidEnd(at: index)
        } else {
            // When scrolling left and right, add headerContainerView to self to achieve the floating effect
            if self.headerContainerView.superview != self {
                self.headerContainerView.frame.origin.y = self.currentHeaderContainerViewY
                self.addSubview(self.headerContainerView)
            }
        }

        let percent = scrollView.contentOffset.x / max(scrollView.bounds.width, 1)
        let maxCount = Int(round(scrollView.contentSize.width / max(scrollView.bounds.width, 1)))
        var leftIndex = Int(floor(Double(percent)))
        leftIndex = max(0, min(maxCount - 1, leftIndex))
        let rightIndex = leftIndex + 1
        if (percent < 0 || rightIndex >= maxCount) {
            self.listDidAppearOrDidDisappear(scrollView)
            return
        }
        if rightIndex == self.currentIndex {
            // The currently selected item is on the right, and the user is sliding from right to left
            if self.listDict[leftIndex] != nil {
                if self.willAppearIndex == -1 {
                    self.willAppearIndex = leftIndex
                    self.listWillAppear(at: self.willAppearIndex)
                }
            }
            if self.willDisappearIndex == -1 {
                self.willDisappearIndex = rightIndex
                self.listWillDisappear(at: self.willDisappearIndex)
            }
        } else {
            // The currently selected item is on the left, and the user is sliding from left to right
            if self.listDict[rightIndex] != nil {
                if self.willAppearIndex == -1 {
                    self.willAppearIndex = rightIndex
                    self.listWillAppear(at: self.willAppearIndex)
                }
            }
            if self.willDisappearIndex == -1 {
                self.willDisappearIndex = leftIndex
                self.listWillDisappear(at: leftIndex)
            }
        }
        self.listDidAppearOrDidDisappear(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // When scrolling to the middle and then cancel the scrolls.
            if (self.willDisappearIndex != -1) {
                self.listWillAppear(at: self.willDisappearIndex)
                self.listWillDisappear(at: self.willAppearIndex)
                self.listDidAppear(at: self.willDisappearIndex)
                self.listDidDisappear(at: self.willAppearIndex)
                self.willDisappearIndex = -1
                self.willAppearIndex = -1
            }
            let index = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
            self.horizontalScrollDidEnd(at: index)
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // When scrolling to the middle and then cancel the scrolls.
        if (self.willDisappearIndex != -1) {
            self.listDidAppear(at: self.willDisappearIndex)
            self.listDidDisappear(at: self.willAppearIndex)
            self.willDisappearIndex = -1
            self.willAppearIndex = -1
        }
        let index = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        self.horizontalScrollDidEnd(at: index)
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard self.isListLoaded else { return }
        let index = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        self.currentIndex = index
        self.currentListScrollView = self.listDict[index]?.listScrollView()
        self.isHorizontalScrolling = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if !self.isHorizontalScrolling && self.headerContainerView.superview == self {
                self.horizontalScrollDidEnd(at: index)
            }
        }
    }
}

/// Provides a default implementations of `PagingViewListProtocol` so that all delegate methods are optional for classes that conform to `PagingViewListProtocol`.
extension PagingViewListProtocol {
    
    /// Life Cycle Method: Called when the listView will be appear.
    public func listViewWillAppear(_ index: Int) { }
    
    /// Life Cycle Method: Called when the listView has been appeared.
    public func listViewDidAppear(_ index: Int) { }
    
    /// Life Cycle Method: Called when the listView will be disappear.
    public func listViewWillDisappear(_ index: Int) { }
    
    /// Life Cycle Method: Called when the listView has been disappeared.
    public func listViewDidDisappear(_ index: Int) { }
}

/// Provides a default implementations of `PagingViewDataSource` so that all delegate methods are optional for classes that conform to `PagingViewDataSource`.
extension PagingViewDataSource {
    
    /// Returns the default height of headerView.
    public func heightForHeaderView(in pagingView: PagingView) -> CGFloat {
        return PagingView.automaticDimension
    }
    
    // Returns the default additional vertical offset of the segmented view.
    public func offsetYForSegmentedView(in pagingView: PagingView) -> CGFloat {
        return 0
    }
}

/// Provides a default implementations of `PagingViewDelegate` so that all delegate methods are optional for classes that conform to `PagingViewDelegate`.
extension PagingViewDelegate {
    
    /// Tells the delegate when the user scrolls the `PagingView`.
    public func pagingViewDidScroll(_ pagingView: PagingView, horizontalScrollView: PagingCollectionView) { }
    
    /// Tells the delegate when the user scrolls current list scrollView.
    public func pagingViewCurrentListViewDidScroll(_ pagingView: PagingView, scrollView: UIScrollView, contentOffset: CGPoint) { }
}

extension UIScrollView {
    
    /// Set contentOffset if needed.
    fileprivate func setContentOffsetIfNeeded(_ offset: CGPoint) {
        if self.contentOffset != offset {
            self.setContentOffset(offset, animated: false)
        }
    }
}
