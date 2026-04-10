//
//  ListContainerWappedView.swift
//  PagingView
//
//  Created by Sun on 2024/7/31.
//

import UIKit
import SwiftUI

class ListContainerWappedView<T: Hashable, C: View, L: View, N: View>: UIView,
                                                                 SegmentedViewContainerDataSource {
    let listContainerView: SegmentedListContainerView
    var pages: [Page<T, C, L, N>]
    
    var count: Int
    var foregroundColor: UIColor
    
    var onListContainer: ((SegmentedListContainerView) -> Void)?
    var onDidScroll: ((CGFloat) -> Void)?
    
    init(
        foregroundColor: UIColor,
        count: Int,
        pages: [Page<T, C, L, N>],
        onListContainer: ((SegmentedListContainerView) -> Void)?,
        onDidScroll: ((CGFloat) -> Void)?
    ) {
        self.listContainerView = SegmentedListContainerView()
        self.foregroundColor = foregroundColor
        self.count = count
        self.pages = pages
        self.onListContainer = onListContainer
        self.onDidScroll = onDidScroll
        
        super.init(frame: .zero)
        
        self.setup()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.listContainerView.dataSource = self
        self.listContainerView.backgroundColor = self.foregroundColor
        self.addSubview(self.listContainerView)
        self.listContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            self.listContainerView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.listContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            self.listContainerView.topAnchor.constraint(equalTo: self.topAnchor),
            self.listContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
    
    func reloadData() {
        self.listContainerView.backgroundColor = self.foregroundColor
        self.onListContainer?(self.listContainerView)
        self.listContainerView.reloadData()
    }
    
    // MARK: - SegmentedViewContainerDataSource
    
    func numberOfLists(in listContainerView: SegmentedListContainerView) -> Int {
        self.count
    }
    
    func listContainerView(
        _ listContainerView: SegmentedListContainerView,
        initListAt index: Int
    ) -> SegmentedViewListProtocol {
        self.pages[index]
    }
}
