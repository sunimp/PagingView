//
//  RootViewController.swift
//  PagingView-Example
//
//  Created by Sun on 2024/7/26.
//

import SwiftUI
import UIKit

class RootViewController: UIViewController {
    private let scrollView = UIScrollView()
    private let contentStackView = UIStackView()

    private lazy var demoSections: [DemoSection] = [
        DemoSection(
            title: "UIKit",
            subtitle: "原生控制器、吸顶头图和滚动联动",
            accentColor: .systemBlue,
            items: [
                DemoItem(
                    title: "Paging Header Studio",
                    subtitle: "大头图、吸顶分段、滚动状态和命令式控制",
                    icon: "rectangle.topthird.inset.filled",
                    accentColor: .systemBlue,
                    badges: ["Header", "Pinned", "PagingView"],
                    action: { [weak self] in
                        self?.makePagingUIKitController() ?? UIViewController()
                    }
                ),
                DemoItem(
                    title: "Detached Segment Lab",
                    subtitle: "导航栏分段与内容容器分离，突出组合灵活度",
                    icon: "square.split.2x1",
                    accentColor: .systemGreen,
                    badges: ["Detached", "Container", "SegmentedView"],
                    action: { [weak self] in
                        self?.makeSegmentUIKitController() ?? UIViewController()
                    }
                ),
            ]
        ),
        DemoSection(
            title: "SwiftUI",
            subtitle: "基于 SwiftUI 封装的三种接入方式",
            accentColor: .systemOrange,
            items: [
                DemoItem(
                    title: "Editorial Pager",
                    subtitle: "用 `PagerView` 组合头图、频道分段与内容流",
                    icon: "sparkles.tv",
                    accentColor: .systemOrange,
                    badges: ["SwiftUI", "PagerView", "Hero"],
                    action: { [weak self] in
                        self?.makeSwiftUIPagerController() ?? UIViewController()
                    }
                ),
                DemoItem(
                    title: "Combined Segment Canvas",
                    subtitle: "一个视图内组合分段与列表，适合高密度内容切换",
                    icon: "rectangle.3.group.bubble.left",
                    accentColor: .systemPink,
                    badges: ["SwiftUI", "Combined", "Compact"],
                    action: { [weak self] in
                        self?.makeSwiftUICombinedSegmentController() ?? UIViewController()
                    }
                ),
                DemoItem(
                    title: "Toolbar Segment Deck",
                    subtitle: "分段驻留顶部工具栏，内容区域完全独立",
                    icon: "menubar.rectangle",
                    accentColor: .systemRed,
                    badges: ["SwiftUI", "Detached", "Toolbar"],
                    action: { [weak self] in
                        self?.makeSwiftUIDetachedSegmentController() ?? UIViewController()
                    }
                ),
            ]
        ),
    ]

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "PagingView Demo"
        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1)

        setupScrollView()
        setupContent()
    }

    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = true
        scrollView.showsVerticalScrollIndicator = false

        contentStackView.axis = .vertical
        contentStackView.spacing = 24
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            contentStackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor, constant: 20),
            contentStackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor, constant: -20),
            contentStackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 16),
            contentStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor, constant: -32),
            contentStackView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -40),
        ])
    }

    private func setupContent() {
        contentStackView.addArrangedSubview(makeHeroView())
        demoSections
            .map(makeSectionView(section:))
            .forEach(contentStackView.addArrangedSubview)
    }

    private func makeHeroView() -> UIView {
        let container = UIView()
        container.isUserInteractionEnabled = false
        container.layer.cornerRadius = 28
        container.layer.masksToBounds = true

        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.12, green: 0.18, blue: 0.34, alpha: 1).cgColor,
            UIColor(red: 0.23, green: 0.46, blue: 0.95, alpha: 1).cgColor,
            UIColor(red: 0.48, green: 0.71, blue: 0.99, alpha: 1).cgColor,
        ]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        container.layer.insertSublayer(gradient, at: 0)

        let titleLabel = UILabel()
        titleLabel.text = "一个 Demo，覆盖 UIKit 与 SwiftUI 两条接入路径"
        titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 0

        let subtitleLabel = UILabel()
        subtitleLabel.text = "在同一个 App 内查看 Header 吸顶、Segment 联动、SwiftUI 封装和分离式容器。"
        subtitleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.84)
        subtitleLabel.numberOfLines = 0

        let metricsStack = UIStackView()
        metricsStack.axis = .horizontal
        metricsStack.spacing = 12
        metricsStack.distribution = .fillEqually
        [
            makeMetricView(value: "5", title: "展示页"),
            makeMetricView(value: "2", title: "UI 技术栈"),
            makeMetricView(value: "1", title: "统一入口"),
        ].forEach(metricsStack.addArrangedSubview)

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, metricsStack])
        stack.axis = .vertical
        stack.spacing = 18
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 24),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24),
            container.heightAnchor.constraint(equalToConstant: 278),
        ])

        container.layoutIfNeeded()
        gradient.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width - 40, height: 278)

        return container
    }

    private func makeMetricView(value: String, title: String) -> UIView {
        let container = UIView()
        container.backgroundColor = UIColor.white.withAlphaComponent(0.12)
        container.layer.cornerRadius = 16

        let valueLabel = UILabel()
        valueLabel.text = value
        valueLabel.font = .systemFont(ofSize: 26, weight: .bold)
        valueLabel.textColor = .white

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 12, weight: .semibold)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.84)

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(stack)

        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 14),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -14),
        ])

        return container
    }

    private func makeSectionView(section: DemoSection) -> UIView {
        let titleLabel = UILabel()
        titleLabel.text = section.title
        titleLabel.font = .systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = .label

        let subtitleLabel = UILabel()
        subtitleLabel.text = section.subtitle
        subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        let cardsStack = UIStackView()
        cardsStack.axis = .vertical
        cardsStack.spacing = 14
        section.items
            .map(makeCardView(item:))
            .forEach(cardsStack.addArrangedSubview)

        let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, cardsStack])
        stack.axis = .vertical
        stack.spacing = 12
        return stack
    }

    private func makeCardView(item: DemoItem) -> UIView {
        let card = DemoCardView(item: item)
        card.onTap = { [weak self] in
            let controller = item.action()
            controller.navigationItem.largeTitleDisplayMode = .never
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        return card
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.black,
        ]
        navigationController?.navigationBar.tintColor = .black
    }

    private func makePagingUIKitController() -> UIViewController {
        let vc = PagingUIKitController()
        vc.title = "Paging Header Studio"
        return vc
    }

    private func makeSegmentUIKitController() -> UIViewController {
        let vc = SegmentUIKitController()
        vc.title = "Detached Segment Lab"
        return vc
    }

    private func makeSwiftUIPagerController() -> UIViewController {
        makeHostingController(
            title: "Editorial Pager",
            rootView: PagerViewExample(titles: ShowcaseCatalog.pagerTitles)
        )
    }

    private func makeSwiftUICombinedSegmentController() -> UIViewController {
        makeHostingController(
            title: "Combined Segment Canvas",
            rootView: SegmentViewExample1(titles: ShowcaseCatalog.combinedTitles)
        )
    }

    private func makeSwiftUIDetachedSegmentController() -> UIViewController {
        makeHostingController(
            title: "Toolbar Segment Deck",
            rootView: SegmentViewExample2(titles: ListType.allCases.map(\.title))
        )
    }

    private func makeHostingController<Content: View>(title: String, rootView: Content) -> UIViewController {
        let controller = UIHostingController(rootView: rootView)
        controller.title = title
        controller.view.backgroundColor = .systemBackground
        return controller
    }
}

extension RootViewController {
    struct DemoSection {
        let title: String
        let subtitle: String
        let accentColor: UIColor
        let items: [DemoItem]
    }

    struct DemoItem {
        let title: String
        let subtitle: String
        let icon: String
        let accentColor: UIColor
        let badges: [String]
        let action: () -> UIViewController
    }

    final class DemoCardView: UIControl {
        private let iconContainer = UIView()
        private let iconView = UIImageView()
        private let titleLabel = UILabel()
        private let subtitleLabel = UILabel()
        private let badgesStackView = UIStackView()
        private let chevronView = UIImageView()

        var onTap: (() -> Void)?

        init(item: DemoItem) {
            super.init(frame: .zero)

            setup(item: item)
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            guard self.point(inside: point, with: event) else {
                return nil
            }
            return self
        }

        private func setup(item: DemoItem) {
            backgroundColor = .white
            layer.cornerRadius = 24
            layer.cornerCurve = .continuous
            layer.shadowColor = UIColor.black.withAlphaComponent(0.08).cgColor
            layer.shadowOpacity = 1
            layer.shadowRadius = 18
            layer.shadowOffset = CGSize(width: 0, height: 12)

            iconContainer.backgroundColor = item.accentColor.withAlphaComponent(0.12)
            iconContainer.layer.cornerRadius = 18
            iconContainer.translatesAutoresizingMaskIntoConstraints = false

            iconView.image = UIImage(systemName: item.icon)
            iconView.tintColor = item.accentColor
            iconView.contentMode = .scaleAspectFit
            iconView.translatesAutoresizingMaskIntoConstraints = false
            iconContainer.addSubview(iconView)

            titleLabel.text = item.title
            titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
            titleLabel.textColor = .label
            titleLabel.numberOfLines = 0

            subtitleLabel.text = item.subtitle
            subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
            subtitleLabel.textColor = .secondaryLabel
            subtitleLabel.numberOfLines = 0

            badgesStackView.axis = .horizontal
            badgesStackView.spacing = 8
            badgesStackView.alignment = .leading
            badgesStackView.distribution = .fillProportionally
            item.badges.map { self.makeBadge(text: $0, color: item.accentColor) }.forEach(badgesStackView.addArrangedSubview)

            chevronView.image = UIImage(systemName: "arrow.up.right")
            chevronView.tintColor = item.accentColor
            chevronView.translatesAutoresizingMaskIntoConstraints = false

            let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, badgesStackView])
            textStack.axis = .vertical
            textStack.spacing = 10

            let contentStack = UIStackView(arrangedSubviews: [iconContainer, textStack, chevronView])
            contentStack.axis = .horizontal
            contentStack.alignment = .top
            contentStack.spacing = 16
            contentStack.translatesAutoresizingMaskIntoConstraints = false
            contentStack.isUserInteractionEnabled = false
            addSubview(contentStack)

            NSLayoutConstraint.activate([
                contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
                contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
                contentStack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),

                iconContainer.widthAnchor.constraint(equalToConstant: 60),
                iconContainer.heightAnchor.constraint(equalToConstant: 60),

                iconView.centerXAnchor.constraint(equalTo: iconContainer.centerXAnchor),
                iconView.centerYAnchor.constraint(equalTo: iconContainer.centerYAnchor),
                iconView.widthAnchor.constraint(equalToConstant: 26),
                iconView.heightAnchor.constraint(equalToConstant: 26),

                chevronView.widthAnchor.constraint(equalToConstant: 18),
                chevronView.heightAnchor.constraint(equalToConstant: 18),
            ])

            addTarget(self, action: #selector(handleTap), for: .touchUpInside)
        }

        private func makeBadge(text: String, color: UIColor) -> UIView {
            let label = UILabel()
            label.text = text
            label.font = .systemFont(ofSize: 11, weight: .semibold)
            label.textColor = color

            let container = UIView()
            container.backgroundColor = color.withAlphaComponent(0.12)
            container.layer.cornerRadius = 11
            container.addSubview(label)
            label.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
                label.topAnchor.constraint(equalTo: container.topAnchor, constant: 5),
                label.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -5),
            ])

            return container
        }

        @objc
        private func handleTap() {
            onTap?()
        }
    }
}
