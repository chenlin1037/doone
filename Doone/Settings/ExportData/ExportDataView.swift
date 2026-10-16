//
//  ExportDataView.swift
//  通用可重用导出组件
//

import SwiftUI

struct ExportDataView<T: Exportable & Encodable>: View {
    let exportModel: ExportDataModel<T>
    @State private var selectedFormat: ExportFormat = .csv
    @State private var showShareSheet = false
    @State private var shareItem: ShareItem?
    @Environment(\.dismiss) var dismiss

    // 可自定义的文本文本
    let titleText: String
    let recordsLabel: (Int) -> String
    let chooseFormatLabel: String
    let exportButtonLabel: String
    let cancelLabel: String
    let navigationTitle: String

    public init(
        exportModel: ExportDataModel<T>,
        titleText: String = "准备导出",
        recordsLabel: @escaping (Int) -> String = { "共 \($0) 条记录" },
        chooseFormatLabel: String = "选择格式",
        exportButtonLabel: String = "导出数据",
        cancelLabel: String = "取消",
        navigationTitle: String = "导出数据"
    ) {
        self.exportModel = exportModel
        self.titleText = titleText
        self.recordsLabel = recordsLabel
        self.chooseFormatLabel = chooseFormatLabel
        self.exportButtonLabel = exportButtonLabel
        self.cancelLabel = cancelLabel
        self.navigationTitle = navigationTitle
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                // 统计数据头部
                VStack(spacing: 8) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)

                    Text(titleText)
                        .font(.title2)
                        .bold()

                    Text(recordsLabel(exportModel.items.count))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)

                // 格式选择
                VStack(alignment: .leading, spacing: 12) {
                    Text(chooseFormatLabel)
                        .font(.headline)

                    ForEach(ExportFormat.allCases, id: \.self) { format in
                        FormatOptionRow(
                            format: format,
                            isSelected: selectedFormat == format
                        ) {
                            selectedFormat = format
                        }
                    }
                }
                .padding(.horizontal)

                Spacer()

                // 导出按钮
                Button(action: exportData) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                        Text(exportButtonLabel)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
                .disabled(exportModel.items.isEmpty)
            }
            .navigationTitle(navigationTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(.hidden, for: .tabBar)
            .sheet(isPresented: $showShareSheet) {
                if let shareItem = shareItem {
                    ShareSheet(items: [shareItem.url])
                }
            }
        }
    }

    private func exportData() {
        let result = exportModel.exportData(format: selectedFormat)

        guard let data = result.data else {
            print("导出失败")
            return
        }

        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent(result.fileName)

        do {
            try data.write(to: tempURL)
            shareItem = ShareItem(url: tempURL, fileName: result.fileName)
            showShareSheet = true
        } catch {
            print("保存文件失败: \(error)")
        }
    }
}

// MARK: - 格式选项行 (Format Option Row)
struct FormatOptionRow: View {
    let format: ExportFormat
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(format.rawValue)
                        .font(.body)
                        .foregroundColor(.primary)

                    Text(format.displayDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - 分享条目 (Share Item)
struct ShareItem {
    let url: URL
    let fileName: String
}

// MARK: - 分享视图 (Share Sheet)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}
