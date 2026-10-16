//
//  SexActivity.swift
//  Doone
//
//  Created by luckly on 2026/1/2.
//

import Foundation
import SwiftData

@Model
final class SexActivity {
    var date: Date
    var endDate: Date?
    var role: String // Top, Bottom, Vers, Side
    var rating: Int // 1-5
    var partner: Partner?
    var safetyStatus: String // Safe, Unsafe, Unnecessary
    var location: String?
    var note: String?
    var isMasturbation: Bool

    init(
        date: Date = Date(),
        endDate: Date? = nil,
        role: String = "Top",
        rating: Int = 3,
        partner: Partner? = nil,
        safetyStatus: String = "无保护",
        location: String? = nil,
        note: String? = nil,
        isMasturbation: Bool = false
    ) {
        self.date = date
        self.endDate = endDate
        self.role = role
        self.rating = rating
        self.partner = partner
        self.safetyStatus = safetyStatus
        self.location = location
        self.note = note
        self.isMasturbation = isMasturbation
    }
}








