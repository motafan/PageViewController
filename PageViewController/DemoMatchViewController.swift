//
//  DemoMatchViewController.swift
//  PageViewController
//
//  Created by Fanfan Tan on 2021/12/5.
//  Copyright © 2021年 Fan. All rights reserved.
//

import UIKit

class DemoMatchViewController: UIViewController {

    private let titles = ["大菠萝", "苹果","芒果", "梨", "香蕉","橘子", "哈密瓜", "西瓜", "葡萄", "橙子", "柚子"]

    private lazy var pageViewController: PageViewController = {
        let pageViewController = PageViewController(navigationOrientation: .horizontal)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    
    private lazy var pageTabBar: PageTabBar = {
        let pageTabBar = PageTabBar(frame: CGRect(x: 0, y: UIApplication.shared.statusBarFrame.height + 44, width: UIScreen.main.bounds.width, height: 50))
        pageTabBar.dataSource = self
        pageTabBar.delegate = self
        return pageTabBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        automaticallyAdjustsScrollViewInsets = false
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        view.addSubview(pageViewController.view)
        pageTabBar.contentScrollView = pageViewController.scrollView
        view.addSubview(pageTabBar)
    }

    deinit {
        print("DemoMatchViewController deinit")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navigationHeight = UIApplication.shared.statusBarFrame.height + 44
        pageTabBar.frame = CGRect(x: 0, y: navigationHeight, width: UIScreen.main.bounds.width, height: 50)
        pageViewController.view.frame = CGRect(x: 0, y: navigationHeight + 50, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navigationHeight - 50 )
    }
    
    @IBAction func reload(_ sender: Any) {
        pageTabBar.setSelectedIndex(5, shouldHandleContentScrollView: true)
    }
    
}

// MARK: -  PageContainerDelegate, PageContainerDataSource
extension DemoMatchViewController: PageViewControllerDelegate, PageViewControllerDataSource {
    
    func numberOfChildViewControllers(in pageViewController: PageViewController) -> Int {
        return titles.count
    }
    
    func pageViewController(_ pageViewController: PageViewController, childViewContollerAt index: Int) -> UIViewController {
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailVC.text = titles[index]
        return detailVC
    }
    
    func defaultCurrentIndex(in pageViewController: PageViewController) -> Int {
        return 5
    }

}

// MARK: -  PageContainerDelegate, PageContainerDataSource
extension DemoMatchViewController: PageTabBarDataSource, PageTabBarDelegate {
    
    func numberOfItems(in pageTabBar: PageTabBar) -> Int {
        return titles.count
    }
    
    func pageTabBar(_ pageTabBar: PageTabBar, titleForItemAt index: Int) -> String {
        return titles[index]
    }
    
    func defaultSelectedIndex(in pageTabBar: PageTabBar) -> Int {
        return 5
    }
    
}
