//
//  RootViewController.swift
//  PagingView-Example
//
//  Created by Sun on 2024/7/26.
//

import UIKit

class RootViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "PagingView-UIKit"
        view.backgroundColor = .systemBackground
        
        let pagingUIKitItem = Item(
            title: "PagingView",
            image: UIImage(systemName: "uiwindow.split.2x1"),
            color: .systemBlue,
            action: { [weak self] title in
                guard let self else { return }
                
                self.handlePagingUIKitAction(title)
            }
        )
        
        let segmentUIKitItem = Item(
            title: "SegmentedView",
            image: UIImage(systemName: "uiwindow.split.2x1"),
            color: .systemGreen,
            action: { [weak self] title in
                guard let self else { return }
                
                self.handleSegmentUIKitAction(title)
            }
        )
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        stackView.addArrangedSubview(pagingUIKitItem)
        stackView.addArrangedSubview(segmentUIKitItem)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            stackView.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 20),
            stackView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black
        ]
        self.navigationController?.navigationBar.tintColor = .black
    }
    
    @objc
    func handlePagingUIKitAction(_ title: String) {
        let vc = PagingUIKitController()
        vc.title = title
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc
    func handleSegmentUIKitAction(_ title: String) {
        let vc = SegmentUIKitController()
        vc.title = title
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension RootViewController {
    
    class Item: UIView {
        
        let title: String
        let image: UIImage?
        let color: UIColor
        let action: ((String) -> Void)
        
        init(title: String, image: UIImage?, color: UIColor, action: @escaping ((String) -> Void)) {
            self.title = title
            self.image = image
            self.color = color
            self.action = action
            
            super.init(frame: .zero)
            
            setup()
        }
        
        @available(*, unavailable)
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        func setup() {
            
            let button = UIButton(configuration: self.customConfiguration())
            button.addTarget(self, action: #selector(handleTap), for: .touchUpInside)
            addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                button.topAnchor.constraint(equalTo: self.topAnchor),
                button.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
        
        @objc
        func handleTap(_ sender: UIButton) {
            self.action(self.title)
        }
        
        func customConfiguration() -> UIButton.Configuration {
            var configuration = UIButton.Configuration.filled()
            configuration.title = self.title
            configuration.titleAlignment = .center
            
            configuration.image = self.image
            configuration.imagePadding = 12
            configuration.imagePlacement = .leading
            
            configuration.baseBackgroundColor = self.color
            configuration.baseForegroundColor = .white
            
            configuration.background.strokeColor = .systemGray4
            configuration.background.strokeWidth = 2
            
            configuration.cornerStyle = .medium
            
            configuration.contentInsets = NSDirectionalEdgeInsets(
                top: 12,
                leading: 32,
                bottom: 12,
                trailing: 32
            )
            
            return configuration
        }
    }
}


