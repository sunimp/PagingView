//
//  TableView.swift
//  PagingView
//
//  Created by Sun on 2024/7/29.
//

import UIKit
import SwiftUI

class TableView<T: Hashable, C: View, L: View, N: View>: UIView,
                                                         UITableViewDataSource,
                                                         UITableViewDelegate {
    
    private let data: [T]?
    private let item: (Int, T) -> C
    private let loadingView: () -> L
    private let noDataView: () -> N
    private let didScroll: ((CGFloat) -> Void)?
    
    let internalTableView = NoSafeAreaInsetsTableView(frame: .zero)
    
    init(
        data: [T]?,
        @ViewBuilder item: @escaping (Int, T) -> C,
        @ViewBuilder loadingView: @escaping () -> L,
        @ViewBuilder noDataView: @escaping () -> N,
        didScroll: ((CGFloat) -> Void)?
    ) {
        self.data = data
        self.item = item
        self.loadingView = loadingView
        self.noDataView = noDataView
        self.didScroll = didScroll
        
        super.init(frame: .zero)
        
        self.setup()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addSubview(self.internalTableView)
        self.internalTableView.dataSource = self
        self.internalTableView.delegate = self
        self.internalTableView.separatorStyle = .none
        self.internalTableView.rowHeight = UITableView.automaticDimension
        self.internalTableView.isPrefetchingEnabled = false
        self.internalTableView.contentInsetAdjustmentBehavior = .never
        
        self.internalTableView.register(TableViewCell<C>.self, forCellReuseIdentifier: "Item")
        self.internalTableView.register(TableViewCell<L>.self, forCellReuseIdentifier: "LoadingView")
        self.internalTableView.register(TableViewCell<N>.self, forCellReuseIdentifier: "NoDataView")
        
        self.internalTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            self.internalTableView.topAnchor.constraint(equalTo: self.topAnchor),
            self.internalTableView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            self.internalTableView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.internalTableView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
    }
    
    func reloadData() {
        self.internalTableView.reloadData()
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let data = self.data, !data.isEmpty else {
            return 1
        }
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let data = self.data else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LoadingView", for: indexPath) as? TableViewCell<L> else {
                return UITableViewCell()
            }
            cell.setHostingView(self.loadingView())
            return cell
        }
        if !data.isEmpty {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "Item", for: indexPath) as? TableViewCell<C> else {
                return UITableViewCell()
            }
            let item = data[indexPath.row]
            cell.setHostingView(self.item(indexPath.row, item))
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NoDataView", for: indexPath) as? TableViewCell<N> else {
                return UITableViewCell()
            }
            cell.setHostingView(self.noDataView())
            return cell
        }
    }
    
    // MARK: - UITableViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.didScroll?(scrollView.contentOffset.y)
    }
}

class NoSafeAreaInsetsTableView: UITableView {
    
    override var safeAreaInsets: UIEdgeInsets {
        .zero
    }
}
