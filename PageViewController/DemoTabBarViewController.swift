//
//  DemoTabBarViewController.swift
//  PageViewController
//
//  Created by Fanfan Tan on 2021/12/5.
//  Copyright © 2021年 Fan. All rights reserved.
//

import UIKit

class DemoTabBarViewController: UIViewController {

//    private let titles = ["大菠萝", "苹果","芒果", "梨", "香蕉","橘子", "哈密瓜", "西瓜", "葡萄", "橙子", "柚子"]
    private let titles = ["大菠萝", "苹果","芒果", "梨"]

    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView(frame: CGRect.zero)
        scrollView.isPagingEnabled = true
        scrollView.bounces = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
    private lazy var pageTabBar: PageTabBar = {
        let pageTabBar = PageTabBar(frame: CGRect.zero)
        pageTabBar.dataSource = self
        pageTabBar.delegate = self
        return pageTabBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        automaticallyAdjustsScrollViewInsets = false
        
        view.addSubview(scrollView)
        view.addSubview(pageTabBar)
        pageTabBar.contentScrollView = scrollView

        for i in 0 ..< titles.count {
            let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
            detailVC.text = titles[i]
            addChild(detailVC)
            detailVC.didMove(toParent: self)
            scrollView.addSubview(detailVC.view)
        }
    }
    
    deinit {
        print("DemoTabBarViewController deinit")
    }
    
    /// 单独使用PageTabBar时，需要手动设置scrollView.observationInfo = nil，否则会在低版本下崩溃
//    deinit {
//        scrollView.observationInfo = nil
//    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let originY = UIApplication.shared.statusBarFrame.height + (navigationController?.navigationBar.frame.height ?? 0)
        pageTabBar.frame = CGRect(x: 0, y: originY, width: view.bounds.width, height: 50)
        scrollView.frame = CGRect(x: 0, y: originY + 50, width: view.bounds.width, height: view.bounds.height - originY - 50 )
        scrollView.contentSize = CGSize(width: scrollView.bounds.width * CGFloat(titles.count), height: scrollView.bounds.height)
        for i in 0 ..< scrollView.subviews.count {
            let vcView = scrollView.subviews[i]
            vcView.frame = CGRect(x: CGFloat(i) * scrollView.bounds.width, y: 0, width: scrollView.bounds.width, height: scrollView.bounds.height)
        }
    }

}

// MARK: -  PageContainerDelegate, PageContainerDataSource
extension DemoTabBarViewController: PageTabBarDataSource, PageTabBarDelegate {
    
    func numberOfItems(in pageTabBar: PageTabBar) -> Int {
        return titles.count
    }
    
    func defaultSelectedIndex(in pageTabBar: PageTabBar) -> Int {
        return 5
    }
    
    func pageTabBar(_ pageTabBar: PageTabBar, titleForItemAt index: Int) -> String {
        return titles[index]
    }
    
    func titleFontForItem(in pageTabBar: PageTabBar) -> UIFont {
        return UIFont.systemFont(ofSize: 15, weight: .thin)
    }
    
    func titleHighlightedFontForItem(in pageTabBar: PageTabBar) -> UIFont {
        return UIFont.systemFont(ofSize: 20, weight: .bold)
    }
    
    func titleColorForItem(in pageTabBar: PageTabBar) -> UIColor {
        return .lightGray
    }
    
    func titleHighlightedColorForItem(in pageTabBar: PageTabBar) -> UIColor {
        return .red
    }
    
    func needsIndicatorView(in pageTabBar: PageTabBar) -> Bool {
        return false
    }

    func transitionAnimationType(in pageTabBar: PageTabBar) -> PageTabBarItemTransitionAnimation {
        return .smoothness
    }
    
//    func relayoutWhenWidthNotEnough(in pageTabBar: PageTabBar) -> Bool {
//        return false
//    }
    
}
