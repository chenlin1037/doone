//
//  Partner.swift
//  Doone
//
//  Created by luckly on 2026/1/2.
//

import Foundation
import SwiftData

@Model
final class Partner {
    var name: String
    var sortOrder: Int
    @Relationship(deleteRule: .cascade, inverse: \SexActivity.partner)
    var activities: [SexActivity]? = []
    @Relationship(deleteRule: .cascade)

    init(name: String, sortOrder: Int = 0) {
        self.name = name
        self.sortOrder = sortOrder
    }
}
