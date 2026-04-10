//
//  TableViewCell.swift
//  PagingView
//
//  Created by Sun on 2024/8/2.
//

import SwiftUI
import UIKit

class TableViewCell<Content: View>: UITableViewCell {
    private var hostingController: UIHostingController<Content>?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
    }

    func setHostingView(_ rootView: Content) {
        if let hostingController = self.hostingController {
            hostingController.rootView = rootView
            hostingController.view.invalidateIntrinsicContentSize()
            return
        }

        let hostingController = UIHostingController(rootView: rootView)
        hostingController.view.backgroundColor = .clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: contentView.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        self.hostingController = hostingController
    }
}
