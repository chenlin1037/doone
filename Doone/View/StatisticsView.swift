import Charts
import SwiftData
import SwiftUI

// MARK: - View

struct StatisticsView: View {
    @Query(sort: \SexActivity.date, order: .reverse)
    private var activities: [SexActivity]

    @StateObject private var viewModel = StatisticsViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if activities.isEmpty {
                    emptyState
                } else {
                    statisticsContent
                }
            }
            .navigationTitle("统计")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    activityFilterMenu
                }
            }
            .background(Color(.systemGroupedBackground))
        }
    }

    private var statisticsContent: some View {
        let stats = viewModel.computeStatistics(from: activities)

        return ScrollView {
            VStack(spacing: 16) {
                // 周期切换器
                Picker("周期", selection: $viewModel.selectedPeriod.animation(.spring())) {
                    ForEach(StatisticsViewModel.Period.allCases) { period in
                        Text(period.title).tag(period)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)

                VStack(spacing: 16) {
                    // 1. 数据概览卡片
                    overviewCard(stats: stats)

                    // 3. 时长分析
                    durationSummarySection(summary: stats.durationSummary)

                    // 4. 时段分布（饼图）
                    if !stats.timeOfDay.isEmpty {
                        timeOfDayChartSection(stats.timeOfDay)
                    }

                    // 5. 地点统计
                    if !stats.locations.isEmpty {
                        categoryListSection(
                            title: String(localized: "地点统计"),
                            data: stats.locations,
                            icon: "location.fill"
                        )
                    }

                    // 6. 伴侣统计
                    if !stats.partners.isEmpty {
                        categoryListSection(
                            title: String(localized: "伴侣统计"),
                            data: stats.partners,
                            icon: "person.fill"
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
    }

    private func overviewCard(stats: StatisticsViewModel.Statistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundStyle(Color.appTheme)
                Text("数据概览").font(.headline)
            }

            HStack(spacing: 12) {
                summaryMetric(value: "\(stats.filteredActivities.count)", label: "次数", icon: "number", color: .blue)
                if let avg = stats.durationSummary.average {
                    summaryMetric(value: viewModel.formattedDuration(avg), label: "平均时长", icon: "clock.fill", color: .orange)
                }
                summaryMetric(value: "\(stats.locations.count)", label: "地点数", icon: "location.fill", color: .green)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func durationSummarySection(summary: StatisticsViewModel.DurationSummary) -> some View {
        cardContainer(title: String(localized: "时长分析"), icon: "timer") {
            HStack(spacing: 8) {
                durationMiniCard(title: String(localized: "最短"), value: viewModel.formattedDuration(summary.min), color: .green)
                durationMiniCard(title: String(localized: "平均"), value: viewModel.formattedDuration(summary.average), color: .orange)
                durationMiniCard(title: String(localized: "最长"), value: viewModel.formattedDuration(summary.max), color: .red)
            }
        }
    }

    private func durationMiniCard(title: String, value: String, color: Color) -> some View {
        VStack(spacing: 4) {
            Text(title).font(.caption).foregroundStyle(.secondary)
            Text(value).font(.subheadline.bold()).foregroundStyle(.primary)
            RoundedRectangle(cornerRadius: 2).fill(color).frame(height: 3)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(8)
    }

    private func timeOfDayChartSection(_ data: [StatisticsViewModel.TimeOfDayBucket]) -> some View {
        let total = data.reduce(0) { $0 + $1.count }

        return cardContainer(title: String(localized: "时段分布"), icon: "clock.fill") {
            Chart(data) { bucket in
                SectorMark(
                    angle: .value("次数", bucket.count),
                    innerRadius: .ratio(0.6),//内半径比例
                    angularInset: 2//弧形间隔
                )
                .foregroundStyle(by: .value("时段", bucket.label))//自动分配颜色
                .cornerRadius(4)
                // 智能标签位置
                .annotation(position: .overlay) {
                    let percentage = Double(bucket.count) / Double(total) * 100
                    if percentage > 5 { // 只显示大于5%的标签，避免拥挤
                        Text(String(format: "%.0f%%", percentage))
                            .font(.caption.bold())
                            .foregroundStyle(.white)
                    }
                }
            }
            .frame(height: 180)
        }
    }

    private func categoryListSection(title: String, data: [StatisticsViewModel.CategoryStat], icon: String) -> some View {
        cardContainer(title: title, icon: icon) {
            VStack(spacing: 0) {
                ForEach(Array(data.prefix(5).enumerated()), id: \.element.name) { index, item in
                    HStack {
                        Text("\(index + 1)").font(.caption.bold()).foregroundStyle(.secondary).frame(width: 20)
                        Text(item.name).font(.body)
                        Spacer()
                        Text("\(item.count) 次").font(.body.bold())
                    }
                    .padding(.vertical, 10)
                    if index != min(data.count - 1, 4) { Divider() }
                }
            }
        }
    }

    // MARK: - 基础组件

    private func cardContainer<Content: View>(title: String, icon: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label(title, systemImage: icon).font(.headline)
                .foregroundStyle(Color.appTheme)
            content()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private func summaryMetric(value: String, label: String, icon: String, color _: Color) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Label(label, systemImage: icon).font(.caption2)
                .foregroundStyle(Color.appTheme)
            Text(value).font(.headline).foregroundStyle(.primary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(UIColor.systemBackground))
        .cornerRadius(12)
    }

    private var activityFilterMenu: some View {
        Menu {
            ForEach(StatisticsViewModel.ActivityFilter.allCases) { filter in
                Button {
                    viewModel.selectedActivityFilter = filter
                } label: {
                    if viewModel.selectedActivityFilter == filter {
                        Label(filter.title, systemImage: "checkmark")
                            .foregroundStyle(Color.appTheme)
                    } else {
                        Text(filter.title)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.selectedActivityFilter.title).font(.subheadline.bold())
                Image(systemName: "chevron.down").font(.caption.bold())
                    .foregroundStyle(Color.appTheme)
            }
            .foregroundStyle(.primary)
        }
    }

    private var emptyState: some View {
        VStack(spacing: 20) {
            Image(systemName: "chart.bar.doc.horizontal").font(.system(size: 60)).foregroundStyle(.secondary)
                .foregroundStyle(Color.appTheme)
            Text("暂无记录").font(.headline)
            Text("在这里你可以看到详细的趋势与统计").font(.subheadline).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Array Safe Subscript Extension

extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
