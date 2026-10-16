//
//  CodingKeys.swift
//  Doone
//
//  Created by luckly on 2026/1/19.
//
import SwiftData
import Foundation

extension SexActivity: Exportable {
    var exportTitle: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    func toCSVRow() -> [String] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        return [
            dateFormatter.string(from: date),
            endDate.map { dateFormatter.string(from: $0) } ?? "",
            isMasturbation ? "自慰" : "性活动",
            role,
            String(rating),
            partner?.name ?? "",
            safetyStatus,
            location ?? "",
            note ?? ""
        ]
    }
    
    static var csvHeaders: [String] {
        return [
            "开始时间",
            "结束时间",
            "类型",
            "角色",
            "评分",
            "伴侣",
            "安全状态",
            "地点",
            "备注"
        ]
    }
}

// 让SexActivity遵循Encodable（用于JSON导出）
extension SexActivity: Encodable {
    enum CodingKeys: String, CodingKey {
        case date, endDate, role, rating, safetyStatus, location, note, isMasturbation
        case partnerName
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(date, forKey: .date)
        try container.encodeIfPresent(endDate, forKey: .endDate)
        try container.encode(role, forKey: .role)
        try container.encode(rating, forKey: .rating)
        try container.encode(safetyStatus, forKey: .safetyStatus)
        try container.encodeIfPresent(location, forKey: .location)
        try container.encodeIfPresent(note, forKey: .note)
        try container.encode(isMasturbation, forKey: .isMasturbation)
        try container.encodeIfPresent(partner?.name, forKey: .partnerName)
    }
}
