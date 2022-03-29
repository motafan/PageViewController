//
//  DemoContainerViewController.swift
//  PageViewController
//
//  Created by Fanfan Tan on 2021/12/5.
//  Copyright © 2021年 Fan. All rights reserved.
//

import UIKit

class DemoContainerViewController: UIViewController {

    private let titles = ["大菠萝", "苹果","芒果", "梨", "香蕉","橘子", "哈密瓜", "西瓜", "葡萄", "橙子", "柚子"]
    
    private lazy var pageViewController: PageViewController = {
        let pageViewController = PageViewController(navigationOrientation: .horizontal)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        automaticallyAdjustsScrollViewInsets = false
        segment.selectedSegmentIndex = 1
        pageViewController.setCurrentIndex(1, animated: false)
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        view.addSubview(pageViewController.view)
    }

    deinit {
        print("DemoContainerViewController deinit")
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let navigationHeight = UIApplication.shared.statusBarFrame.height + 44
        pageViewController.view.frame = CGRect(x: 0, y: navigationHeight, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height - navigationHeight)
    }

    @IBAction func segmentDidChanged(_ sender: UISegmentedControl) {
        pageViewController.setCurrentIndex(sender.selectedSegmentIndex, animated: true)
    }
    
    @IBAction func reloadAction(_ sender: Any) {
        let randomTitles = randomElements()
        segment.removeAllSegments()
        for randomTitle in randomTitles {
            segment.insertSegment(withTitle: randomTitle, at: 0, animated: false)
        }
        segment.selectedSegmentIndex = min(randomTitles.count - 1, pageViewController.currentIndex)
        segment.sizeToFit()
        segment.layoutIfNeeded()
        pageViewController.reloadData()
    }
    
    private func randomElements() -> [String] {
        var randomElements: [String] = []
        let randomCount = Int(arc4random() % 3) + 2
        var copyElements = titles
        for _ in 0 ..< randomCount {
            // 如果copyElements的元素取光了
            if copyElements.isEmpty {
                break
            }
            let randomIndex = Int(arc4random_uniform(UInt32(copyElements.count)))
            randomElements.append(copyElements[randomIndex])
            copyElements.remove(at: randomIndex)
        }
        return randomElements
    }
    
}

// MARK: -  PageContainerDelegate, PageContainerDataSource
extension DemoContainerViewController: PageViewControllerDelegate, PageViewControllerDataSource {
 
    func numberOfChildViewControllers(in pageViewController: PageViewController) -> Int {
        return segment.numberOfSegments
    }
    
    func pageViewController(_ pageViewController: PageViewController, childViewContollerAt index: Int) -> UIViewController {
        let detailVC = DetailViewController(nibName: "DetailViewController", bundle: nil)
        detailVC.text = segment.titleForSegment(at: index) ?? ""
        return detailVC
    }
    
    
    func pageViewController(_ pageViewController: PageViewController, willTransition fromController: UIViewController, toController: UIViewController) {
//        print("willTransition: \(pageViewController.currentIndex) fromController: \(fromController) toController: \(toController)")
    }
    
    func pageViewController(_ pageViewController: PageViewController, didFinishedTransition fromController: UIViewController, toController: UIViewController) {
//        print("didFinishedTransition: \(pageViewController.currentIndex) fromController: \(fromController) toController: \(toController)")
    }
    
    func pageViewController(_ pageViewController: PageViewController, didCancelledTransition fromController: UIViewController, toController: UIViewController) {
//        print("didCancelledTransition: \(pageViewController.currentIndex) fromController: \(fromController) toController: \(toController)")
    }
    
    func pageViewController(_ pageViewController: PageViewController, dragging fromIndex: Int, toIndex: Int, percent: CGFloat) {
//        print("dragging: \(pageViewController.currentIndex) fromIndex: \(fromIndex) toIndex: \(toIndex) percent: \(percent)")
    }
    
    func pageViewController(_ pageViewController: PageViewController, didSelected index: Int) {
        segment.selectedSegmentIndex = index
    }
    
}
