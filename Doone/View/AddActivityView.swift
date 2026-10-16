//
//  AddActivityView.swift
//  Doone
//
//  Created by luckly on 2026/1/2.
//

import Foundation
import SwiftData
import SwiftUI

struct AddActivityView: View {
    // MARK: - 环境与状态

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    // 查询所有伴侣数据
    @Query(sort: \Partner.name) private var partners: [Partner]

    // 使用 StateObject 管理逻辑
    @StateObject private var viewModel: AddActivityViewModel
    @State private var showPreview = false

    // 初始化时注入 ModelContext
    init(modelContext: ModelContext, initialDate: Date) {
        _viewModel = StateObject(wrappedValue: AddActivityViewModel(modelContext: modelContext, initialDate: initialDate))
    }

    var body: some View {
        NavigationStack {
            Form {
                // 1. 预览卡片区域
                previewSection

                // 2. 保护措施区域
                safetySection

                typeSection

                // 3. 基础信息区域
                basicInfoSection

                // 4. 地点选择区域
                locationSection

                // 5. 备注区域
                noteSection
            }
            .navigationTitle("新活动")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        if viewModel.save() {
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .tint(.appTheme)
    }

    // MARK: - 辅助方法

    // private func iconForLocation(_ location: String) -> String {
    //     switch location {
    //     case "家": return "house.fill"
    //     case "公园": return "tree.fill"
    //     case "酒店": return "bed.double.fill"
    //     case "派对": return "party.popper.fill"
    //     case "海滩": return "beach.umbrella.fill"
    //     default: return "mappin.circle.fill"
    //     }
    // }
}

// MARK: - 视图模块拆分 (防止编译器报错)

extension AddActivityView {
    // 预览区域 - 复原原始动画逻辑
    private var previewSection: some View {
        Section {
            VStack(spacing: 0) {
                // 点击按钮
                Button {
                    withAnimation(.spring(response: 0.4)) {
                        showPreview.toggle()
                    }
                } label: {
                    HStack {
                        Text("预览活动卡片")
                            .font(.headline)
                            .foregroundColor(.secondary)

                        Spacer()

                        Image(systemName: "chevron.right")
                            .rotationEffect(.degrees(showPreview ? 90 : 0))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }

                // 预览卡片：放在同一个 VStack 里，不使用单独的 transition
                if showPreview {
                    ActivityPreviewCard(
                        date: viewModel.date,
                        endDate: viewModel.endDate,
                        partner: viewModel.selectedPartner,
                        rating: viewModel.rating,
                        location: viewModel.location,
                        safetyStatus: viewModel.safetyStatus,
                        durationText: viewModel.durationText,
                        isMasturbation: viewModel.isMasturbation
                    )
                    .padding(.horizontal, 8)
                    .padding(.bottom, 8)
                }
            }
            .background(Color(.systemBackground)) // 保持白色背景
        }
        .listRowInsets(EdgeInsets()) // 撑满行宽
        .listRowBackground(Color(.systemGray6)) // 模拟列表底层背景色
    }

    // 保护措施
    private var safetySection: some View {
        Section(header: Text("保护措施")) {
            if viewModel.isMasturbation {
                Text("自慰记录无需保护措施")
                    .foregroundStyle(.secondary)
            } else {
                Picker("安全措施", selection: $viewModel.safetyStatus) {
                    ForEach(viewModel.safetyOptions, id: \.self) { option in
                        Text(option).tag(option)
                    }
                }
                .pickerStyle(.segmented)
            }

            // Picker("安全措施", selection: $viewModel.safetyStatus) {
            //     ForEach(viewModel.safetyOptions, id: \.self) { option in
            //         Text(option).tag(option)
            //     }
            // }
            // .pickerStyle(.segmented)
        }
    }

    private var typeSection: some View {
        Section(header: Text("类型")) {
            Picker("类型", selection: $viewModel.isMasturbation) {
                Text("性行为").tag(false)
                Text("自慰").tag(true)
            }
            .pickerStyle(.segmented)
        }
    }

    // 基础信息
    private var basicInfoSection: some View {
        Section(header: Text("信息")) {
            // 时间
            HStack {
                Label("开始时间", systemImage: "clock.arrow.trianglehead.counterclockwise.rotate.90")
                Spacer()
                DatePicker(
                    "",
                    selection: $viewModel.date,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }

            HStack {
                Label("结束时间", systemImage: "clock")
                Spacer()
                DatePicker(
                    "",
                    selection: $viewModel.endDate,
                    in: viewModel.date...,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }

            HStack {
                Label("时长", systemImage: "hourglass")
                Spacer()
                Text(viewModel.durationText)
                    .foregroundStyle(.secondary)
            }

            if !viewModel.isMasturbation {
                // 伴侣
                Picker(selection: $viewModel.selectedPartner) {
                    // 当为nil时，显示"匿名"
                    Text("匿名").tag(nil as Partner?)

                    ForEach(viewModel.partners, id: \.self) { partner in
                        Text(partner.name).tag(partner as Partner?)
                    }
                } label: {
                    Label("伴侣", systemImage: "person")
                }

                // 角色
                Picker(selection: $viewModel.selectedRole) {
                    ForEach(viewModel.roles, id: \.self) { role in
                        Text(role).tag(role)
                    }
                } label: {
                    Label("我的角色", systemImage: "person.2")
                }
            }

            // 评分
            HStack {
                Label("评分", systemImage: "star")
                Spacer()
                HStack(spacing: 4) {
                    ForEach(1 ... 5, id: \.self) { index in
                        Image(systemName: index <= viewModel.rating ? "star.fill" : "star")
                            .foregroundStyle(index <= viewModel.rating ? .yellow : .gray.opacity(0.3))
                            .font(.system(size: 22))
                            .onTapGesture {
                                viewModel.rating = index
                            }
                    }
                }
            }
        }
    }

    // 地点
    private var locationSection: some View {
        Section(header: Text("地点")) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    LocationButton(
                        location: "无",
                        isSelected: viewModel.location == "无"
                    ) {
                        viewModel.location = "无"
                    }

                    ForEach(viewModel.locations.filter { $0 != "无" }, id: \.self) { loc in
                        LocationButton(
                            location: loc,
                            isSelected: viewModel.location == loc
                        ) {
                            viewModel.location = loc
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
    }

    // 备注
    private var noteSection: some View {
        Section(header: Text("备注")) {
            HStack(spacing: 12) {
                Image(systemName: "note.text")
                    .foregroundColor(.appTheme)
                    .frame(width: 24)

                TextField("备注", text: $viewModel.note)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
        }
    }
}

// MARK: - 辅助子视图组件

struct LocationButton: View {
    let location: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Text(location)
                    .font(.subheadline)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(isSelected ? Color.appTheme.opacity(0.2) : Color(.systemGray6))
            .foregroundStyle(isSelected ? Color.appTheme : .primary)
            .cornerRadius(16)
        }
        .buttonStyle(PlainButtonStyle()) // 防止在 List 中触发整行点击
    }
}

struct ActivityPreviewCard: View {
    let date: Date
    let endDate: Date?
    let partner: Partner?
    let rating: Int
    let location: String
    let safetyStatus: String
    let durationText: String
    let isMasturbation: Bool

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(date, style: .date).font(.headline)

                    if let endDate, endDate >= date {
                        HStack(spacing: 8) {
                            Text("开始")
                            Text(date, style: .time)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        HStack(spacing: 8) {
                            Text("结束")
                            Text(endDate, style: .time)
                        }
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                        Text("时长 \(durationText)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        Text(date, style: .time)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                HStack(spacing: 4) {
                    ForEach(1 ... 5, id: \.self) { index in
                        Image(systemName: index <= rating ? "star.fill" : "star")
                            .foregroundStyle(index <= rating ? .yellow : .gray.opacity(0.3))
                            .font(.system(size: 16))
                    }
                }
            }
            Divider()
            HStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Label(isMasturbation ? "自慰" : (partner?.name ?? "匿名"), systemImage: isMasturbation ? "hand.raised.fill" : "person.fill").font(.subheadline)
                        // Label(partner?.name ?? "匿名", systemImage: "person.fill")
                        .font(.subheadline)
                    Label(location, systemImage: "mappin.circle.fill").font(.subheadline)
                }
                Spacer()
                if !isMasturbation {
                    Text(safetyStatus)
                        .font(.caption)
                        .padding(.horizontal, 8).padding(.vertical, 4)
                        .background(Color.appTheme.opacity(0.2))
                        .cornerRadius(6)
                }
            }
            .foregroundStyle(.secondary)
        }
        .padding(8)
        .background(
            LinearGradient(
                colors: [
                    Color.appTheme.opacity(0.25),
                    Color.appTheme.opacity(0.05),
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
    }
}

// MARK: - 预览

#Preview {
    AddActivityView(
        modelContext: try! ModelContext(try! ModelContainer(for: SexActivity.self, Partner.self, LocationPreset.self)),
        initialDate: Date()
    )
}
