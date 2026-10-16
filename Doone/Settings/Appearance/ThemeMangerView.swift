//
//  ThemeMangerView.swift
//  Doone
//
//  Created by luckly on 2026/1/15.
//

import SwiftUI

struct ThemeMangerView: View {
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(AppTheme.allCases, id: \.self) { theme in
                ThemeOptionRow(
                    theme: theme,
                    isSelected: themeManager.currentTheme == theme
                ) {
                    themeManager.currentTheme = theme
                    dismiss()
                }
            }
        }
        .navigationTitle(String(localized: "主题颜色"))
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar(.hidden, for: .tabBar)
    }
}

struct ThemeOptionRow: View {
    let theme: AppTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(theme.displayName)
                        .font(.system(size: 17))
                        .foregroundColor(.primary)

                    Text(theme.themeDescription)
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
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

#Preview {
    ThemeMangerView()
}

