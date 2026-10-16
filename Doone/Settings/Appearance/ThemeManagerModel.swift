//
//  AppTheme.swift
//  Doone
//
//  Created by luckly on 2026/1/15.
//

import Combine
import SwiftUI

// MARK: - Theme Types

enum AppTheme: String, CaseIterable {
    case system
    case light
    case dark

    var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }

    var displayName: String {
        switch self {
        case .system:
            return String(localized: "theme_system")
        case .light:
            return String(localized: "theme_light")
        case .dark:
            return String(localized: "theme_dark")
        }
    }

    var themeDescription: String {
        switch self {
        case .system:
            return String(localized: "theme_system_description")
        case .light:
            return String(localized: "theme_light_description")
        case .dark:
            return String(localized: "theme_dark_description")
        }
    }
}

// MARK: - Theme Manager

final class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var currentTheme: AppTheme {
        didSet {
            saveTheme()
        }
    }

    private let userDefaults = UserDefaults.standard
    private let themeKey = "selected_theme"

    private init() {
        // 从 UserDefaults 加载保存的主题，默认为跟随系统
        if let savedTheme = userDefaults.string(forKey: themeKey),
           let theme = AppTheme(rawValue: savedTheme)
        {
            currentTheme = theme
        } else {
            currentTheme = .system
        }
    }

    // MARK: - Private Methods

    private func saveTheme() {
        userDefaults.set(currentTheme.rawValue, forKey: themeKey)
    }
}

// MARK: - View Modifier for Theme Application

struct ThemeModifier: ViewModifier {
    @ObservedObject var themeManager = ThemeManager.shared

    func body(content: Content) -> some View {
        content
            .preferredColorScheme(themeManager.currentTheme.colorScheme)
            .environmentObject(themeManager)
            // .id(themeManager.currentTheme)
            
    }
}

extension View {
    func applyTheme() -> some View {
        modifier(ThemeModifier())
    }
}