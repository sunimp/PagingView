//
//  SegmentUIKitController.swift
//  UIKitExample
//
//  Created by Sun on 2026/4/10.
//

import PagingView
import UIKit

class SegmentUIKitController: UIViewController {
    private let lists = ListType.allCases

    private let summaryView = SummaryDeckView()

    lazy var segmentedView: SegmentedView = .init()

    lazy var listContainerView: SegmentedListContainerView = .init()

    let dataSource = SegmentedTitleDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1)
        configureSegmentedView()
        configureContent()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.systemGreen,
        ]
        navigationController?.navigationBar.tintColor = .systemGreen
    }

    private func configureSegmentedView() {
        dataSource.titles = lists.map(\.title)
        dataSource.titleNormalColor = UIColor.black.withAlphaComponent(0.48)
        dataSource.titleSelectedColor = .systemGreen
        dataSource.titleNormalFont = .systemFont(ofSize: 14, weight: .semibold)
        dataSource.titleSelectedFont = .systemFont(ofSize: 14, weight: .bold)
        dataSource.itemSpacing = 18

        segmentedView.backgroundColor = .white
        segmentedView.layer.cornerRadius = 18
        segmentedView.clipsToBounds = true
        segmentedView.delegate = self
        segmentedView.dataSource = dataSource

        let indicator = SegmentedIndicatorLineView()
        indicator.indicatorColor = .systemGreen
        indicator.indicatorHeight = 3
        indicator.indicatorWidthIncrement = 20
        segmentedView.indicators = [indicator]
        navigationItem.titleView = segmentedView
        segmentedView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            segmentedView.widthAnchor.constraint(equalToConstant: min(UIUtils.screenWidth * 0.72, 320)),
            segmentedView.heightAnchor.constraint(equalToConstant: 42),
        ])
    }

    private func configureContent() {
        view.addSubview(summaryView)
        summaryView.translatesAutoresizingMaskIntoConstraints = false

        listContainerView.dataSource = self
        listContainerView.backgroundColor = .clear
        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        listContainerView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            summaryView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            summaryView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            summaryView.topAnchor.constraint(equalTo: view.topAnchor, constant: UIUtils.topBarHeight + 12),

            listContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            listContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            listContainerView.topAnchor.constraint(equalTo: summaryView.bottomAnchor, constant: 12),
            listContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }
}

extension SegmentUIKitController: SegmentedViewContainerDataSource {
    func numberOfLists(in _: SegmentedListContainerView) -> Int {
        lists.count
    }

    func listContainerView(_: SegmentedListContainerView, initListAt index: Int) -> any SegmentedViewListProtocol {
        ShowcasePageController(listType: lists[index], mode: .detached)
    }
}

extension SegmentUIKitController: SegmentedViewDelegate {
    func segmentedView(_: SegmentedView, didSelectedItemAt _: Int) {}
}

extension SegmentUIKitController {
    final class SummaryDeckView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup() {
            let titleLabel = UILabel()
            titleLabel.text = "Detached Segment Lab"
            titleLabel.font = .systemFont(ofSize: 30, weight: .bold)
            titleLabel.textColor = .label

            let subtitleLabel = UILabel()
            subtitleLabel.text = "分段固定在导航栏，内容区完全独立滚动，更适合工具型或目录型信息架构。"
            subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
            subtitleLabel.textColor = .secondaryLabel
            subtitleLabel.numberOfLines = 0

            let metrics = UIStackView()
            metrics.axis = .horizontal
            metrics.spacing = 12
            metrics.distribution = .fillEqually
            [
                makeMetricCard(title: "Mode", value: "Detached", tone: .systemGreen),
                makeMetricCard(title: "Tempo", value: "Fast", tone: .systemOrange),
                makeMetricCard(title: "Cards", value: "Mixed", tone: .systemPink),
            ].forEach(metrics.addArrangedSubview)

            let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, metrics])
            stack.axis = .vertical
            stack.spacing = 12
            stack.translatesAutoresizingMaskIntoConstraints = false
            addSubview(stack)

            backgroundColor = .white
            layer.cornerRadius = 24
            layer.cornerCurve = .continuous
            layer.shadowColor = UIColor.black.withAlphaComponent(0.05).cgColor
            layer.shadowOpacity = 1
            layer.shadowRadius = 16
            layer.shadowOffset = CGSize(width: 0, height: 8)

            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 18),
                stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -18),
                stack.topAnchor.constraint(equalTo: topAnchor, constant: 18),
                stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            ])
        }

        private func makeMetricCard(title: String, value: String, tone: UIColor) -> UIView {
            let titleLabel = UILabel()
            titleLabel.text = title
            titleLabel.font = .systemFont(ofSize: 11, weight: .bold)
            titleLabel.textColor = .secondaryLabel

            let valueLabel = UILabel()
            valueLabel.text = value
            valueLabel.font = .systemFont(ofSize: 17, weight: .bold)
            valueLabel.textColor = tone

            let stack = UIStackView(arrangedSubviews: [titleLabel, valueLabel])
            stack.axis = .vertical
            stack.spacing = 4

            let container = UIView()
            container.backgroundColor = tone.withAlphaComponent(0.1)
            container.layer.cornerRadius = 16
            container.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false

            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 12),
                stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -12),
                stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
                stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            ])

            return container
        }
    }
}
