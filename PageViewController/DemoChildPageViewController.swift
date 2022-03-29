//
//  DemoChildPageViewController.swift
//  PageViewController
//
//  Created by Fanfan Tan on  2021/12/5.
//  Copyright © 2021年 Fan. All rights reserved.
//

import UIKit

class DemoChildPageViewController: UIViewController {

    private let titles = ["大菠萝", "苹果","芒果", "梨", "香蕉","橘子", "哈密瓜", "西瓜", "葡萄", "橙子", "柚子"]

    private lazy var pageVC: PageTabBarController = {
        let pageVC = PageTabBarController()
        pageVC.dataSource = self
        pageVC.delegate = self
        return pageVC
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        automaticallyAdjustsScrollViewInsets = false
        addChild(pageVC)
        pageVC.didMove(toParent: pageVC)
        view.addSubview(pageVC.view)
    }

    deinit {
        print("DemoChildPageViewController deinit")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let originY = UIApplication.shared.statusBarFrame.height + 44
        pageVC.view.frame = CGRect(x: 0, y: originY, width: view.bounds.width, height: view.bounds.height - originY)
    }
    
}

// MARK: -  PageViewControllerDelegate, PageViewControllerDataSource
extension DemoChildPageViewController: PageTabBarControllerDelegate, PageTabBarControllerDataSource {
    
    func numberOfItems(in pageViewController: PageTabBarController) -> Int {
        return titles.count
    }
    
    func pageViewController(_ pageViewController: PageTabBarController, titleForItemAt index: Int) -> String {
        return titles[index]
    }
    
    func pageViewController(_ pageViewController: PageTabBarController, childViewContollerAt index: Int) -> UIViewController {
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailVC.text = titles[index]
        return detailVC
    }
    
}
