//
//  AddActivityViewModel.swift
//  Doone
//
//  Created by luckly on 2026/1/2.
//

import Combine
import Foundation
import SwiftData

final class AddActivityViewModel: ObservableObject {
    // 1. UI 绑定的状态
    @Published var date: Date = .init()
    @Published var endDate: Date = .init()
    @Published var isMasturbation: Bool = false
    @Published var selectedPartner: Partner? = nil
    @Published var selectedRole: String = "Top"
    @Published var safetyStatus: String = "无保护"
    @Published var rating: Int = 3

    @Published var location: String = "无"
    @Published var note: String = ""

    // 2. 常量定义
    let roles = ["Top", "Bottom", "Vers", "Side"]
    let safetyOptions = ["药物", "无保护", "避孕套"]
    @Published var locations: [String] = ["无"]
    @Published var partners: [Partner] = []

    private var modelContext: ModelContext

    init(modelContext: ModelContext, initialDate: Date) {
        self.modelContext = modelContext

        let now = Date()
        let calendar = Calendar.current

        // 取当前时间的 时、分
        let timeComponents = calendar.dateComponents([.hour, .minute], from: now)

        // 拼接选择的日期和当前的时、分
        date = calendar.date(
            bySettingHour: timeComponents.hour ?? 0,
            minute: timeComponents.minute ?? 0,
            second: timeComponents.second ?? 0,
            of: initialDate
        ) ?? now

        endDate = date

        loadLocations()
        loadPartners()
    }

    private func loadPartners() {
        let descriptor = FetchDescriptor<Partner>()

        do {
            let fetched = try modelContext.fetch(descriptor)
            partners = fetched.sorted { $0.sortOrder < $1.sortOrder }
        } catch {
            print("加载伴侣失败: \(error)")
            partners = []
        }
    }

    private func loadLocations() {
        let descriptor = FetchDescriptor<LocationPreset>()
        do {
            let fetchedPresets = try modelContext.fetch(descriptor)
            if fetchedPresets.isEmpty {
                locations = ["无"]
            } else {
                let sortedPresets = fetchedPresets.sorted { lhs, rhs in
                    lhs.sortOrder < rhs.sortOrder
                }
                let names = sortedPresets.map { $0.name }
                locations = ["无"] + names
            }
        } catch {
            print("加载地点失败: \(error)")
            locations = ["无"]
        }
    }

    // 3. 业务逻辑：保存数据
    func save() -> Bool {
        let partnerToSave: Partner? = isMasturbation ? nil : selectedPartner
        // let partnerToSave: Partner? = selectedPartner

        let newActivity = SexActivity(
            date: date,
            endDate: endDate,
            role: selectedRole,
            rating: rating,
            partner: partnerToSave,
            safetyStatus: safetyStatus,
            location: location,
            note: note,
            isMasturbation: isMasturbation
        )
        modelContext.insert(newActivity)

        do {
            try modelContext.save()
            return true
        } catch {
            print("保存失败: \(error)")
            return false
        }
    }

    // 4. 计算属性：时长显示
    var isEndDateValid: Bool {
        endDate >= date
    }

    /// 纯时长文本，例如："1小时30分钟"、"45分钟"、"--"
    var durationText: String {
        guard isEndDateValid else { return "--" }

        let seconds = Int(endDate.timeIntervalSince(date))
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60

        if hours > 0 {
            return "\(hours)小时\(minutes)分钟"
        } else {
            return "\(minutes)分钟"
        }
    }
}
