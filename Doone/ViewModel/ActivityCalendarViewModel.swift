import Combine
import Foundation
import SwiftData

final class ActivityCalendarViewModel: ObservableObject {
    @Published var selectedDate: Date
    @Published var showingAddActivity: Bool = false
    @Published var selectedActivity: SexActivity?
    @Published var selectedActivityIndex: Int = 0

    private let calendar: Calendar

    init(initialDate: Date = Date(), calendar: Calendar = .current) {
        selectedDate = initialDate
        self.calendar = calendar
    }

    func activitiesForSelectedDate(from activities: [SexActivity]) -> [SexActivity] {
        activities.filter { activity in
            calendar.isDate(activity.date, inSameDayAs: selectedDate)
        }
    }

    func activityDates(from activities: [SexActivity]) -> Set<Date> {
        Set(activities.map { calendar.startOfDay(for: $0.date) })
    }

    func durationText(for activity: SexActivity) -> String {
        guard let end = activity.endDate, end >= activity.date else { return "--" }
        let seconds = Int(end.timeIntervalSince(activity.date))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
}
