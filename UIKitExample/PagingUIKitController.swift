//
//  PagingUIKitController.swift
//  PagingView-Example
//
//  Created by Sun on 2024/7/26.
//

import UIKit

import PagingView

class PagingUIKitController: UIViewController {
    
    private lazy var stripeView = StripedView()
    private lazy var headerView = HeaderView()
    private let lists = ListType.allCases
    
    private var stripeHeightConstraint: NSLayoutConstraint?
    private var pinItem: UIBarButtonItem?
    private var idleItem: UIBarButtonItem?
    
    lazy var pagingView: PagingView = {
        return PagingView(dataSource: self)
    }()
    
    lazy var segmentedView: SegmentedView = {
        return SegmentedView()
    }()
    
    let dataSource = SegmentedTitleDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        self.pagingView.delegate = self
        self.view.addSubview(self.pagingView)
        self.pagingView.translatesAutoresizingMaskIntoConstraints = false
        
        self.dataSource.titles = self.lists.map(\.title)
        
        self.segmentedView.backgroundColor = .white
        self.segmentedView.delegate = self
        self.segmentedView.dataSource = self.dataSource
        
        let indicator = SegmentedIndicatorLineView()
        self.segmentedView.indicators = [indicator]
        
        self.segmentedView.contentScrollView = self.pagingView.listCollectionView
        
        self.view.addSubview(self.stripeView)
        self.stripeView.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint =
        stripeView.heightAnchor.constraint(equalToConstant: HeaderView.stripeDefaultHeight)
        self.stripeHeightConstraint = heightConstraint
        
        NSLayoutConstraint.activate([
            self.stripeView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.stripeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.stripeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            heightConstraint,
            
            self.pagingView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.pagingView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.pagingView.topAnchor.constraint(equalTo: self.view.topAnchor),
            self.pagingView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
        
        let pinItem = UIBarButtonItem(
            title: "Pin",
            style: .plain,
            target: self,
            action: #selector(handlePinned)
        )
        self.pinItem = pinItem
        let idleItem = UIBarButtonItem(
            title:"Idle",
            style: .plain,
            target: self,
            action: #selector(handleIdle)
        )
        self.idleItem = idleItem
        idleItem.isEnabled = false
        self.navigationItem.rightBarButtonItems = [pinItem, idleItem]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue
        ]
        self.navigationController?.navigationBar.tintColor = .systemBlue
    }
    
    @objc
    private func handlePinned() {
        self.pagingView.scrollToPinned()
    }
    
    @objc
    private func handleIdle() {
        self.pagingView.scrollToIdle()
    }
    
}

extension PagingUIKitController: PagingViewDataSource {
    // MARK: - PagingViewDataSource
    
    func heightForHeaderView(in pagingView: PagingView) -> CGFloat {
        return PagingView.automaticDimension
    }
    
    func headerView(in pagingView: PagingView) -> UIView {
        self.headerView.update()
        return self.headerView
    }
    
    func heightForSegmentedView(in pagingView: PagingView) -> CGFloat {
        return 50
    }
    
    func offsetYForSegmentedView(in pagingView: PagingView) -> CGFloat {
        return UIUtils.topBarHeight
    }
    
    func segmentedView(in pagingView: PagingView) -> UIView {
        return self.segmentedView
    }
    
    func numberOfLists(in pagingView: PagingView) -> Int {
        return self.dataSource.titles.count
    }
    
    func pagingView(_ pagingView: PagingView, initListAtIndex index: Int) -> any PagingViewListProtocol {
        let vc = ListViewController(listType: self.lists[index])
        vc.title = self.dataSource.titles[index]
        return vc
    }
}

extension PagingUIKitController: PagingViewDelegate {
    // MARK: - PagingViewDelegate
    
    func pagingViewCurrentListViewDidScroll(_ pagingView: PagingView, scrollView: UIScrollView, contentOffset: CGPoint) {
        let offsetY = contentOffset.y
        if offsetY < 0 {
            self.stripeHeightConstraint?.constant = HeaderView.stripeDefaultHeight - offsetY
        } else {
            self.stripeHeightConstraint?.constant = HeaderView.stripeDefaultHeight
        }
        let isIdleEnabled = offsetY > 0
        let isPinEnabled = offsetY < pagingView.pinnedOffsetY
        if isIdleEnabled != self.idleItem?.isEnabled {
            self.idleItem?.isEnabled = isIdleEnabled
        }
        if isPinEnabled != self.pinItem?.isEnabled {
            self.pinItem?.isEnabled = isPinEnabled
        }
        self.stripeView.updateBackground(offsetY)
    }
}

extension PagingUIKitController: SegmentedViewDelegate {
    // MARK: - SegmentedViewDelegate
    
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        print("did select: \(index)")
    }
}

extension PagingUIKitController {
    
    class HeaderView: UIView {
        
        static var stripeDefaultHeight: CGFloat {
            UIUtils.topBarHeight + 20
        }
        
        private let titleLabel = UILabel()
        private let subtitleLabel = UILabel()
        
        private let coverView = UIImageView()
        private let subscriptionsLabel = UILabel()
        private lazy var subscribeButton = UIButton(configuration: self.subscribe())
        
        private var titleTopConstraint: NSLayoutConstraint?
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            self.setup()
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            
            titleLabel.font = .systemFont(ofSize: 24, weight: .semibold)
            titleLabel.textColor = .black
            addSubview(titleLabel)
            titleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            subtitleLabel.font = .systemFont(ofSize: 15)
            subtitleLabel.textColor = .systemGray
            subtitleLabel.numberOfLines = 0
            addSubview(subtitleLabel)
            subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
            
            subscriptionsLabel.font = .systemFont(ofSize: 15, weight: .medium)
            subscriptionsLabel.textColor = .black
            addSubview(subscriptionsLabel)
            subscriptionsLabel.translatesAutoresizingMaskIntoConstraints = false
            
            coverView.contentMode = .scaleAspectFit
            coverView.layer.cornerRadius = 2
            coverView.layer.masksToBounds = true
            addSubview(coverView)
            coverView.translatesAutoresizingMaskIntoConstraints = false
            
            subscribeButton.layer.cornerRadius = 2
            addSubview(subscribeButton)
            subscribeButton.translatesAutoresizingMaskIntoConstraints = false
            
            let bottomConstraint = subscribeButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -10)
            bottomConstraint.priority = .defaultHigh
            let topConstraint = titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: Self.stripeDefaultHeight + 20)
            self.titleTopConstraint = topConstraint
            NSLayoutConstraint.activate([
                titleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
                topConstraint,
                titleLabel.trailingAnchor.constraint(greaterThanOrEqualTo: coverView.leadingAnchor, constant: -10),
                
                subtitleLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
                subtitleLabel.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor, constant: 8),
                
                coverView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
                coverView.topAnchor.constraint(equalTo: self.titleLabel.bottomAnchor),
                coverView.widthAnchor.constraint(equalToConstant: 72),
                coverView.heightAnchor.constraint(equalToConstant: 72),
                
                subscribeButton.trailingAnchor.constraint(equalTo: self.coverView.trailingAnchor),
                subscribeButton.topAnchor.constraint(equalTo: coverView.bottomAnchor, constant: 24),
                bottomConstraint,
                
                subscriptionsLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
                subscriptionsLabel.centerYAnchor.constraint(equalTo: self.subscribeButton.centerYAnchor)
            ])
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.titleTopConstraint?.constant = Self.stripeDefaultHeight + 20
        }
        
        func update() {
            titleLabel.text = "Vibration Sound Room"
            subtitleLabel.text = "Too much music, too few ears"
            coverView.backgroundColor = .systemBlue
            subscriptionsLabel.text = "\(Int.random(in: 100000...200000)) Subscribers"
            subscribeButton.setTitle("+ Subscribe", for: .normal)
        }
        
        private func subscribe() -> UIButton.Configuration {
            var configuration = UIButton.Configuration.filled()
            configuration.titleAlignment = .center
            
            configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
                var outgoing = incoming
                outgoing.font = .systemFont(ofSize: 15)
                outgoing.foregroundColor = .white
                return outgoing
            }
            
            configuration.baseBackgroundColor = .black
            configuration.baseForegroundColor = .white
            
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: 6,
                leading: 32,
                bottom: 6,
                trailing: 32
            )
            return configuration
        }
    }
    
    class StripedView: UIView {
        
        class StripeView: UIView {
            
            var stripeColor: UIColor = UIColor(displayP3Red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
            var stripeWidth: CGFloat = 4.0
            
            override func draw(_ rect: CGRect) {
                super.draw(rect)
                guard let context = UIGraphicsGetCurrentContext() else { return }
                context.setFillColor(stripeColor.cgColor)
                
                let numberOfStripes = Int(rect.width / stripeWidth)
                for index in 0..<numberOfStripes {
                    let offsetX = CGFloat(index) * stripeWidth
                    let stripeRect = CGRect(x: offsetX, y: 0, width: stripeWidth / 2, height: rect.height)
                    context.fill(stripeRect)
                }
            }
        }
        
        private let backgroundView = UIView()
        private let stripeView = StripeView()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            setup()
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            
            self.addSubview(self.backgroundView)
            self.backgroundView.backgroundColor = .white
            
            self.stripeView.backgroundColor = .white
            self.stripeView.stripeColor = .systemBlue.withAlphaComponent(0.1)
            self.addSubview(self.stripeView)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            
            self.stripeView.frame = self.bounds
            self.backgroundView.frame = CGRect(
                x: 0,
                y: 0,
                width: self.bounds.width,
                height: UIUtils.topBarHeight
            )
        }
        
        func updateBackground(_ offsetY: CGFloat) {
            var alpha: CGFloat = 1
            if offsetY >= 0 {
                alpha = 1 - (abs(offsetY) / (HeaderView.stripeDefaultHeight - UIUtils.topBarHeight))
            }
            alpha = min(max(alpha, 0), 1)
            self.stripeView.alpha = alpha
        }
    }
    
    class ListViewController: UIViewController,
                              PagingViewListProtocol,
                              UICollectionViewDataSource,
                              UICollectionViewDelegateFlowLayout {
        
        let numberOfItems = 50
        var randomCellStyle: CellStyle {
            return Bool.random() ? .solid : .translucent
        }
        
        lazy var style: [CellStyle] = { (0..<self.numberOfItems).map { _ in self.randomCellStyle } }()
        
        private var oldSize: CGSize = .zero
        var sizes: [CGSize] = []
        
        var insets: UIEdgeInsets {
            return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
        lazy var layout = UICollectionViewFlowLayout()
        
        lazy var collectionView: UICollectionView = {
            
            let view = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .clear
            view.delegate = self
            view.dataSource = self
            view.register(CollectionViewCell.self, forCellWithReuseIdentifier: CollectionViewCell.reuseId)
            
            return view
        }()
        
        private let listType: ListType
        
        init(listType: ListType) {
            self.listType = listType
            super.init(nibName: nil, bundle: nil)
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            title = listType.title
            view.backgroundColor = .white
            view.clipsToBounds = true
            collectionView.contentInsetAdjustmentBehavior = .never
            view.addSubview(collectionView)
            
            NSLayoutConstraint.activate([
                collectionView.topAnchor.constraint(equalTo: view.topAnchor),
                collectionView.leftAnchor.constraint(equalTo: view.leftAnchor),
                collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
                collectionView.rightAnchor.constraint(equalTo: view.rightAnchor)
            ])
        }
        
        override func viewWillLayoutSubviews() {
            super.viewWillLayoutSubviews()
            
            let size = self.view.bounds.size
            if self.oldSize != size {
                let width = size.width
                self.oldSize = size
                let listType = self.listType
                self.sizes = (0..<self.numberOfItems).map { _ in
                    switch listType {
                    case .recent:
                        return CGSize(
                            width: width - 20,
                            height: max(CGFloat.random(in: 40...100), 0)
                        )
                    case .nearby:
                        return CGSize(
                            width: floor((width - (5 * 10)) / 4),
                            height: floor((width - (5 * 10)) / 4)
                        )
                        
                    case .all:
                        return CGSize(width: width - 20, height: 64)
                    }
                }
                self.collectionView.reloadData()
            }
        }
        
        func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return self.numberOfItems
        }
        
        func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            return collectionView.dequeueReusableCell(withReuseIdentifier: CollectionViewCell.reuseId, for: indexPath)
        }
        
        func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
            guard let cell = cell as? CollectionViewCell else { return }
            cell.setCell(style: style[indexPath.item], listType: self.listType)
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            return self.sizes[indexPath.item]
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
            return self.insets
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
            return self.listType == .nearby ? 10 : 0
        }
        
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
            return self.listType == .nearby ? 10 : 0
        }
        
        func listView() -> UIView {
            return self.view
        }
        
        func listScrollView() -> UIScrollView {
            return self.collectionView
        }
        
        func listViewWillAppear(_ index: Int) { 
            print("list will appear at: \(index)")
        }
        
        func listViewDidAppear(_ index: Int) {
            print("list did appear at: \(index)")
        }
        
        func listViewWillDisappear(_ index: Int) {
            print("list will disappear at: \(index)")
        }
        
        func listViewDidDisappear(_ index: Int) {
            print("list did disappear at: \(index)")
        }
    }
    
    class CollectionViewCell: UICollectionViewCell {
        
        static let reuseId: String = "Cell"
        
        lazy var top: NSLayoutConstraint = self.background.topAnchor.constraint(equalTo: self.contentView.topAnchor)
        lazy var left: NSLayoutConstraint = self.background.leftAnchor.constraint(equalTo: self.contentView.leftAnchor)
        lazy var bottom: NSLayoutConstraint = self.background.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor)
        lazy var right: NSLayoutConstraint = self.background.rightAnchor.constraint(equalTo: self.contentView.rightAnchor)
        
        func setCell(style: CellStyle, listType: ListType) {
            background.backgroundColor = style.backgroundColor(for: listType)
            let insets = style.insets(for: listType)
            
            top.constant = insets.top
            left.constant = insets.left
            bottom.constant = insets.bottom
            right.constant = insets.right
            
        }
        
        lazy var background: UIView = {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 15
            view.clipsToBounds = true
            
            return view
        }()
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            
            contentView.backgroundColor = nil
            contentView.addSubview(background)
            
            NSLayoutConstraint.activate([top, left, bottom, right])
        }
    }
}
