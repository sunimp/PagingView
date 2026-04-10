//
//  TableViewCell.swift
//  PagingView
//
//  Created by Sun on 2024/8/2.
//

import UIKit
import SwiftUI

class TableViewCell<Content: View>: UITableViewCell {
    
    private var hostingController: UIHostingController<Content>?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setup()
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
        self.selectionStyle = .none
    }
    
    func setHostingView(_ rootView: Content) {
        self.hostingController?.view.removeFromSuperview()
        self.hostingController = nil
        
        let hosting = UIHostingController(rootView: rootView)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor)
        ])
        self.hostingController = hosting
    }
}
