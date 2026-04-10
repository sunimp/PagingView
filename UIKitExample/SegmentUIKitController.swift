//
//  SegmentUIKitController.swift
//  Example
//
//  Created by Sun on 2024/7/31.
//

import UIKit

import PagingView

class SegmentUIKitController: UIViewController {
    
    private let lists = ListType.allCases
    
    lazy var segmentedView: SegmentedView = {
        return SegmentedView()
    }()
    lazy var listContainerView: SegmentedListContainerView = {
        return SegmentedListContainerView()
    }()
    
    let dataSource = SegmentedTitleDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .systemBackground
        
        self.dataSource.titles = self.lists.map(\.title)
        self.dataSource.titleSelectedColor = .systemGreen
        
        self.segmentedView.backgroundColor = .white
        self.segmentedView.delegate = self
        self.segmentedView.dataSource = self.dataSource
        
        let indicator = SegmentedIndicatorLineView()
        indicator.indicatorColor = .systemGreen
        self.segmentedView.indicators = [indicator]
        self.navigationItem.titleView = self.segmentedView
        self.segmentedView.translatesAutoresizingMaskIntoConstraints = false
        
        self.listContainerView.dataSource = self
        self.segmentedView.listContainer = self.listContainerView
        self.view.addSubview(self.listContainerView)
        self.listContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.segmentedView.widthAnchor.constraint(equalToConstant: UIUtils.screenWidth * 0.5),
            self.segmentedView.heightAnchor.constraint(equalToConstant: 40),
            
            self.listContainerView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            self.listContainerView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            self.listContainerView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: UIUtils.topBarHeight),
            self.listContainerView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen
        ]
        self.navigationController?.navigationBar.tintColor = .systemGreen
    }
}

extension SegmentUIKitController: SegmentedViewContainerDataSource {
    
    func numberOfLists(in listContainerView: SegmentedListContainerView) -> Int {
        return self.dataSource.dataSource.count
    }
    
    func listContainerView(_ listContainerView: SegmentedListContainerView, initListAt index: Int) -> any SegmentedViewListProtocol {
        return ListViewController(listType: self.lists[index])
    }
}

extension SegmentUIKitController: SegmentedViewDelegate {
    // MARK: - SegmentedViewDelegate
    
    func segmentedView(_ segmentedView: SegmentedView, didSelectedItemAt index: Int) {
        print("did select: \(index)")
    }
}

extension SegmentUIKitController {
    
    class ListViewController: UIViewController,
                              SegmentedViewListProtocol,
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
