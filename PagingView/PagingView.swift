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
    public func gestureRecognizer(_: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        let point = touch.location(in: headerContainerView)
        if headerContainerView?.bounds.contains(point) == true {
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

    /// A proxy protocol used to provide header and list.
    public weak var delegate: PagingViewDelegate?

    /// Current list scrollView.
    public private(set) var currentListScrollView: UIScrollView?

    /// Default selected index.
    public var defaultSelectedIndex: Int = 0 {
        didSet {
            currentIndex = defaultSelectedIndex
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
        headerContainerHeight - segmentedHeight - segmentedOffsetY
    }

    /// Saving KVO Information.
    private var scrollViewObservations: [NSKeyValueObservation] = []
    /// Header container
    private lazy var headerContainerView = UIView()
    /// Header view
    public private(set) var headerView: UIView?
    /// Segmented view
    public private(set) var segmentedView: UIView?
    /// Flag whether to enable sync list content offset
    private var isSyncListContentOffsetEnabled: Bool = false
    /// Current paging header view min y
    private var currentHeaderContainerViewY: CGFloat = 0
    /// Header view height
    public private(set) var headerHeight: CGFloat = 0
    /// Segmented view height
    public private(set) var segmentedHeight: CGFloat = 0
    /// The additional vertical offset of the segmented view.
    public private(set) var segmentedOffsetY: CGFloat = 0
    /// Current list initialize contentOffset.y
    private var currentListInitailzeContentOffsetY: CGFloat = 0
    /// Flag whether the list loaded
    private var isListLoaded: Bool = false
    /// Whether it is in horizontal scrolling
    private var isHorizontalScrolling: Bool = false
    /// Flag the index of the list will appear
    private var willAppearIndex: Int = -1
    /// Flag the index of the list will disappear
    private var willDisappearIndex: Int = -1
    /// Whether it is in changing horizontal contentOffset
    private var isChangingHorizontalOffset: Bool = false

    /// Initializer
    public init(dataSource: PagingViewDataSource? = nil) {
        self.dataSource = dataSource

        super.init(frame: .zero)

        setup()
    }

    @available(*, unavailable)
    public required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func layoutSubviews() {
        super.layoutSubviews()

        let bounds = self.bounds
        guard !bounds.isEmpty else {
            return
        }
        if listCollectionView.frame != bounds {
            listCollectionView.frame = bounds
            if isListLoaded {
                reloadForBoundsChange()
            } else {
                reloadData()
            }
        }
        reloadListView(bounds)
    }

    /// Reload paging view.
    public func reloadData() {
        currentListScrollView = nil
        currentHeaderContainerViewY = 0
        isSyncListContentOffsetEnabled = false
        isListLoaded = true

        listHeaderDict.values.forEach { $0.removeFromSuperview() }
        listHeaderDict.removeAll()
        for list in listDict.values {
            list.listView().removeFromSuperview()
        }
        listDict.removeAll()
        for observation in scrollViewObservations {
            observation.invalidate()
        }
        scrollViewObservations.removeAll()
        reloadHeaderView()
        listCollectionView.setContentOffsetIfNeeded(
            CGPoint(x: bounds.width * CGFloat(currentIndex), y: 0)
        )
        listCollectionView.reloadData()
        DispatchQueue.main.async {
            self.listWillAppear(at: self.currentIndex)
            self.listDidAppear(at: self.currentIndex)
        }
    }

    /// Reload headerView, called when headerView height changes.
    public func reloadHeaderView() {
        headerView?.removeFromSuperview()
        segmentedView?.removeFromSuperview()
        headerView = dataSource?.headerView(in: self)
        segmentedView = dataSource?.segmentedView(in: self)
        if let headerView = headerView {
            headerContainerView.addSubview(headerView)
        }
        if let segmentedView = segmentedView {
            headerContainerView.addSubview(segmentedView)
        }
        reloadHeaderHeights()
        reloadHeaderContainerView()
    }

    /// Reload segmentedView, called when segmentedView height changes.
    public func reloadSegmentedView() {
        segmentedView = dataSource?.segmentedView(in: self)
        if let segmentedView = segmentedView {
            headerContainerView.addSubview(segmentedView)
        }
        reloadHeaderHeights()
        reloadHeaderContainerView()
    }

    /// Scroll to idle
    public func scrollToIdle(_ animated: Bool = true) {
        currentListScrollView?.setContentOffset(
            CGPoint(x: 0, y: -headerContainerHeight),
            animated: animated
        )
    }

    /// Scroll to pinned position
    public func scrollToPinned(_ animated: Bool = true) {
        currentListScrollView?.setContentOffset(
            CGPoint(x: 0, y: -(segmentedHeight + segmentedOffsetY)),
            animated: animated
        )
    }

    // MARK: - Privates

    private func setup() {
        listCollectionView.dataSource = self
        listCollectionView.delegate = self
        listCollectionView.isPagingEnabled = true
        listCollectionView.bounces = false
        listCollectionView.showsHorizontalScrollIndicator = false
        listCollectionView.showsVerticalScrollIndicator = false
        listCollectionView.scrollsToTop = false
        listCollectionView.isPrefetchingEnabled = false
        listCollectionView.contentInsetAdjustmentBehavior = .never
        listCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        listCollectionView.headerContainerView = headerContainerView
        addSubview(listCollectionView)
        addSubview(headerContainerView)
    }

    private func observeContentOffset(_ scrollView: UIScrollView, newOffset _: CGPoint) {
        guard scrollView.window != nil else {
            return
        }
        listDidScroll(scrollView: scrollView)
    }

    private func observeContentSize(_ scrollView: UIScrollView, newSize _: CGSize) {
        guard scrollView.window != nil else {
            return
        }
        let minContentHeight = bounds.height - segmentedHeight - segmentedOffsetY
        let contentHeight = scrollView.contentSize.height
        if minContentHeight > contentHeight, isFillContentSizeAutomatically {
            scrollView.contentSize = CGSize(
                width: scrollView.contentSize.width,
                height: minContentHeight
            )
            // Reset contentOffset when the new scrollView is first loaded
            if let listScrollView = currentListScrollView {
                if scrollView != listScrollView, scrollView.contentSize != .zero {
                    scrollView.setContentOffsetIfNeeded(
                        CGPoint(x: 0, y: currentListInitailzeContentOffsetY)
                    )
                }
            }
        } else {
            if minContentHeight > contentHeight {
                scrollView.setContentOffsetIfNeeded(
                    CGPoint(x: scrollView.contentOffset.x, y: -headerContainerHeight)
                )
                listDidScroll(scrollView: scrollView)
            }
        }
    }

    private func listDidScroll(scrollView: UIScrollView) {
        if listCollectionView.isDragging || listCollectionView.isDecelerating { return }
        let index = listIndex(for: scrollView)
        guard index == currentIndex else {
            return
        }
        currentListScrollView = scrollView
        let contentOffsetY = scrollView.contentOffset.y + headerContainerHeight
        if contentOffsetY < (headerHeight - segmentedOffsetY) {
            isSyncListContentOffsetEnabled = true
            currentHeaderContainerViewY = -contentOffsetY
            for list in listDict.values {
                let listScrollView = list.listScrollView()
                if listScrollView != scrollView {
                    listScrollView.setContentOffsetIfNeeded(scrollView.contentOffset)
                }
                if listScrollView.showsVerticalScrollIndicator {
                    let contentOffsetY = listScrollView.contentOffset.y + headerContainerHeight
                    var indicatorInsets = listScrollView.verticalScrollIndicatorInsets
                    indicatorInsets.top = listScrollView.contentInset.top - contentOffsetY
                    listScrollView.verticalScrollIndicatorInsets = indicatorInsets
                }
            }
            let header = listHeader(for: scrollView)
            if headerContainerView.superview != header {
                moveHeaderContainerView(to: header, y: 0)
            }
        } else {
            if headerContainerView.superview != self {
                moveHeaderContainerView(to: self, y: -(headerHeight - segmentedOffsetY))
            }
            if isSyncListContentOffsetEnabled {
                isSyncListContentOffsetEnabled = false
                currentHeaderContainerViewY = -(headerHeight - segmentedOffsetY)
                for list in listDict.values {
                    if list.listScrollView() != currentListScrollView {
                        list.listScrollView().setContentOffsetIfNeeded(
                            CGPoint(x: 0, y: -(segmentedHeight + segmentedOffsetY))
                        )
                    }
                }
            }
        }

        let contentOffset = CGPoint(x: scrollView.contentOffset.x, y: contentOffsetY)
        delegate?.pagingViewCurrentListViewDidScroll(
            self,
            scrollView: scrollView,
            contentOffset: contentOffset
        )
    }

    private func reloadHeaderContainerView() {
        let bounds = self.bounds
        headerContainerView.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: headerContainerHeight
        )
        headerView?.frame = CGRect(
            x: 0,
            y: 0,
            width: bounds.width,
            height: headerHeight
        )
        segmentedView?.frame = CGRect(
            x: 0,
            y: headerHeight,
            width: bounds.width,
            height: segmentedHeight
        )

        for list in listDict.values {
            let listScrollView = list.listScrollView()
            var insets = listScrollView.contentInset
            insets.top = headerContainerHeight
            listScrollView.contentInset = insets
            listScrollView.setContentOffsetIfNeeded(
                CGPoint(x: 0, y: -headerContainerHeight)
            )
        }
    }

    private func moveHeaderContainerView(to view: UIView?, y: CGFloat) {
        guard let view else {
            return
        }
        headerContainerView.frame = CGRect(
            x: 0,
            y: y,
            width: bounds.width,
            height: headerContainerHeight
        )
        view.addSubview(headerContainerView)
    }

    private func reloadForBoundsChange() {
        reloadHeaderHeights()
        reloadHeaderContainerView()
        listCollectionView.collectionViewLayout.invalidateLayout()
        listCollectionView.setContentOffsetIfNeeded(
            CGPoint(x: bounds.width * CGFloat(currentIndex), y: 0)
        )
        listCollectionView.reloadData()
        if let currentListScrollView = currentListScrollView {
            listDidScroll(scrollView: currentListScrollView)
        }
    }

    private func reloadHeaderHeights() {
        if let headerView = headerView {
            let heightForHeader = dataSource?.heightForHeaderView(in: self)
            if heightForHeader == PagingView.automaticDimension {
                let targetSize = CGSize(
                    width: bounds.width,
                    height: UIView.layoutFittingCompressedSize.height
                )
                let previousBounds = headerView.bounds
                if previousBounds.width != bounds.width {
                    headerView.bounds = CGRect(origin: .zero, size: CGSize(width: bounds.width, height: previousBounds.height))
                }
                headerView.setNeedsLayout()
                headerView.layoutIfNeeded()
                headerHeight = headerView.systemLayoutSizeFitting(
                    targetSize,
                    withHorizontalFittingPriority: .required,
                    verticalFittingPriority: .fittingSizeLevel
                ).height
            } else {
                headerHeight = heightForHeader ?? 0
            }
        } else {
            headerHeight = 0
        }
        if let segmentedView = segmentedView {
            let heightForSegmented = dataSource?.heightForSegmentedView(in: self)
            segmentedHeight = heightForSegmented ?? segmentedView.bounds.height
        } else {
            segmentedHeight = 0
        }
        headerContainerHeight = headerHeight + segmentedHeight
        segmentedOffsetY = dataSource?.offsetYForSegmentedView(in: self) ?? 0
    }

    private func reloadListView(_ bounds: CGRect) {
        for list in listDict.values {
            var listFrame = list.listView().frame
            if listFrame.size != bounds.size {
                listFrame.size = bounds.size
                list.listView().frame = listFrame
            }
        }
        for header in listHeaderDict.values {
            var headerFrame = header.frame
            headerFrame.origin.y = -headerContainerHeight
            headerFrame.size.height = headerContainerHeight
            header.frame = headerFrame
        }
    }

    private func horizontalScrollDidEnd(at index: Int) {
        currentIndex = index
        guard let listHeader = listHeaderDict[index],
              let listScrollView = listDict[index]?.listScrollView()
        else {
            return
        }
        currentListScrollView = listScrollView
        for list in listDict.values {
            list.listScrollView().scrollsToTop = (list.listScrollView() == listScrollView)
        }
        if listScrollView.contentOffset.y <= -(segmentedHeight + segmentedOffsetY) {
            moveHeaderContainerView(to: listHeader, y: 0)
        }
        let minContentSizeHeight = bounds.height - segmentedHeight - segmentedOffsetY
        if minContentSizeHeight > listScrollView.contentSize.height,
           !isFillContentSizeAutomatically
        {
            listScrollView.setContentOffsetIfNeeded(
                CGPoint(x: listScrollView.contentOffset.x, y: -headerContainerHeight)
            )
            listDidScroll(scrollView: listScrollView)
        }
    }

    private func listHeader(for listScrollView: UIScrollView) -> UIView? {
        for (index, list) in listDict {
            if list.listScrollView() == listScrollView {
                return listHeaderDict[index]
            }
        }
        return nil
    }

    private func listIndex(for listScrollView: UIScrollView) -> Int {
        for (index, list) in listDict {
            if list.listScrollView() == listScrollView {
                return index
            }
        }
        return 0
    }

    private func listWillAppear(at index: Int) {
        guard isValidIndex(index) else { return }
        let list = listDict[index]
        list?.listViewWillAppear(index)
    }

    private func listDidAppear(at index: Int) {
        guard isValidIndex(index) else { return }
        currentIndex = index
        let list = listDict[index]
        list?.listViewDidAppear(index)
        if let listScrollView = list?.listScrollView(),
           listScrollView.showsVerticalScrollIndicator
        {
            listScrollView.flashScrollIndicators()
        }
    }

    private func listWillDisappear(at index: Int) {
        guard isValidIndex(index) else { return }
        let list = listDict[index]
        list?.listViewWillDisappear(index)
    }

    private func listDidDisappear(at index: Int) {
        guard isValidIndex(index) else { return }
        let list = listDict[index]
        list?.listViewDidDisappear(index)
    }

    private func isValidIndex(_ index: Int) -> Bool {
        guard let dataSource = dataSource else { return false }
        let count = dataSource.numberOfLists(in: self)
        if count <= 0 || index >= count {
            return false
        }
        return true
    }

    private func listDidAppearOrDidDisappear(_ scrollView: UIScrollView) {
        let currentIndexPercent = scrollView.contentOffset.x / max(scrollView.bounds.width, 1)
        if willAppearIndex != -1, willDisappearIndex != -1 {
            let appearIndex = willAppearIndex
            let disappearIndex = willDisappearIndex
            if willAppearIndex > willDisappearIndex {
                // The list that will appear is on the right
                if currentIndexPercent >= CGFloat(willAppearIndex) {
                    willDisappearIndex = -1
                    willAppearIndex = -1
                    listDidDisappear(at: disappearIndex)
                    listDidAppear(at: appearIndex)
                }
            } else {
                // The list that will appear is on the left
                if currentIndexPercent <= CGFloat(willAppearIndex) {
                    willDisappearIndex = -1
                    willAppearIndex = -1
                    listDidDisappear(at: disappearIndex)
                    listDidAppear(at: appearIndex)
                }
            }
        }
    }
}

extension PagingView: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    public func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        guard let dataSource = dataSource else {
            return 0
        }
        return isListLoaded ? dataSource.numberOfLists(in: self) : 0
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let dataSource = dataSource else {
            return UICollectionViewCell()
        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        var list = listDict[indexPath.item]
        if list == nil {
            list = dataSource.pagingView(self, initListAtIndex: indexPath.item)
            if let listVC = list as? UIViewController {
                var next: UIResponder? = superview
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
            listDict[indexPath.item] = list
            list.listView().setNeedsLayout()

            let listScrollView = list.listScrollView()
            listScrollView.contentInsetAdjustmentBehavior = .never
            listScrollView.automaticallyAdjustsScrollIndicatorInsets = false

            let minContentHeight = bounds.height - segmentedHeight - segmentedOffsetY
            if listScrollView.contentSize.height < minContentHeight && isFillContentSizeAutomatically {
                listScrollView.contentSize = CGSize(width: bounds.width, height: minContentHeight)
            }

            var insets = listScrollView.contentInset
            insets.top = headerContainerHeight
            listScrollView.contentInset = insets
            currentListInitailzeContentOffsetY = -headerContainerHeight + min(-currentHeaderContainerViewY, headerHeight - segmentedOffsetY)
            listScrollView.setContentOffsetIfNeeded(
                CGPoint(x: 0, y: currentListInitailzeContentOffsetY)
            )
            let listHeader = UIView(
                frame: CGRect(
                    x: 0,
                    y: -headerContainerHeight,
                    width: bounds.width,
                    height: headerContainerHeight
                )
            )
            listScrollView.addSubview(listHeader)

            if headerContainerView.superview == nil {
                listHeader.addSubview(headerContainerView)
            }
            listHeaderDict[indexPath.item] = listHeader
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
            scrollViewObservations.append(contentsOf: [
                offsetObservation,
                sizeObservation,
            ])
            listScrollView.contentOffset = listScrollView.contentOffset
            if listScrollView.showsVerticalScrollIndicator {
                let contentOffsetY = listScrollView.contentOffset.y + headerContainerHeight
                var indicatorInsets = listScrollView.verticalScrollIndicatorInsets
                indicatorInsets.top = listScrollView.contentInset.top - contentOffsetY
                listScrollView.verticalScrollIndicatorInsets = indicatorInsets
            }
        }
        for cachedList in listDict.values {
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
        layout _: UICollectionViewLayout,
        sizeForItemAt _: IndexPath
    ) -> CGSize {
        return collectionView.bounds.size
    }

    public func scrollViewWillBeginDragging(_: UIScrollView) {
        listCollectionView.willBeginDraggingHandler?()
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        delegate?.pagingViewDidScroll(self, horizontalScrollView: listCollectionView)
        let indexPercent = scrollView.contentOffset.x / max(scrollView.bounds.width, 1)
        let index = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        isHorizontalScrolling = true

        let listScrollView = listDict[index]?.listScrollView()
        if index != currentIndex,
           indexPercent - CGFloat(index) == 0,
           !(scrollView.isTracking || scrollView.isDecelerating),
           listScrollView?.contentOffset.y ?? 0 <= -(segmentedHeight + segmentedOffsetY)
        {
            horizontalScrollDidEnd(at: index)
        } else {
            // When scrolling left and right, add headerContainerView to self to achieve the floating effect
            if headerContainerView.superview != self {
                moveHeaderContainerView(to: self, y: currentHeaderContainerViewY)
            }
        }

        let percent = scrollView.contentOffset.x / max(scrollView.bounds.width, 1)
        let maxCount = Int(round(scrollView.contentSize.width / max(scrollView.bounds.width, 1)))
        var leftIndex = Int(floor(Double(percent)))
        leftIndex = max(0, min(maxCount - 1, leftIndex))
        let rightIndex = leftIndex + 1
        if percent < 0 || rightIndex >= maxCount {
            listDidAppearOrDidDisappear(scrollView)
            return
        }
        if rightIndex == currentIndex {
            // The currently selected item is on the right, and the user is sliding from right to left
            if listDict[leftIndex] != nil {
                if willAppearIndex == -1 {
                    willAppearIndex = leftIndex
                    listWillAppear(at: willAppearIndex)
                }
            }
            if willDisappearIndex == -1 {
                willDisappearIndex = rightIndex
                listWillDisappear(at: willDisappearIndex)
            }
        } else {
            // The currently selected item is on the left, and the user is sliding from left to right
            if listDict[rightIndex] != nil {
                if willAppearIndex == -1 {
                    willAppearIndex = rightIndex
                    listWillAppear(at: willAppearIndex)
                }
            }
            if willDisappearIndex == -1 {
                willDisappearIndex = leftIndex
                listWillDisappear(at: leftIndex)
            }
        }
        listDidAppearOrDidDisappear(scrollView)
    }

    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // When scrolling to the middle and then cancel the scrolls.
            if willDisappearIndex != -1 {
                listWillAppear(at: willDisappearIndex)
                listWillDisappear(at: willAppearIndex)
                listDidAppear(at: willDisappearIndex)
                listDidDisappear(at: willAppearIndex)
                willDisappearIndex = -1
                willAppearIndex = -1
            }
            let index = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
            horizontalScrollDidEnd(at: index)
        }
    }

    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        // When scrolling to the middle and then cancel the scrolls.
        if willDisappearIndex != -1 {
            listDidAppear(at: willDisappearIndex)
            listDidDisappear(at: willAppearIndex)
            willDisappearIndex = -1
            willAppearIndex = -1
        }
        let index = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        horizontalScrollDidEnd(at: index)
    }

    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        guard isListLoaded else { return }
        let index = Int(scrollView.contentOffset.x / max(scrollView.bounds.width, 1))
        currentIndex = index
        currentListScrollView = listDict[index]?.listScrollView()
        isHorizontalScrolling = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if !self.isHorizontalScrolling, self.headerContainerView.superview == self {
                self.horizontalScrollDidEnd(at: index)
            }
        }
    }
}

/// Provides a default implementations of `PagingViewListProtocol` so that all delegate methods are optional for classes that conform to `PagingViewListProtocol`.
public extension PagingViewListProtocol {
    /// Life Cycle Method: Called when the listView will be appear.
    func listViewWillAppear(_: Int) {}

    /// Life Cycle Method: Called when the listView has been appeared.
    func listViewDidAppear(_: Int) {}

    /// Life Cycle Method: Called when the listView will be disappear.
    func listViewWillDisappear(_: Int) {}

    /// Life Cycle Method: Called when the listView has been disappeared.
    func listViewDidDisappear(_: Int) {}
}

/// Provides a default implementations of `PagingViewDataSource` so that all delegate methods are optional for classes that conform to `PagingViewDataSource`.
public extension PagingViewDataSource {
    /// Returns the default height of headerView.
    func heightForHeaderView(in _: PagingView) -> CGFloat {
        return PagingView.automaticDimension
    }

    /// Returns the default additional vertical offset of the segmented view.
    func offsetYForSegmentedView(in _: PagingView) -> CGFloat {
        return 0
    }
}

/// Provides a default implementations of `PagingViewDelegate` so that all delegate methods are optional for classes that conform to `PagingViewDelegate`.
public extension PagingViewDelegate {
    /// Tells the delegate when the user scrolls the `PagingView`.
    func pagingViewDidScroll(_: PagingView, horizontalScrollView _: PagingCollectionView) {}

    /// Tells the delegate when the user scrolls current list scrollView.
    func pagingViewCurrentListViewDidScroll(_: PagingView, scrollView _: UIScrollView, contentOffset _: CGPoint) {}
}

private extension UIScrollView {
    /// Set contentOffset if needed.
    func setContentOffsetIfNeeded(_ offset: CGPoint) {
        if contentOffset != offset {
            setContentOffset(offset, animated: false)
        }
    }
}
