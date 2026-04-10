//
//  ListType.swift
//  UIKitExample
//
//  Created by Sun on 2026/4/10.
//

import UIKit

enum ListType: CaseIterable {
    case recent
    case nearby
    case all

    var title: String {
        switch self {
        case .recent:
            return "Pulse"
        case .nearby:
            return "Nearby"
        case .all:
            return "Library"
        }
    }

    var subtitle: String {
        switch self {
        case .recent:
            return "最新策展、作者手记与高热度长文"
        case .nearby:
            return "地点、社群与轻量活动卡片"
        case .all:
            return "归档收藏、清单与完整目录"
        }
    }

    var tone: ShowcaseTone {
        switch self {
        case .recent:
            return .cobalt
        case .nearby:
            return .mint
        case .all:
            return .coral
        }
    }
}

enum ShowcaseTone: CaseIterable, Hashable {
    case cobalt
    case mint
    case amber
    case coral
    case plum
    case slate

    var color: UIColor {
        switch self {
        case .cobalt:
            return UIColor(red: 0.19, green: 0.36, blue: 0.86, alpha: 1)
        case .mint:
            return UIColor(red: 0.12, green: 0.67, blue: 0.54, alpha: 1)
        case .amber:
            return UIColor(red: 0.89, green: 0.57, blue: 0.12, alpha: 1)
        case .coral:
            return UIColor(red: 0.9, green: 0.35, blue: 0.38, alpha: 1)
        case .plum:
            return UIColor(red: 0.46, green: 0.27, blue: 0.76, alpha: 1)
        case .slate:
            return UIColor(red: 0.25, green: 0.31, blue: 0.41, alpha: 1)
        }
    }

    var softColor: UIColor {
        color.withAlphaComponent(0.12)
    }

    var mutedColor: UIColor {
        color.withAlphaComponent(0.2)
    }

    var gradientColors: [UIColor] {
        switch self {
        case .cobalt:
            return [
                UIColor(red: 0.11, green: 0.19, blue: 0.43, alpha: 1),
                UIColor(red: 0.2, green: 0.4, blue: 0.88, alpha: 1),
            ]
        case .mint:
            return [
                UIColor(red: 0.07, green: 0.28, blue: 0.22, alpha: 1),
                UIColor(red: 0.16, green: 0.71, blue: 0.58, alpha: 1),
            ]
        case .amber:
            return [
                UIColor(red: 0.44, green: 0.23, blue: 0.02, alpha: 1),
                UIColor(red: 0.94, green: 0.65, blue: 0.17, alpha: 1),
            ]
        case .coral:
            return [
                UIColor(red: 0.42, green: 0.09, blue: 0.13, alpha: 1),
                UIColor(red: 0.92, green: 0.42, blue: 0.45, alpha: 1),
            ]
        case .plum:
            return [
                UIColor(red: 0.19, green: 0.1, blue: 0.34, alpha: 1),
                UIColor(red: 0.55, green: 0.35, blue: 0.86, alpha: 1),
            ]
        case .slate:
            return [
                UIColor(red: 0.14, green: 0.16, blue: 0.21, alpha: 1),
                UIColor(red: 0.34, green: 0.4, blue: 0.49, alpha: 1),
            ]
        }
    }
}

enum ShowcaseItemStyle: Hashable {
    case hero
    case editorial
    case compact
    case stat
    case mosaic
}

struct ShowcaseMetric: Hashable {
    let label: String
    let value: String
}

struct ShowcaseItem: Hashable, Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let note: String
    let badges: [String]
    let metrics: [ShowcaseMetric]
    let tone: ShowcaseTone
    let style: ShowcaseItemStyle
}

struct ShowcaseChannel: Hashable {
    let title: String
    let subtitle: String
    let description: String
    let audience: String
    let updateNote: String
    let primaryMetric: ShowcaseMetric
    let secondaryMetric: ShowcaseMetric
    let tertiaryMetric: ShowcaseMetric
    let tone: ShowcaseTone
}

enum ShowcaseCatalog {
    static let pagerTitles = [
        "Featured",
        "Sessions",
        "Interviews",
        "Signals",
        "Collections",
        "Archive",
    ]

    static let combinedTitles = [
        "Highlights",
        "Momentum",
        "Community",
        "Notes",
        "Vault",
    ]

    static let channel = ShowcaseChannel(
        title: "Editorial Signal Room",
        subtitle: "Curated paging playground",
        description: "把头图吸顶、频道切换、异构列表与内容节奏放进同一页，直接展示 `PagingView` 在真实内容场景里的层次表达。",
        audience: "186K followers",
        updateNote: "Updated 12 minutes ago",
        primaryMetric: ShowcaseMetric(label: "Playlists", value: "24"),
        secondaryMetric: ShowcaseMetric(label: "Writers", value: "18"),
        tertiaryMetric: ShowcaseMetric(label: "Depth", value: "A+"),
        tone: .cobalt
    )

    private static let titlePool = [
        "Late Signal Dispatch",
        "Monochrome Memory",
        "Quiet Club Manifesto",
        "Analog Futures",
        "Field Notes from Orbit",
        "Room Tone Index",
        "Night Shift Study",
        "Portable Rituals",
        "Archive of Small Scenes",
        "Pattern Language 03",
        "Pocket Broadcast",
        "Dense Air Bulletin",
    ]

    private static let subtitlePool = [
        "Long-form notes with structured pull quotes and editorial spacing.",
        "Compact updates tuned for rapid scanning and quick transitions.",
        "A layered card set built for pinned headers and segmented switching.",
        "Tighter summaries for toolbars, detached tabs and dense lists.",
        "A softer visual rhythm for immersive pager content.",
        "Grid-friendly capsules for nearby collections and quick browsing.",
    ]

    private static let notePool = [
        "Updated for this week’s curation sweep.",
        "Built to show variable card heights cleanly.",
        "Pairs well with a sticky summary strip.",
        "Useful when switching quickly between tabs.",
        "A good fit for mixed media and narrative sections.",
        "Highlights visual weight changes during segmented transitions.",
    ]

    private static let badgePool = [
        "Editor Pick",
        "Live",
        "Deep Dive",
        "Field",
        "Draft",
        "Club",
        "Ambient",
        "Pinned",
        "Fresh",
        "Focus",
        "Archive",
        "Studio",
    ]

    static func pagerItems(for title: String) -> [ShowcaseItem] {
        let seed = self.seed(for: title, in: pagerTitles)
        return makeItems(
            seed: seed,
            count: 9,
            leadTone: ShowcaseTone.allCases[seed % ShowcaseTone.allCases.count],
            baseBadges: ["Pager"]
        )
    }

    static func combinedItems(for title: String) -> [ShowcaseItem] {
        let seed = self.seed(for: title, in: combinedTitles) + 2
        return makeItems(
            seed: seed,
            count: 8,
            leadTone: ShowcaseTone.allCases[(seed + 1) % ShowcaseTone.allCases.count],
            baseBadges: ["Combined"]
        )
    }

    static func items(for listType: ListType) -> [ShowcaseItem] {
        switch listType {
        case .recent:
            return makeItems(seed: 1, count: 9, leadTone: listType.tone, baseBadges: ["Pulse"])
        case .nearby:
            return makeItems(seed: 4, count: 12, leadTone: listType.tone, baseBadges: ["Nearby"])
        case .all:
            return makeItems(seed: 7, count: 10, leadTone: listType.tone, baseBadges: ["Library"])
        }
    }

    static func heroMetrics(for title: String) -> [ShowcaseMetric] {
        let seed = self.seed(for: title, in: pagerTitles + combinedTitles)
        return [
            ShowcaseMetric(label: "Stories", value: "\(8 + seed)"),
            ShowcaseMetric(label: "Writers", value: "\(3 + seed % 6)"),
            ShowcaseMetric(label: "Tempo", value: ["Calm", "Dense", "Mixed"][seed % 3]),
        ]
    }

    private static func seed(for title: String, in titles: [String]) -> Int {
        titles.firstIndex(of: title) ?? 0
    }

    private static func makeItems(
        seed: Int,
        count: Int,
        leadTone: ShowcaseTone,
        baseBadges: [String]
    ) -> [ShowcaseItem] {
        let tones = ShowcaseTone.allCases
        let styles: [ShowcaseItemStyle] = [.hero, .editorial, .compact, .stat, .mosaic]

        return (0 ..< count).map { index in
            let poolIndex = (seed * 3 + index) % self.titlePool.count
            let title = self.titlePool[poolIndex]
            let subtitle = self.subtitlePool[(seed + index) % self.subtitlePool.count]
            let note = self.notePool[(seed * 2 + index) % self.notePool.count]
            let tone = index == 0 ? leadTone : tones[(seed + index + 1) % tones.count]
            let style = styles[min(index, styles.count - 1)]
            let badges = Array((baseBadges + self.makeBadges(seed: seed, index: index)).prefix(3))
            let metrics = self.makeMetrics(seed: seed, index: index)

            return ShowcaseItem(
                id: "\(seed)-\(index)-\(title)",
                title: title,
                subtitle: subtitle,
                note: note,
                badges: badges,
                metrics: metrics,
                tone: tone,
                style: style
            )
        }
    }

    private static func makeBadges(seed: Int, index: Int) -> [String] {
        [
            badgePool[(seed + index) % badgePool.count],
            badgePool[(seed + index + 3) % badgePool.count],
        ]
    }

    private static func makeMetrics(seed: Int, index: Int) -> [ShowcaseMetric] {
        let read = 3 + ((seed + index) % 7)
        let saves = 18 + ((seed * 11 + index * 7) % 64)
        let pace = ["Soft", "Fast", "Layered", "Focused"][(seed + index) % 4]

        return [
            ShowcaseMetric(label: "Read", value: "\(read) min"),
            ShowcaseMetric(label: "Saves", value: "\(saves)"),
            ShowcaseMetric(label: "Pace", value: pace),
        ]
    }
}
