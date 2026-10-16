//
//  MainTabView.swift
//  Doone
//
//  Created by luckly on 2026/1/2.
//


import SwiftUI
import UIKit

struct MainTabView: View {
    @State private var selectedTab = 0 // 1 表示第一个 tab

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground() // 保持透明背景

        // 使用系统背景色并保持半透明效果
        appearance.backgroundColor = UIColor.systemBackground.withAlphaComponent(0.95)

        // 自定义选中状态的图标和文字颜色（浅色模式下黑色，深色模式下白色）
        appearance.stackedLayoutAppearance.selected.iconColor = UIColor.label
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.label]
        
        // 自定义未选中状态的图标和文字颜色（灰色）
        appearance.stackedLayoutAppearance.normal.iconColor = UIColor.secondaryLabel
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.secondaryLabel]

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Image("首页")
                    Text("首页")
                                        
                }
                .tag(0)

            StatisticsView()
                .tabItem {
                    Image("统计")
                    Text("统计")
                }
                .tag(1)


            MyView()
                .tabItem {
                    Image("我的")
                    Text("我的")
                }
                .tag(2)

        }
        .onChange(of: selectedTab) { _, _ in
            let generator = UISelectionFeedbackGenerator()
            generator.selectionChanged()
        }
    }
}

//


