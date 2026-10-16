//
//  MyView.swift
//  Doone
//
//  Created by luckly on 2026/1/2.
//

import SwiftData
import SwiftUI

struct MyView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var activities: [SexActivity]
    @State private var showExport = false
    @State private var showImport = false
    var body: some View {
        NavigationStack {
            List {
                Section {
                    // 导出数据和导入数据
                    NavigationLink {
                        let model = ExportDataModel(items: activities, appName: "性活动记录")
                        ExportDataView(exportModel: model)
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up.fill")
                                .foregroundStyle(Color.appTheme)

                            Text("导出数据")
                                .foregroundStyle(.primary)
                        }
                    }
                }
                header: {
                    Text("数据安全")
                        .font(.headline)
                }

                Section {
                    NavigationLink {
                        PartnerManagementView(modelContext: modelContext)
                    } label: {
                        HStack {
                            Image(systemName: "person.2.fill")
                                .foregroundStyle(Color.appTheme)

                            Text("伴侣管理")
                                .foregroundStyle(.primary)
                        }
                    }

                    NavigationLink {
                        LocationManagementView(modelContext: modelContext)
                    } label: {
                        HStack {
                            Image(systemName: "location.fill")
                                .foregroundStyle(Color.appTheme)

                            Text("地点管理")
                                .foregroundStyle(.primary)
                        }
                    }
                }
                header: {
                    Text("自定义")
                        .font(.headline)
                }

                // 通用设置：主题、语言、隐私、
                Section {
                    NavigationLink {
                        ThemeMangerView()
                    } label: {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundStyle(Color.appTheme)

                            Text("主题颜色")
                                .foregroundStyle(.primary)
                            Spacer()
                            // 显示当前的主题名称
                            Text(ThemeManager.shared.currentTheme.displayName)
                                .foregroundStyle(.secondary)
                        }
                    }

                    NavigationLink {
                        LanguageManagerView()
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundStyle(Color.appTheme)

                            Text("语言")
                                .foregroundStyle(.primary)
                            Spacer()
                            // 显示当前的语言名称
                            Text(LanguageManager.shared.currentLanguage.displayName)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                header: {
                    Text("通用")
                        .font(.headline)
                }
            }
            .navigationTitle("我的")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

#Preview {
    let container = try! ModelContainer(for: SexActivity.self, Partner.self, LocationPreset.self)
    return MyView()
        .modelContainer(container)
        .preferredColorScheme(.light)
}
