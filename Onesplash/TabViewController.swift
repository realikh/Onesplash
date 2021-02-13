//
//  TabViewController.swift
//  Onesplash
//
//  Created by Мирас on 2/10/21.
//

import UIKit

class TabViewController: UITabBarController, UISearchBarDelegate {
    
    private let homeVC = HomeViewController()
    private let searchVC = SearchViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.barTintColor = UIColor(named: "DarkTheme")
        homeVC.tabBarItem = UITabBarItem(tabBarSystemItem: .featured, tag: 0)
        searchVC.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 1)
        let tabBarList = [homeVC,searchVC]
        viewControllers = tabBarList
        extendedLayoutIncludesOpaqueBars = true
    }

}
