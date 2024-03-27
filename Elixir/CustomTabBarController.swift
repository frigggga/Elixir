//
//  CustomTabBarController.swift
//  Elixir
//
//  Created by Youzhi Liu on 2023/4/24.
//
import UIKit

class CustomTabBarController: UITabBarController {

    private let tabBarHeight: CGFloat = 70.0

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print(tabBar.frame.size.height)
        var tabBarFrame = tabBar.frame
        tabBarFrame.size.height = tabBarHeight
        tabBarFrame.origin.y = view.frame.size.height - tabBarHeight
        tabBar.frame = tabBarFrame
    }

}

