//
//  TabBarController.swift
//  DoggieOn
//
//  Created by Victor Lee on 2023/02/08.
//

import UIKit

final class TabBarController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()

        setTabBarControllers()
    }

    private func setTabBarControllers() {
        tabBar.backgroundColor = .systemBackground
        let appHome = AppHomeViewController()
        appHome.tabBarItem = UITabBarItem(
            title: "홈",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )

        let favouriteHome = FavouriteHomeViewController()
        favouriteHome.tabBarItem = UITabBarItem(
            title: "즐겨찾기",
            image: UIImage(systemName: "heart"),
            selectedImage: UIImage(systemName: "heart.fill")
        )

        let uploadHome = UploadHomeViewController()
        uploadHome.tabBarItem = UITabBarItem(
            title: "업로드",
            image: UIImage(systemName: "square.and.arrow.up"),
            selectedImage: UIImage(systemName: "square.and.arrow.up.fill")
        )

        viewControllers = [appHome, favouriteHome, uploadHome]
    }
}
