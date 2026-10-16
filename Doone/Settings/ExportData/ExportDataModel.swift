//
//  ExportKit.swift
//  通用可重用导出组件
//

import Foundation
import SwiftUI

// MARK: - 可导出协议 (Exportable Protocol)
public protocol Exportable {
    /// 导出条目的标题
    var exportTitle: String { get }

    /// 转换为 CSV 行数据
    func toCSVRow() -> [String]

    /// CSV 表头标题
    static var csvHeaders: [String] { get }
}

// MARK: - 导出格式 (Export Format)
public enum ExportFormat: String, CaseIterable {
    case csv = "CSV"
    case json = "JSON"

    var fileExtension: String {
        switch self {
        case .csv: return "csv"
        case .json: return "json"
        }
    }

    var mimeType: String {
        switch self {
        case .csv: return "text/csv"
        case .json: return "application/json"
        }
    }

    var displayDescription: String {
        switch self {
        case .csv: return "在 Excel 或 Numbers 中打开"
        case .json: return "最适合数据迁移/处理"
        }
    }
}

// MARK: - 导出数据模型 (Export Data Model)
public class ExportDataModel<T: Exportable & Encodable> {
    public let items: [T]
    public let appName: String

    public init(items: [T], appName: String) {
        self.items = items
        self.appName = appName
    }

    public func generateCSV() -> String {
        var csvString = T.csvHeaders.joined(separator: ",") + "\n"

        for item in items {
            let row = item.toCSVRow().map { value -> String in
                if value.contains(",") || value.contains("\"") || value.contains("\n") {
                    return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
                }
                return value
            }.joined(separator: ",")
            csvString += row + "\n"
        }

        return csvString
    }

    public func generateJSON() -> Data? {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return try? encoder.encode(items)
    }

    public func generateFileName(format: ExportFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HHmmss"
        let timestamp = dateFormatter.string(from: Date())
        return "\(appName)_export_\(timestamp).\(format.fileExtension)"
    }

    public func exportData(format: ExportFormat) -> (data: Data?, fileName: String, mimeType: String) {
        let fileName = generateFileName(format: format)
        var data: Data?

        switch format {
        case .csv:
            data = generateCSV().data(using: .utf8)
        case .json:
            data = generateJSON()
        }

        return (data, fileName, format.mimeType)
    }
}