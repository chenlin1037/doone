import Combine
import Foundation
import SwiftUI

final class StatisticsViewModel: ObservableObject {
    enum Period: CaseIterable, Identifiable {
        case week, month, year, total
        var id: Self { self }
        var title: String {
            switch self {
            case .week: return String(localized: "周")
            case .month: return String(localized: "月")
            case .year: return String(localized: "年")
            case .total: return String(localized: "总计")
            }
        }

        var daysBack: Int? {
            switch self {
            case .week: return 6
            case .month: return 29
            case .year: return 364
            case .total: return nil
            }
        }
    }

    enum ActivityFilter: CaseIterable, Identifiable {
        case all, masturbation, sex
        var id: Self { self }
        var title: String {
            switch self {
            case .all: return String(localized: "全部")
            case .masturbation: return String(localized: "自慰")
            case .sex: return String(localized: "性生活")
            }
        }
    }

    // MARK: - 统计模型

    struct Statistics {
        let filteredActivities: [SexActivity]
        let durationSummary: DurationSummary //持续时间
        let timeOfDay: [TimeOfDayBucket]
        let locations: [CategoryStat]
        let partners: [CategoryStat]
    }

    struct DurationSummary {
        let min: TimeInterval?
        let max: TimeInterval?
        let average: TimeInterval?

        var isEmpty: Bool {
            min == nil && max == nil && average == nil
        }
    }

    struct TimeOfDayBucket: Identifiable {
        let id: Int
        let label: String
        let count: Int
        let timeRange: String

        init(id: Int, label: String, count: Int) {
            self.id = id
            self.label = label
            self.count = count

            // 添加具体时间范围
            let ranges = [String(localized: "0-6时"), String(localized: "6-12时"), String(localized: "12-18时"), String(localized: "18-24时")]
            timeRange = ranges[id]
        }
    }

    struct CategoryStat: Identifiable {
        let name: String
        let count: Int
        let percentage: Double
        var id: String { name }

        init(name: String, count: Int, total: Int) {
            self.name = name
            self.count = count
            percentage = total > 0 ? Double(count) / Double(total) * 100 : 0
        }
    }

    @Published var selectedPeriod: Period = .week
    @Published var selectedActivityFilter: ActivityFilter = .all

    // MARK: - 主计算逻辑

    func computeStatistics(from activities: [SexActivity]) -> Statistics {
        let filtered = filterActivities(activities)
        let total = filtered.count

        return Statistics(
            filteredActivities: filtered,
            durationSummary: calculateDurationSummary(filtered),
            timeOfDay: calculateTimeOfDay(filtered),
            locations: calculateCategory(filtered, total: total) { $0.location ?? String(localized: "无") },
            partners: calculateCategory(filtered, total: total) { $0.partner?.name ?? String(localized: "匿名") }
        )
    }

    // MARK: - 过滤逻辑

    private func filterActivities(_ activities: [SexActivity]) -> [SexActivity] {
        // 先按类型过滤
        let typeFiltered = activities.filter { act in
            switch selectedActivityFilter {
            case .all: return true
            case .masturbation: return act.isMasturbation
            case .sex: return !act.isMasturbation
            }
        }

        // 再按时间范围过滤
        guard let days = selectedPeriod.daysBack else { return typeFiltered }
        let calendar = Calendar.current
        let now = Date()
        guard let startDate = calendar.date(byAdding: .day, value: -days, to: now) else {
            return typeFiltered
        }

        let startOfDay = calendar.startOfDay(for: startDate)
        return typeFiltered.filter { $0.date >= startOfDay }
    }

    // MARK: - 时长统计

    private func calculateDurationSummary(_ activities: [SexActivity]) -> DurationSummary {
        let durations = activities.compactMap { activity -> TimeInterval? in
            guard let endDate = activity.endDate,
                  endDate > activity.date
            else {
                return nil
            }
            return endDate.timeIntervalSince(activity.date)
        }

        guard !durations.isEmpty else {
            return DurationSummary(min: nil, max: nil, average: nil)
        }

        let min = durations.min()
        let max = durations.max()
        let average = durations.reduce(0, +) / Double(durations.count)

        return DurationSummary(min: min, max: max, average: average)
    }

    // MARK: - 时段分布

    private func calculateTimeOfDay(_ activities: [SexActivity]) -> [TimeOfDayBucket] {
        var counts = [0, 0, 0, 0] // 凌晨、上午、下午、晚上
        let labels = [String(localized: "凌晨"), String(localized: "上午"), String(localized: "下午"), String(localized: "晚上")]

        for activity in activities {
            let hour = Calendar.current.component(.hour, from: activity.date)
            let bucketIndex = min(hour / 6, 3)
            counts[bucketIndex] += 1
        }

        return counts.enumerated().map { index, count in
            TimeOfDayBucket(id: index, label: labels[index], count: count)
        }.filter { $0.count > 0 } // 只返回有数据的时段
    }

    // MARK: - 分类统计（地点、伴侣等）

    private func calculateCategory(
        _ activities: [SexActivity],
        total: Int,
        extractor: (SexActivity) -> String
    ) -> [CategoryStat] {
        let grouped = Dictionary(grouping: activities, by: extractor)

        return grouped.map { name, items in
            CategoryStat(name: name, count: items.count, total: total)
        }
        .sorted { $0.count > $1.count }
    }

    // MARK: - 格式化辅助

    func formattedDuration(_ interval: TimeInterval?) -> String {
        guard let interval = interval, interval > 0 else { return "--" }

        let totalMinutes = Int(interval / 60)
        let hours = totalMinutes / 60
        let minutes = totalMinutes % 60

        if hours > 0 {
            return minutes > 0 ? "\(hours)h\(minutes)m" : "\(hours)h"
        } else {
            return "\(minutes)min"
        }
    }

    func formattedPercentage(_ value: Double) -> String {
        return String(format: "%.1f%%", value)
    }
}
