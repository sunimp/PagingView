//
//  HeaderView.swift
//  PagingView
//
//  Created by Sun on 2024/7/30.
//

import UIKit
import SwiftUI

public class HeaderView<Content: View>: UIView {
    
    private let hostingController: UIHostingController<Content>
    
    public init(_ content: Content) {
        self.hostingController = UIHostingController(rootView: content)
        super.init(frame: .zero)
        
        self.setup()
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        self.addSubview(self.hostingController.view)
        self.hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = self.hostingController.view.topAnchor.constraint(equalTo: self.topAnchor)
        topConstraint.priority = .defaultHigh
        
        NSLayoutConstraint.activate([
            self.hostingController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            self.hostingController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            topConstraint,
            self.hostingController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
