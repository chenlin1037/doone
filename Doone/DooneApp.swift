//
//  DooneApp.swift
//  Doone
//
//  Created by luckly on 2026/1/2.
//

import SwiftData
import SwiftUI

@main
struct DooneApp: App {
    var body: some Scene {
        WindowGroup {
            MainTabView()
                .modelContainer(for: [SexActivity.self, Partner.self, LocationPreset.self])
                .tint(Color.appTheme)
                .applyTheme()
                .applyLanguage()
        }
    }
}
