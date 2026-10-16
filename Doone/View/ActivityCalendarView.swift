import FSCalendar
import SwiftData
import SwiftUI
import UIKit

struct ActivityCalendarView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SexActivity.date, order: .reverse) private var activities: [SexActivity]

    @StateObject private var viewModel = ActivityCalendarViewModel()

    private var activitiesForSelectedDate: [SexActivity] {
        viewModel.activitiesForSelectedDate(from: activities)
    }

    private var activityDates: Set<Date> {
        viewModel.activityDates(from: activities)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                CalendarContainer(selectedDate: $viewModel.selectedDate, activityDates: activityDates)
                    // .frame(height: 380)
                    .background(Color(UIColor.systemBackground))

                Divider()

                if activitiesForSelectedDate.isEmpty {
                    Button {
                        viewModel.showingAddActivity = true
                    } label: {
                        emptyStatePreview
                            .frame(height: 180)
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .background(Color(UIColor.systemBackground))
                            .cornerRadius(16)
                    }
                    .buttonStyle(.plain)

                } else {
                    TabView(selection: $viewModel.selectedActivityIndex) {
                        ForEach(Array(activitiesForSelectedDate.enumerated()), id: \.offset) { index, activity in
                            ActivityPreviewCard(
                                date: activity.date,
                                endDate: activity.endDate,
                                partner: activity.partner,
                                rating: activity.rating,
                                location: activity.location ?? "无",
                                safetyStatus: activity.safetyStatus,
                                durationText: durationText(for: activity),
                                isMasturbation: activity.isMasturbation
                            )
                            .padding(.horizontal, 8)
                            .padding(.vertical, 8)
                            .tag(index)
                            .onTapGesture {
                                viewModel.selectedActivity = activity
                            }
                            .onAppear {
                                print("[ActivityPreviewCard] activity: \(activity)")
                            }
                        }
                    }
                    .tabViewStyle(.page(indexDisplayMode: activitiesForSelectedDate.count > 1 ? .automatic : .never))
                    .frame(height: 180)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color(UIColor.systemBackground))
                    .cornerRadius(16)
                }

                // Spacer()
            }
            .navigationTitle("日历浏览")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.showingAddActivity = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingAddActivity) {
                AddActivityView(modelContext: modelContext, initialDate: viewModel.selectedDate)
            }
            .sheet(
                isPresented: Binding(
                    get: { viewModel.selectedActivity != nil },
                    set: { isPresented in
                        if !isPresented {
                            viewModel.selectedActivity = nil
                        }
                    }
                )
            ) {
                if let activity = viewModel.selectedActivity {
                    ActivityDetailSheetView(
                        activity: activity,
                        onDelete: {
                            viewModel.selectedActivity = nil
                        }
                    )
                }
            }
        }
    }

    // 预览用的空状态（简化版）
    private var emptyStatePreview: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("这一天还没有活动")
                        .font(.headline)
                    Text("添加你的第一次记录吧")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 24))
                    .foregroundColor(.appTheme)
            }
            Spacer()

            Divider()

            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Label("伴侣：匿名", systemImage: "person.fill")
                        .font(.subheadline)
                    Label("地点：无", systemImage: "mappin.circle.fill")
                        .font(.subheadline)
                }
                Spacer()
                Text("点击添加")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.appTheme.opacity(0.2))
                    .cornerRadius(6)
            }
            .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(
            LinearGradient(
                colors: [
                    Color.appTheme.opacity(0.25),
                    Color.appTheme.opacity(0.05),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }

    private func durationText(for activity: SexActivity) -> String {
        viewModel.durationText(for: activity)
    }
}





struct ActivityDetailSheetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = ActivityCalendarViewModel()

    @Query(sort: \Partner.name) private var partners: [Partner]

    @Bindable var activity: SexActivity

    let roles = ["Top", "Bottom", "Vers", "Side"]
    let safetyOptions = ["药物", "无保护", "避孕套"]

    let onDelete: () -> Void

    private func durationText(for activity: SexActivity) -> String {
        viewModel.durationText(for: activity)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    ActivityPreviewCard(
                        date: activity.date,
                        endDate: activity.endDate,
                        partner: activity.partner,
                        rating: activity.rating,
                        location: activity.location ?? "无",
                        safetyStatus: activity.safetyStatus,
                        durationText: durationText(for: activity),
                        isMasturbation: activity.isMasturbation
                    )
                    .padding(.vertical, 4)
                }

                Section(header: Text("信息")) {
                    HStack {
                        Label("开始时间", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                        Spacer()
                        DatePicker(
                            "",
                            selection: $activity.date,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }

                    HStack {
                        Label("结束时间", systemImage: "clock")
                        Spacer()
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { activity.endDate ?? activity.date },
                                set: { newValue in
                                    activity.endDate = newValue
                                }
                            ),
                            in: activity.date...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                    }

                    HStack {
                        Label("时长", systemImage: "hourglass")
                        Spacer()
                        Text(durationText(for: activity))
                            .foregroundStyle(.secondary)
                    }

                    if !activity.isMasturbation {
                        Picker(selection: Binding(
                            get: { activity.partner },
                            set: { activity.partner = $0 }
                        )) {
                            Text("匿名").tag(Partner?.none)
                            ForEach(partners) { partner in
                                Text(partner.name).tag(Optional(partner))
                            }
                        } label: {
                            Label("伴侣", systemImage: "person")
                        }

                        Picker(selection: Binding(
                            get: { activity.role },
                            set: { activity.role = $0 }
                        )) {
                            ForEach(roles, id: \.self) { role in
                                Text(role).tag(role)
                            }
                        } label: {
                            Label("我的角色", systemImage: "person.2")
                        }
                    }

                    HStack {
                        Label("评分", systemImage: "star")
                        Spacer()
                        HStack(spacing: 4) {
                            ForEach(1 ... 5, id: \.self) { index in
                                Image(systemName: index <= activity.rating ? "star.fill" : "star")
                                    .foregroundStyle(index <= activity.rating ? .yellow : .gray.opacity(0.3))
                                    .font(.system(size: 22))
                                    .onTapGesture {
                                        activity.rating = index
                                    }
                            }
                        }
                    }

                    if !activity.isMasturbation {
                        Picker("安全措施", selection: $activity.safetyStatus) {
                            ForEach(safetyOptions, id: \.self) { option in
                                Text(option).tag(option)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                }

                Section(header: Text("地点")) {
                    TextField(
                        "地点",
                        text: Binding(
                            get: { activity.location ?? "" },
                            set: { newValue in
                                activity.location = newValue.isEmpty ? nil : newValue
                            }
                        )
                    )
                }

                Section(header: Text("备注")) {
                    TextField(
                        "备注",
                        text: Binding(
                            get: { activity.note ?? "" },
                            set: { newValue in
                                activity.note = newValue.isEmpty ? nil : newValue
                            }
                        )
                    )
                }

                Section {
                    Button(role: .destructive) {
                        modelContext.delete(activity)
                        do {
                            try modelContext.save()
                        } catch {}
                        onDelete()
                        dismiss()
                    } label: {
                        HStack {
                            Spacer()
                            Text("删除此活动")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("活动详情")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        modelContext.rollback()
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("完成") {
                        do {
                            try modelContext.save()
                        } catch {}
                        dismiss()
                    }
                }
            }
        }
        .tint(.appTheme)
    }
}

// MARK: - CalendarContainer（保持不变）

struct CalendarContainer: UIViewRepresentable {
    @Binding var selectedDate: Date
    var activityDates: Set<Date>

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        // 语言根据系统语言来
        calendar.locale = Locale.current
        calendar.firstWeekday = 2
        //如果系统语言是中文，使用中文格式，否则使用英文格式
        if Locale.current.languageCode == "zh" {
            calendar.appearance.headerDateFormat = "yyyy年MM月"
        } else {
            calendar.appearance.headerDateFormat = "MMMM yyyy"
        }

        let themeColor = UIColor(Color.appTheme)
        calendar.backgroundColor = .clear
        calendar.appearance.todayColor = themeColor.withAlphaComponent(0.25)
        calendar.appearance.selectionColor = themeColor
        calendar.appearance.titleDefaultColor = UIColor.label
        calendar.appearance.titleTodayColor = themeColor
        calendar.appearance.titleSelectionColor = UIColor.white
        calendar.appearance.headerTitleColor = UIColor.label
        calendar.appearance.weekdayTextColor = UIColor.secondaryLabel
        calendar.appearance.borderRadius = 0.5
        calendar.scrollDirection = .horizontal
        calendar.scope = .month
        calendar.select(selectedDate)
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        // 更新 coordinator 中的 parent，以便获取最新的 activityDates
        let previousDates = context.coordinator.lastActivityDates
        context.coordinator.parent = self
        context.coordinator.lastActivityDates = activityDates

        if let current = uiView.selectedDate,
           !Calendar.current.isDate(current, inSameDayAs: selectedDate)
        {
            uiView.select(selectedDate)
        }

        // 数据变更时刷新日历外观（圈出有活动的日期）
        if previousDates != activityDates {
            uiView.reloadData()
        }
    }

    final class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDelegateAppearance {
        var parent: CalendarContainer
        var lastActivityDates: Set<Date>

        init(_ parent: CalendarContainer) {
            self.parent = parent
            lastActivityDates = parent.activityDates
        }

        func calendar(_: FSCalendar, didSelect date: Date, at _: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }

        // 为有活动的日期添加主题色描边，实现“圈出来”的效果
        func calendar(
            _: FSCalendar,
            appearance: FSCalendarAppearance,
            borderDefaultColorFor date: Date
        ) -> UIColor? {
            let day = Calendar.current.startOfDay(for: date)
            if parent.activityDates.contains(day) {
                return UIColor(Color.appTheme)
            }
            return appearance.borderDefaultColor
        }
    }
}
