//
//  LanguageManagerModel.swift
//  Doone
//
//  Created by luckly on 2026/1/19.
//

//
//  LanguageSettings.swift
//  MinCalendar
//
//  Created by luckly on 2025/8/20.
//
// 这部分的逻辑是语言国际化
// 1 检测系统的语言
// 2 将系统语言转换为应用语言
// 3 用户手动更改应用语言
// 4 与Localizable.xcstrings文件配合使用
// 5 观察值、系统变量、用户默认值
import SwiftUI

enum Language: String, CaseIterable {
    case auto
    case en
    case zh = "zh-Hans"

    var displayName: String {
        switch self {
        case .auto:
            return String(localized: "language_system")
        case .en:
            return "English"
        case .zh:
            return "简体中文"
        }
    }
}

final class LanguageManager: ObservableObject {
    static let shared = LanguageManager()
    @Published var currentLanguage: Language = .en
    private var currentBundle: Bundle = .main

    private let userDefaultsKey = "app_language"

    private init() {
        // 1. 从 UserDefaults 加载保存的语言
        if let savedLanguageCode = UserDefaults.standard.string(forKey: userDefaultsKey),
           let savedLanguage = Language(rawValue: savedLanguageCode)
        {
            setLanguage(savedLanguage, initial: true)
        } else {
            // 2. 如果没有保存的语言，则检测系统语言
            let defaultLanguage: Language
            if let languageCode = Locale.preferredLanguages.first, languageCode.hasPrefix("zh") {
                defaultLanguage = .zh
            } else {
                defaultLanguage = .en
            }
            // 确保在初始化时也加载正确的 Bundle
            setLanguage(defaultLanguage, initial: true)
        }
    }

    // 检测系统语言并返回对应的应用语言
    private func detectSystemLanguage() -> Language {
        if let languageCode = Locale.preferredLanguages.first, languageCode.hasPrefix("zh") {
            return .zh
        } else {
            return .en
        }
    }

    // 3. 更改应用语言
    func setLanguage(_ language: Language, initial _: Bool = false) {
        let actualLanguage: Language

        if language == .auto {
            // 自动检测系统语言
            actualLanguage = detectSystemLanguage()

            // 对于auto模式，不设置AppleLanguages，让系统使用默认语言
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        } else {
            // 使用用户指定的语言
            actualLanguage = language

            // 更新 UserDefaults 中的 "AppleLanguages" 来告诉系统下次启动时加载哪个语言包
            UserDefaults.standard.set([language.rawValue], forKey: "AppleLanguages")
        }

        // 手动加载对应语言的 Bundle
        if let path = Bundle.main.path(forResource: actualLanguage.rawValue, ofType: "lproj"),
           let bundle = Bundle(path: path)
        {
            currentBundle = bundle
        } else {
            currentBundle = .main
        }

        // 更新我们自己的状态，用于UI刷新和持久化
        currentLanguage = language // 保存用户选择的语言（包括auto）
        UserDefaults.standard.set(language.rawValue, forKey: userDefaultsKey)
    }

    // 4. 提供一个从当前 Bundle 获取本地化字符串的方法
    func localized(key: String) -> String {
        // 直接从我们加载的 bundle 中获取字符串，绕过 NSLocalizedString 的缓存
        return currentBundle.localizedString(forKey: key, value: nil, table: nil)
    }

    func getLanguageDisplayName() -> String {
        if currentLanguage == .auto {
            let systemLanguage = detectSystemLanguage()
            return "\(currentLanguage.displayName) (\(systemLanguage.displayName))"
        }
        return currentLanguage.displayName
    }
}

struct LanguageModifier: ViewModifier {
    @ObservedObject var languageManager = LanguageManager.shared

    func body(content: Content) -> some View {
        content
            .environmentObject(languageManager)
    }
}

extension View {
    func applyLanguage() -> some View {
        modifier(LanguageModifier())
    }
}
