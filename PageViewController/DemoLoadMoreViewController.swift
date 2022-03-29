//
//  DemoLoadMoreViewController.swift
//  PageViewController
//
//  Created by Fanfan Tan on 2021/12/5.
//  Copyright © 2021年 Fan. All rights reserved.
//

import UIKit

class DemoLoadMoreViewController: UIViewController {

    private var count: Int = 5
    private var isLoading: Bool = false
    
    private lazy var pageViewController: PageViewController = {
        let pageViewController = PageViewController(navigationOrientation: .vertical)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        automaticallyAdjustsScrollViewInsets = false
        title = "Index\(1)"
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        view.addSubview(pageViewController.view)
    }
    
    deinit {
        print("DemoLoadMoreViewController deinit")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navigationHeight = UIApplication.shared.statusBarFrame.height + 44
        pageViewController.view.frame = CGRect(x: 0, y: navigationHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navigationHeight)
    }

}

// MARK: -  PageContainerDelegate, PageContainerDataSource
extension DemoLoadMoreViewController: PageViewControllerDelegate, PageViewControllerDataSource {
    
    func numberOfChildViewControllers(in pageViewController: PageViewController) -> Int {
        return count
    }
    
    func pageViewController(_ pageViewController: PageViewController, childViewContollerAt index: Int) -> UIViewController {
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailVC.text = "Index\(index)"
        return detailVC
    }
    
    func defaultCurrentIndex(in pageViewController: PageViewController) -> Int {
        return 1
    }
    
    func pageViewController(_ pageViewController: PageViewController, didSelected index: Int) {
        title = "Index\(index)"
        if count - index < 3 && count < 15 && !isLoading {
            isLoading = true
            print("加载中...")
            /// 模拟网络请求
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.count += 5
                self.pageViewController.reloadData(.notReload)
                print("加载完成")
                self.isLoading = false
            }
        }
    }
    
}
