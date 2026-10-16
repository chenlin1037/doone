# Doone

一款 iOS 私密的个人记录与统计工具，用于记录日常活动并查看长期趋势。数据全部保存在设备本地，不联网、不同步。

## 功能

- **首页 · 日历浏览**：按月查看记录分布，有记录的日期会打点；选中某天后以卡片形式浏览当天条目，可进入详情页查看与编辑，也可直接新增。
- **统计 · 图表分析**：基于 Swift Charts，支持按周 / 月 / 年 / 全部切换；包含数据概览、时长分析（最短 / 最长 / 平均）、时段分布（0-6 / 6-12 / 12-18 / 18-24 时）、地点与伴侣排行，并可按「全部 / 自慰 / 性生活」筛选。
- **我的 · 设置**：数据导出（CSV / JSON）、伴侣管理、地点管理、主题颜色、语言切换。

一条记录包含的字段：开始时间、结束时间（时长）、角色、评分（1-5）、伴侣、安全状态、地点、备注、是否为自慰。

## 技术栈

| 项目 | 说明 |
| --- | --- |
| 框架 | SwiftUI（少量 UIKit 胶水：`UITabBarAppearance`、`UIViewRepresentable`、`UISelectionFeedbackGenerator`） |
| 持久化 | SwiftData（`@Model` / `@Query`），数据模型：`SexActivity`、`Partner`、`LocationPreset` |
| 图表 | Swift Charts |
| 日历 | [FSCalendar](https://github.com/WenchaoD/FSCalendar) 2.8.4（唯一的第三方依赖，Swift Package） |
| 偏好存储 | UserDefaults（主题色、语言） |
| 系统框架 | SwiftUI / SwiftData / Charts / PhotosUI / UIKit / Combine |

## 环境要求

- Xcode 16.4 或更高
- iOS 18.5 或更高（iPhone / iPad，`TARGETED_DEVICE_FAMILY = 1,2`）
- Swift 5.0

## 构建与运行

```bash
open Doone.xcodeproj
```

1. 首次打开时 Xcode 会自动解析 FSCalendar 依赖，需要联网。
2. 选择 **Doone** scheme。
3. 选择 iOS 18.5 及以上的模拟器或真机，`Cmd + R` 运行。

## 目录结构

```
Doone/
├── DooneApp.swift                  @main 入口，配置 SwiftData 容器、主题与语言
├── MainTabView.swift               TabView 外壳
├── Theme.swift                     主题色定义
├── Models/                         SwiftData 模型与导出扩展
├── View/                           首页、日历、新增、统计、我的及其子页面
├── ViewModel/                      各页面对应的 ViewModel
├── Settings/
│   ├── Appearance/                 主题管理
│   ├── Language/                   语言管理
│   └── ExportData/                 数据导出
├── Assets.xcassets/                图标与 Tab 图标资源
└── Info.plist
Localizable.xcstrings               本地化词条（简体中文 / English）
DooneTests/                         单元测试（Xcode 模板）
DooneUITests/                       UI 测试（Xcode 模板）
```

## 本地化

源语言为简体中文（`zh-Hans`），另提供英文（`en`）。应用内可手动切换「跟随系统 / English / 简体中文」。

## 隐私

- 所有数据仅保存在本机，无账号、无云端同步、无第三方统计。
- 申请的唯一系统权限是相册（`NSPhotoLibraryUsageDescription`），用于选择伴侣相关的图片。
- 支持将数据导出为 CSV / JSON 文件自行保存或迁移。

## 说明

测试目录中的用例目前仍为 Xcode 生成的模板，尚未补充实际断言。
