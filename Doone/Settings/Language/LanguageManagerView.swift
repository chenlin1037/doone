//
//  LanguageManagerView.swift
//  Doone
//
//  Created by luckly on 2026/1/19.
//

import SwiftUI

struct LanguageManagerView: View {
    @ObservedObject var languageManager = LanguageManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var showAlert = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(Language.allCases, id: \.self) { language in
                    LanguageOptionRow(
                        language: language,
                        isSelected: languageManager.currentLanguage == language
                    ) {
                        // 只有当选择的语言与当前语言不同时，才执行操作
                        if languageManager.currentLanguage != language {
                            languageManager.setLanguage(language)
                            showAlert = true
                        }
                    }
                }
            }
            .navigationTitle(String(localized: "language_title"))
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(false)
            .toolbar(.hidden, for: .tabBar)
        }
        .toolbar(.hidden, for: .tabBar)

        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("alert_restart_title"),
                message: Text("alert_restart_message"),
                primaryButton: .destructive(Text("alert_restart_button_confirm")) {
                    // 强制退出应用
                    exit(0)
                },
                secondaryButton: .cancel(Text("alert_restart_button_cancel")) {
                    // 用户选择稍后，关闭设置页面
                    dismiss()
                }
            )
        }
    }
}

struct LanguageOptionRow: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(language.displayName)
                        .font(.system(size: 17))
                        .foregroundColor(.primary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .font(.system(size: 16, weight: .semibold))
                }
            }
            .padding(.vertical, 8)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}
