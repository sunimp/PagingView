//
//  PagingUIKitController.swift
//  PagingView-Example
//
//  Created by Sun on 2026/4/10.
//

import PagingView
import UIKit

class PagingUIKitController: UIViewController {
    private let channel = ShowcaseCatalog.channel
    private let lists = ListType.allCases

    private lazy var chromeView = HeaderChromeView()
    private lazy var headerView = HeaderView(channel: self.channel)

    private var chromeHeightConstraint: NSLayoutConstraint?
    private var pinItem: UIBarButtonItem?
    private var idleItem: UIBarButtonItem?

    lazy var pagingView: PagingView = .init(dataSource: self)

    lazy var segmentedView: SegmentedView = .init()

    let dataSource = SegmentedTitleDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1)
        configurePagingView()
        configureNavigationItems()
        configureChromeView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.systemBlue,
        ]
        navigationController?.navigationBar.tintColor = .systemBlue
    }

    private func configurePagingView() {
        pagingView.delegate = self
        view.addSubview(pagingView)
        pagingView.translatesAutoresizingMaskIntoConstraints = false

        dataSource.titles = lists.map(\.title)
        dataSource.titleNormalColor = UIColor.black.withAlphaComponent(0.46)
        dataSource.titleSelectedColor = .white
        dataSource.titleNormalFont = .systemFont(ofSize: 14, weight: .semibold)
        dataSource.titleSelectedFont = .systemFont(ofSize: 14, weight: .bold)
        dataSource.itemSpacing = 18
        dataSource.itemWidthIncrement = 14

        segmentedView.backgroundColor = UIColor(red: 0.15, green: 0.18, blue: 0.27, alpha: 0.98)
        segmentedView.layer.cornerRadius = 18
        segmentedView.clipsToBounds = true
        segmentedView.delegate = self
        segmentedView.dataSource = dataSource

        let indicator = SegmentedIndicatorLineView()
        indicator.indicatorColor = .white
        indicator.indicatorHeight = 3
        indicator.indicatorWidthIncrement = 24
        segmentedView.indicators = [indicator]
        segmentedView.contentScrollView = pagingView.listCollectionView

        NSLayoutConstraint.activate([
            pagingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pagingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pagingView.topAnchor.constraint(equalTo: view.topAnchor),
            pagingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    private func configureChromeView() {
        view.addSubview(chromeView)
        chromeView.translatesAutoresizingMaskIntoConstraints = false

        let heightConstraint = chromeView.heightAnchor.constraint(equalToConstant: HeaderView.topChromeHeight)
        chromeHeightConstraint = heightConstraint

        NSLayoutConstraint.activate([
            chromeView.topAnchor.constraint(equalTo: view.topAnchor),
            chromeView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            chromeView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            heightConstraint,
        ])
    }

    private func configureNavigationItems() {
        let pinItem = UIBarButtonItem(
            title: "Pin",
            style: .plain,
            target: self,
            action: #selector(handlePinned)
        )
        self.pinItem = pinItem

        let idleItem = UIBarButtonItem(
            title: "Idle",
            style: .plain,
            target: self,
            action: #selector(handleIdle)
        )
        idleItem.isEnabled = false
        self.idleItem = idleItem

        navigationItem.rightBarButtonItems = [pinItem, idleItem]
    }

    @objc
    private func handlePinned() {
        pagingView.scrollToPinned()
    }

    @objc
    private func handleIdle() {
        pagingView.scrollToIdle()
    }
}

extension PagingUIKitController: PagingViewDataSource {
    func heightForHeaderView(in _: PagingView) -> CGFloat {
        PagingView.automaticDimension
    }

    func headerView(in _: PagingView) -> UIView {
        headerView
    }

    func heightForSegmentedView(in _: PagingView) -> CGFloat {
        52
    }

    func offsetYForSegmentedView(in _: PagingView) -> CGFloat {
        UIUtils.topBarHeight + 10
    }

    func segmentedView(in _: PagingView) -> UIView {
        segmentedView
    }

    func numberOfLists(in _: PagingView) -> Int {
        dataSource.titles.count
    }

    func pagingView(_: PagingView, initListAtIndex index: Int) -> any PagingViewListProtocol {
        let controller = ShowcasePageController(listType: lists[index], mode: .paging)
        controller.title = dataSource.titles[index]
        return controller
    }
}

extension PagingUIKitController: PagingViewDelegate {
    func pagingViewCurrentListViewDidScroll(_ pagingView: PagingView, scrollView _: UIScrollView, contentOffset: CGPoint) {
        let offsetY = contentOffset.y
        if offsetY < 0 {
            chromeHeightConstraint?.constant = HeaderView.topChromeHeight - offsetY
        } else {
            chromeHeightConstraint?.constant = HeaderView.topChromeHeight
        }

        let isIdleEnabled = offsetY > 0
        let isPinEnabled = offsetY < pagingView.pinnedOffsetY
        if isIdleEnabled != idleItem?.isEnabled {
            idleItem?.isEnabled = isIdleEnabled
        }
        if isPinEnabled != pinItem?.isEnabled {
            pinItem?.isEnabled = isPinEnabled
        }

        chromeView.updateBackground(offsetY)
    }
}

extension PagingUIKitController: SegmentedViewDelegate {
    func segmentedView(_: SegmentedView, didSelectedItemAt _: Int) {}
}

extension PagingUIKitController {
    final class HeaderView: UIView {
        static var topChromeHeight: CGFloat {
            UIUtils.topBarHeight + 18
        }

        private let channel: ShowcaseChannel

        private let gradientLayer = CAGradientLayer()
        private let badgeLabel = PaddingLabel()
        private let titleLabel = UILabel()
        private let subtitleLabel = UILabel()
        private let descriptionLabel = UILabel()
        private let artworkView = ArtworkView()
        private let metricStackView = UIStackView()
        private let footerLabel = UILabel()
        private let ctaButton = UIButton(type: .system)

        init(channel: ShowcaseChannel) {
            self.channel = channel
            super.init(frame: .zero)
            setup()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup() {
            layer.cornerRadius = 0
            layer.insertSublayer(gradientLayer, at: 0)
            gradientLayer.colors = channel.tone.gradientColors.map(\.cgColor)
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)

            badgeLabel.text = channel.subtitle.uppercased()
            badgeLabel.font = .systemFont(ofSize: 11, weight: .black)
            badgeLabel.textColor = .white
            badgeLabel.contentInsets = UIEdgeInsets(top: 7, left: 12, bottom: 7, right: 12)
            badgeLabel.backgroundColor = UIColor.white.withAlphaComponent(0.12)
            badgeLabel.layer.cornerRadius = 14
            badgeLabel.layer.masksToBounds = true

            titleLabel.text = channel.title
            titleLabel.font = .systemFont(ofSize: 32, weight: .bold)
            titleLabel.textColor = .white
            titleLabel.numberOfLines = 0

            subtitleLabel.text = channel.description
            subtitleLabel.font = .systemFont(ofSize: 14, weight: .medium)
            subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.82)
            subtitleLabel.numberOfLines = 0

            descriptionLabel.text = channel.updateNote
            descriptionLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            descriptionLabel.textColor = UIColor.white.withAlphaComponent(0.82)

            metricStackView.axis = .horizontal
            metricStackView.spacing = 12
            metricStackView.distribution = .fillEqually
            [
                channel.primaryMetric,
                channel.secondaryMetric,
                channel.tertiaryMetric,
            ].map(makeMetricView(metric:)).forEach(metricStackView.addArrangedSubview)

            footerLabel.text = channel.audience
            footerLabel.font = .systemFont(ofSize: 13, weight: .semibold)
            footerLabel.textColor = UIColor.white.withAlphaComponent(0.8)

            var configuration = UIButton.Configuration.plain()
            configuration.title = "Follow"
            configuration.baseForegroundColor = channel.tone.color
            configuration.background.backgroundColor = .white
            configuration.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 18, bottom: 10, trailing: 18)
            configuration.titleLineBreakMode = .byClipping
            ctaButton.configuration = configuration
            ctaButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .bold)
            ctaButton.titleLabel?.numberOfLines = 1
            ctaButton.setContentCompressionResistancePriority(.required, for: .horizontal)
            ctaButton.setContentHuggingPriority(.required, for: .horizontal)
            ctaButton.widthAnchor.constraint(greaterThanOrEqualToConstant: 88).isActive = true
            ctaButton.layer.cornerRadius = 18

            let textStack = UIStackView(arrangedSubviews: [
                badgeLabel,
                titleLabel,
                subtitleLabel,
                metricStackView,
            ])
            textStack.axis = .vertical
            textStack.spacing = 16

            let headerRow = UIStackView(arrangedSubviews: [textStack, artworkView])
            headerRow.axis = .horizontal
            headerRow.spacing = 20
            headerRow.alignment = .top

            let footerRow = UIStackView(arrangedSubviews: [footerLabel, UIView(), descriptionLabel, ctaButton])
            footerRow.axis = .horizontal
            footerRow.alignment = .center
            footerRow.spacing = 12
            footerLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            descriptionLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)

            let contentStack = UIStackView(arrangedSubviews: [headerRow, footerRow])
            contentStack.axis = .vertical
            contentStack.spacing = 20
            contentStack.translatesAutoresizingMaskIntoConstraints = false
            addSubview(contentStack)

            NSLayoutConstraint.activate([
                artworkView.widthAnchor.constraint(equalToConstant: 116),
                artworkView.heightAnchor.constraint(equalToConstant: 116),

                contentStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
                contentStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
                contentStack.topAnchor.constraint(equalTo: topAnchor, constant: Self.topChromeHeight + 20),
                contentStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -18),
            ])
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            gradientLayer.frame = bounds
            CATransaction.commit()
        }

        private func makeMetricView(metric: ShowcaseMetric) -> UIView {
            let valueLabel = UILabel()
            valueLabel.text = metric.value
            valueLabel.font = .systemFont(ofSize: 20, weight: .bold)
            valueLabel.textColor = .white

            let titleLabel = UILabel()
            titleLabel.text = metric.label
            titleLabel.font = .systemFont(ofSize: 11, weight: .semibold)
            titleLabel.textColor = UIColor.white.withAlphaComponent(0.78)

            let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
            stack.axis = .vertical
            stack.spacing = 4

            let container = UIView()
            container.backgroundColor = UIColor.white.withAlphaComponent(0.12)
            container.layer.cornerRadius = 18
            container.addSubview(stack)
            stack.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 14),
                stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -14),
                stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 12),
                stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -12),
            ])
            return container
        }
    }

    final class HeaderChromeView: UIView {
        private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        private let stripeLayer = CAShapeLayer()

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        private func setup() {
            addSubview(blurView)
            blurView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                blurView.leadingAnchor.constraint(equalTo: leadingAnchor),
                blurView.trailingAnchor.constraint(equalTo: trailingAnchor),
                blurView.topAnchor.constraint(equalTo: topAnchor),
                blurView.bottomAnchor.constraint(equalTo: bottomAnchor),
            ])

            layer.addSublayer(stripeLayer)
            stripeLayer.fillColor = UIColor.clear.cgColor
            stripeLayer.strokeColor = UIColor.systemBlue.withAlphaComponent(0.18).cgColor
            stripeLayer.lineWidth = 1
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            CATransaction.begin()
            CATransaction.setDisableActions(true)
            stripeLayer.frame = bounds
            let path = UIBezierPath()
            let step: CGFloat = 6
            for x in stride(from: 0 as CGFloat, through: bounds.width + 20, by: step) {
                path.move(to: CGPoint(x: x, y: 0))
                path.addLine(to: CGPoint(x: x - 20, y: bounds.height))
            }
            stripeLayer.path = path.cgPath
            CATransaction.commit()
        }

        func updateBackground(_ offsetY: CGFloat) {
            let alpha = max(0, min(1, 1 - offsetY / 140))
            stripeLayer.opacity = Float(alpha)
            blurView.alpha = max(0.15, alpha)
        }
    }

    final class ArtworkView: UIView {
        override init(frame: CGRect) {
            super.init(frame: frame)
            backgroundColor = UIColor.white.withAlphaComponent(0.14)
            layer.cornerRadius = 26
            layer.masksToBounds = true

            let bars = UIStackView()
            bars.axis = .vertical
            bars.spacing = 8
            bars.translatesAutoresizingMaskIntoConstraints = false

            for value in [32, 22, 44, 18] {
                let bar = UIView()
                bar.backgroundColor = UIColor.white.withAlphaComponent(0.85)
                bar.layer.cornerRadius = 4
                bar.translatesAutoresizingMaskIntoConstraints = false
                bar.heightAnchor.constraint(equalToConstant: CGFloat(value)).isActive = true
                bars.addArrangedSubview(bar)
            }

            addSubview(bars)
            NSLayoutConstraint.activate([
                bars.centerXAnchor.constraint(equalTo: centerXAnchor),
                bars.centerYAnchor.constraint(equalTo: centerYAnchor),
                bars.widthAnchor.constraint(equalToConstant: 26),
            ])
        }

        @available(*, unavailable)
        required init?(coder _: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}

enum ShowcasePageMode {
    case paging
    case detached
}

final class ShowcasePageController: UIViewController,
    PagingViewListProtocol,
    SegmentedViewListProtocol,
    UICollectionViewDataSource,
    UICollectionViewDelegateFlowLayout
{
    private let listType: ListType
    private let mode: ShowcasePageMode
    private let items: [ShowcaseItem]

    private let layout = UICollectionViewFlowLayout()
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: self.layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.contentInset = UIEdgeInsets(top: 12, left: 16, bottom: 24, right: 16)
        view.contentInsetAdjustmentBehavior = .never
        view.delegate = self
        view.dataSource = self
        view.alwaysBounceVertical = true
        view.register(ShowcaseCollectionCell.self, forCellWithReuseIdentifier: ShowcaseCollectionCell.reuseId)
        return view
    }()

    private var oldSize: CGSize = .zero
    private var sizes: [CGSize] = []

    init(listType: ListType, mode: ShowcasePageMode) {
        self.listType = listType
        self.mode = mode
        items = ShowcaseCatalog.items(for: listType)
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(red: 0.97, green: 0.97, blue: 0.99, alpha: 1)
        view.addSubview(collectionView)

        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        guard oldSize != view.bounds.size else {
            return
        }

        oldSize = view.bounds.size
        sizes = items.enumerated().map { index, item in
            self.size(for: item, index: index, width: self.view.bounds.width)
        }
        collectionView.reloadData()
    }

    private func size(for item: ShowcaseItem, index _: Int, width: CGFloat) -> CGSize {
        let contentWidth = width - 32
        switch listType {
        case .recent:
            switch item.style {
            case .hero:
                return CGSize(width: contentWidth, height: 320)
            case .editorial:
                return CGSize(width: contentWidth, height: 228)
            case .compact:
                return CGSize(width: contentWidth, height: 154)
            case .stat:
                return CGSize(width: contentWidth, height: 176)
            case .mosaic:
                return CGSize(width: contentWidth, height: 220)
            }
        case .nearby:
            let spacing: CGFloat = 12
            let itemWidth = floor((contentWidth - spacing) / 2)
            return CGSize(width: itemWidth, height: mode == .paging ? 220 : 236)
        case .all:
            return CGSize(width: contentWidth, height: mode == .paging ? 158 : 172)
        }
    }

    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        items.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: ShowcaseCollectionCell.reuseId,
            for: indexPath
        ) as? ShowcaseCollectionCell else {
            return UICollectionViewCell()
        }
        cell.configure(item: items[indexPath.item], listType: listType, mode: mode)
        return cell
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        sizes[indexPath.item]
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumLineSpacingForSectionAt _: Int
    ) -> CGFloat {
        listType == .nearby ? 12 : 16
    }

    func collectionView(
        _: UICollectionView,
        layout _: UICollectionViewLayout,
        minimumInteritemSpacingForSectionAt _: Int
    ) -> CGFloat {
        listType == .nearby ? 12 : 0
    }

    func listView() -> UIView {
        view
    }

    func listScrollView() -> UIScrollView {
        collectionView
    }

    func listViewWillAppear(_: Int) {}
    func listViewDidAppear(_: Int) {}
    func listViewWillDisappear(_: Int) {}
    func listViewDidDisappear(_: Int) {}
    func listWillAppear() {}
    func listDidAppear() {}
    func listWillDisappear() {}
    func listDidDisappear() {}
}

private final class ShowcaseCollectionCell: UICollectionViewCell {
    static let reuseId = "ShowcaseCollectionCell"

    private let cardView = UIView()
    private let artworkView = UIView()
    private let artworkGradient = CAGradientLayer()
    private let badgeStackView = UIStackView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let noteLabel = UILabel()
    private let metricStackView = UIStackView()
    private var artworkHeightConstraint: NSLayoutConstraint?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        artworkGradient.frame = artworkView.bounds
    }

    private func setup() {
        contentView.backgroundColor = .clear

        cardView.backgroundColor = .white
        cardView.layer.cornerRadius = 24
        cardView.layer.cornerCurve = .continuous
        cardView.layer.shadowColor = UIColor.black.withAlphaComponent(0.06).cgColor
        cardView.layer.shadowOpacity = 1
        cardView.layer.shadowRadius = 14
        cardView.layer.shadowOffset = CGSize(width: 0, height: 8)
        cardView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(cardView)

        artworkView.layer.cornerRadius = 20
        artworkView.layer.masksToBounds = true
        artworkView.translatesAutoresizingMaskIntoConstraints = false
        artworkView.layer.addSublayer(artworkGradient)

        badgeStackView.axis = .horizontal
        badgeStackView.spacing = 8
        badgeStackView.alignment = .leading

        titleLabel.font = .systemFont(ofSize: 21, weight: .bold)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        subtitleLabel.font = .systemFont(ofSize: 13, weight: .medium)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        noteLabel.font = .systemFont(ofSize: 13, weight: .semibold)
        noteLabel.textColor = .label
        noteLabel.numberOfLines = 0

        metricStackView.axis = .horizontal
        metricStackView.spacing = 8
        metricStackView.distribution = .fillEqually

        let stack = UIStackView(arrangedSubviews: [
            artworkView,
            badgeStackView,
            titleLabel,
            subtitleLabel,
            noteLabel,
            metricStackView,
        ])
        stack.axis = .vertical
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false
        cardView.addSubview(stack)

        artworkHeightConstraint = artworkView.heightAnchor.constraint(equalToConstant: 120)
        artworkHeightConstraint?.isActive = true

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            stack.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: cardView.bottomAnchor, constant: -16),
        ])
    }

    func configure(item: ShowcaseItem, listType: ListType, mode: ShowcasePageMode) {
        artworkGradient.colors = item.tone.gradientColors.map(\.cgColor)
        artworkGradient.startPoint = CGPoint(x: 0, y: 0)
        artworkGradient.endPoint = CGPoint(x: 1, y: 1)

        titleLabel.text = item.title
        subtitleLabel.text = item.subtitle
        noteLabel.text = item.note

        badgeStackView.removeAllArrangedSubviews()
        item.badges.prefix(3).map { self.makeBadge(text: $0, tone: item.tone) }.forEach(badgeStackView.addArrangedSubview)

        metricStackView.removeAllArrangedSubviews()
        item.metrics.prefix(listType == .nearby ? 2 : 3).map { self.makeMetricView(metric: $0, tone: item.tone) }.forEach(metricStackView.addArrangedSubview)

        switch listType {
        case .recent:
            artworkHeightConstraint?.constant = item.style == .hero ? 170 : 112
        case .nearby:
            artworkHeightConstraint?.constant = 92
        case .all:
            artworkHeightConstraint?.constant = mode == .paging ? 84 : 92
        }
    }

    private func makeBadge(text: String, tone: ShowcaseTone) -> UIView {
        let label = PaddingLabel()
        label.text = text
        label.font = .systemFont(ofSize: 11, weight: .bold)
        label.textColor = tone.color
        label.contentInsets = UIEdgeInsets(top: 5, left: 10, bottom: 5, right: 10)
        label.backgroundColor = tone.softColor
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        return label
    }

    private func makeMetricView(metric: ShowcaseMetric, tone: ShowcaseTone) -> UIView {
        let valueLabel = UILabel()
        valueLabel.text = metric.value
        valueLabel.font = .systemFont(ofSize: 15, weight: .bold)
        valueLabel.textColor = .label

        let titleLabel = UILabel()
        titleLabel.text = metric.label
        titleLabel.font = .systemFont(ofSize: 10, weight: .semibold)
        titleLabel.textColor = .secondaryLabel

        let stack = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        stack.axis = .vertical
        stack.spacing = 3

        let container = UIView()
        container.backgroundColor = tone.softColor
        container.layer.cornerRadius = 14
        container.addSubview(stack)
        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 10),
            stack.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: container.topAnchor, constant: 10),
            stack.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -10),
        ])
        return container
    }
}

private final class PaddingLabel: UILabel {
    var contentInsets = UIEdgeInsets.zero

    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: contentInsets))
    }

    override var intrinsicContentSize: CGSize {
        let size = super.intrinsicContentSize
        return CGSize(
            width: size.width + contentInsets.left + contentInsets.right,
            height: size.height + contentInsets.top + contentInsets.bottom
        )
    }
}

private extension UIStackView {
    func removeAllArrangedSubviews() {
        for view in arrangedSubviews {
            removeArrangedSubview(view)
            view.removeFromSuperview()
        }
    }
}
