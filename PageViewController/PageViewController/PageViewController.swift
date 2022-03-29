//
//  PageViewController.swift
//  PageViewController
//
//  Created by Fanfan Tan on 2021/12/5.
//  Copyright © 2021年 Fan. All rights reserved.
//

import UIKit

// MARK: -  行为代理
@objc public protocol PageViewControllerDelegate: AnyObject {
    
    /// 将要切换子控制器
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromController: fromController
    ///   - toController: toController
    @objc optional func pageViewController(_ pageViewController: PageViewController, willTransition fromController: UIViewController, toController: UIViewController)
    
    /// 完成切换子控制器
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromController: fromController
    ///   - toController: toController
    @objc optional func pageViewController(_ pageViewController: PageViewController, didFinishedTransition fromController: UIViewController, toController: UIViewController)
    
    /// 取消切换子控制器
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromController: fromController
    ///   - toController: toController
    @objc optional func pageViewController(_ pageViewController: PageViewController, didCancelledTransition fromController: UIViewController, toController: UIViewController)
    
    /// 拖动状态回调
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - percent: 进度百分比
    @objc optional func pageViewController(_ pageViewController: PageViewController, dragging fromIndex: Int, toIndex: Int, percent: CGFloat)
    
    /// 选中index的回调
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 当前index
    @objc optional func pageViewController(_ pageViewController: PageViewController, didSelected index: Int)

}

// MARK: -  数据源代理
@objc public protocol PageViewControllerDataSource: AnyObject {
    
    /// 获取childViewController的数目
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: childViewController的数目
    func numberOfChildViewControllers(in pageViewController: PageViewController) -> Int
    
    /// 获取index位置的childViewController
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 位置
    /// - Returns: index位置的childViewController
    func pageViewController(_ pageViewController: PageViewController, childViewContollerAt index: Int) -> UIViewController
    
    /// 默认选中位置，默认为0
    ///
    /// - Parameter pageTabBar: pageViewController
    /// - Returns: 默认选中位置
    @objc optional func defaultCurrentIndex(in pageViewController: PageViewController) -> Int
    
}



public extension PageViewController {
    
    // MARK: -  重新加载子控制器的方式
     enum Reload  {
        /// 所有
        case all
        /// 除了当前
        case exceptCurrentIndex
        /// 都不重新加载
        case notReload
    }
}

public extension PageViewController {
    
     enum NavigationOrientation : Int {

        case horizontal = 0

        case vertical = 1
    }
}



// MARK: -  PageViewController内容控制器
open class PageViewController: UIViewController {
    
    public init(navigationOrientation: NavigationOrientation) {
        self.navigationOrientation = navigationOrientation
        super.init(nibName: nil, bundle: nil)
    }

    required  public init?(coder: NSCoder) {
        self.navigationOrientation = .horizontal
        super.init(coder: coder)
        
    }

    // MARK: - Properties
    
    private let navigationOrientation: NavigationOrientation
    
    /// 数据源代理
    open weak var dataSource: PageViewControllerDataSource? {
        didSet {
            if let defaultIndex = dataSource?.defaultCurrentIndex?(in: self) {
                currentIndex = min(max(0, defaultIndex), numberOfChildViewControllers() - 1)
            }
        }
    }
    
    /// 代理
    open weak var delegate: PageViewControllerDelegate?
    
    /// 当前的index
    open private (set) var currentIndex: Int = 0
    
    /// 当前子控制器
    open var currentChildViewController: UIViewController? {
        return childViewController(at: currentIndex)
    }
    
    /// 滚动视图
    open lazy var scrollView: PageContentView = {
        let scrollView = PageContentView(navigationOrientation: self.navigationOrientation)
        scrollView.frame = view.bounds
        scrollView.delegate = self
        return scrollView
    }()
    
    /// 缓存的子控制器
    private var cacheViewControllers: [Int: UIViewController] = [:]
    
    /// 初始滑动的偏移量
    private var lastOffset: CGPoint = .zero
    
    /// 初始滑动的index
    private var lastIndex: Int = 0
    
    /// 是否已经处理了子控制器的生命周期函数
    private var hasProcessAppearance: Bool = false
    
    /// 可能的下一页
    private var potentialIndex: Int = -999
    
    /// 设置false，手动控制子控制器的生命周期
    open override var shouldAutomaticallyForwardAppearanceMethods: Bool {
        return false
    }
    
    // MARK: -  Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        reloadChildViewControllers()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        currentChildViewController?.beginAppearanceTransition(true, animated: true)
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        currentChildViewController?.endAppearanceTransition()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        currentChildViewController?.beginAppearanceTransition(false, animated: true)
    }
    
    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        currentChildViewController?.endAppearanceTransition()
    }

    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        /// 重新布局
        relayoutScrollView()
    }
    
    /// 收到内存警告
    open override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        /// 除了当前子控制器，清空所有 
        clearCaches(.exceptCurrentIndex)
    }
}

// MARK: -  Private Methods
extension PageViewController {
    
    /// 初始化设置
    private func setup() {
//        automaticallyAdjustsScrollViewInsets = false
        view.backgroundColor = .clear
        view.addSubview(scrollView)
        scrollView.didSetContentOffsetCallback = { [weak self] (index, animated) in
            guard let `self` = self else { return }
            self.setCurrentIndex(index, animated: animated)
        }
    }

    /// 重新加载子控制器
    ///
    /// - Parameter flag: 是否回调子控制器生命周期函数，默认false
    private func reloadChildViewControllers(shouldForwardAppearance flag: Bool = false) {
        guard isViewLoaded else { return }
        /// 重新布局scrollView
        relayoutScrollView()
        /// 添加当前子控制器
        addChildViewContoller(at: currentIndex, shouldForwardAppearance: flag)
    }
    
    /// 重新布局scrollView
    private func relayoutScrollView() {
        guard isViewLoaded else { return }
        let lastFrame = scrollView.frame
        scrollView.frame = view.bounds
        scrollView.contentSize  = scrollViewContentSize()
        
        /// 设置contentOffset，如果正在拖动，不做设置
        if !scrollView.isTracking && !scrollView.isDecelerating {
            let currentOffsetX = scrollView.calculateContentOffset(with: currentIndex).x
            scrollView.contentOffset = CGPoint(x: currentOffsetX, y: 0)
        }
        if lastFrame != scrollView.frame {
            /// 重新设置子视图的位置
            for (index, childViewController) in cacheViewControllers {
                childViewController.view.frame = scrollView.calculateVisibleViewControllerFrame(with: index)
            }
        }
        resetCurrentState()
    }
    
    private func scrollViewContentSize() -> CGSize {
        let controllerCount = numberOfChildViewControllers()
        switch self.navigationOrientation {
        case .horizontal:
            return CGSize(width: CGFloat(controllerCount) * scrollView.bounds.width, height: scrollView.bounds.height)
        case .vertical:
            return CGSize(width: scrollView.bounds.width, height: CGFloat(controllerCount) * scrollView.bounds.height)
        }
    }
    
    /// 重新设置当前状态
    private func resetCurrentState() {
        hasProcessAppearance = false
        lastIndex = currentIndex
        lastOffset = scrollView.contentOffset
        /// 重新设置currentIndex
        currentIndex = scrollView.calculateIndex()
    }
    
    /// 获取子控制器数目
    ///
    /// - Returns: 子控制器数目
    private func numberOfChildViewControllers() -> Int {
        return dataSource?.numberOfChildViewControllers(in: self) ?? 0
    }
    
    /// 获取子控制器
    ///
    /// - Parameter index: 子控制器的位置
    /// - Returns: 子控制器
    private func childViewController(at index: Int) -> UIViewController? {
        /// 如果index越界，返回nil
        if index < 0 || index >= numberOfChildViewControllers()  {
            return nil
        }
        /// 如果有缓存，直接取缓存
        if let cacheViewController = cacheViewControllers[index] {
            return cacheViewController
        }
        return dataSource?.pageViewController(self, childViewContollerAt: index)
    }
    
    /// 添加子控制器
    ///
    /// - Parameters:
    ///   - index: 位置
    ///   - flag: 是否回调子控制器的生命周期函数，默认false
    /// - Returns: 子控制器
    @discardableResult
    private func addChildViewContoller(at index: Int, shouldForwardAppearance flag: Bool = false) -> UIViewController? {
        guard let childViewController = childViewController(at: index) else {
            return nil
        }
        if children.contains(childViewController) {
            return childViewController
        }
        /// 设置frame
        childViewController.view.frame = scrollView.calculateVisibleViewControllerFrame(with: index)
        scrollView.addSubview(childViewController.view)
        /// 回调子控制器的生命周期函数
        if flag {
            childViewController.beginAppearanceTransition(true, animated: true)
            childViewController.endAppearanceTransition()
        }
        /// 添加
        addChild(childViewController)
        childViewController.didMove(toParent: self)
        /// 添加到缓存中
        cacheViewControllers[index] = childViewController
        return childViewController
    }

    /// 清除缓存
    ///
    /// - Parameter clearType: 清除缓存的方式，默认清除所有
    private func clearCaches(_ clearType: PageViewController.Reload = .all) {
        /// 移除子控制器
        for (index, childViewController) in cacheViewControllers {
            if clearType == .exceptCurrentIndex {
                if index == currentIndex && index < numberOfChildViewControllers() {
                    continue
                }
            } else if clearType == .notReload {
                if index < numberOfChildViewControllers() {
                    continue
                }
            }
            removeChildViewContoller(childViewController)
            cacheViewControllers.removeValue(forKey: index)
        }
    }
    
    /// 移除子控制器
    ///
    /// - Parameter childViewContoller: 子控制器
    private func removeChildViewContoller(_ childViewController: UIViewController) {
        childViewController.willMove(toParent: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParent()
    }
    
    /// 开始更新子控制器
    private func beginUpdateChildViewControllers() {
        if currentIndex == potentialIndex {
            return
        }
        /// 开始切换
        beginTransitionChildViewController(fromIndex: currentIndex, toIndex: potentialIndex)
    }
    
    /// 结束更新
    private func endUpdateChildViewControllers() {
        resetCurrentState()
        endTransitionChildViewController(fromIndex: lastIndex, toIndex: potentialIndex)
    }
    
    /// 开始切换子控制器
    ///
    /// - Parameters:
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    private func beginTransitionChildViewController(fromIndex: Int, toIndex: Int) {
        guard let newController = addChildViewContoller(at: toIndex),
            let oldController = childViewController(at: fromIndex) else { return }
        /// oldController消失, newController出现
        oldController.beginAppearanceTransition(false, animated: true)
        newController.beginAppearanceTransition(true, animated: true)
        /// 代理回调
        delegate?.pageViewController?(self, willTransition: oldController, toController: newController)
    }
    
    /// 结束切换子控制器
    ///
    /// - Parameters:
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    private func endTransitionChildViewController(fromIndex: Int, toIndex: Int) {
        guard let oldController = childViewController(at: fromIndex),
            let newController = childViewController(at: toIndex) else { return }
        if potentialIndex == currentIndex { /// 已切换
            oldController.endAppearanceTransition()
            newController.endAppearanceTransition()
            /// 代理回调
            delegate?.pageViewController?(self, didFinishedTransition: oldController, toController: newController)
            delegate?.pageViewController?(self, didSelected: currentIndex)
        } else {  /// 未切换
            oldController.beginAppearanceTransition(true, animated: true)
            oldController.endAppearanceTransition()
            newController.beginAppearanceTransition(false, animated: true)
            newController.endAppearanceTransition()
            /// 代理回调
            delegate?.pageViewController?(self, didCancelledTransition: oldController, toController: newController)
        }
    }
    
    /// 自定义scrollView的滚动动画
    ///
    /// - Parameters:
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    private func customScrollAnimation(fromIndex: Int, toIndex: Int) {
        guard let oldController = childViewController(at: fromIndex) else { return }
        let oldViewFrame = oldController.view.frame
        var nearestIndex: Int
        if fromIndex > toIndex {
            nearestIndex = toIndex + 1
        } else {
            nearestIndex = toIndex - 1
        }
        /// 将当前控制器的view，移动到toIndex的旁边
        scrollView.contentOffset = scrollViewContentOffset(of: nearestIndex)
        oldController.view.frame.origin = controllerViewOrigin(of: nearestIndex)
        /// 将其置于最上层
        scrollView.bringSubviewToFront(oldController.view)
        UIView.animate(withDuration: 0.25, animations: {
            self.scrollView.contentOffset = self.scrollViewContentOffset(of: toIndex)
        }) { (_) in
            oldController.view.frame = oldViewFrame
            self.endUpdateChildViewControllers()
        }
    }
    
    private func controllerViewOrigin(of index: Int) -> CGPoint {
        switch self.navigationOrientation {
        case .horizontal:
            return CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0)
        case .vertical:
            return CGPoint(x: 0, y: CGFloat(index) * scrollView.bounds.height)
        }
    }
    
    private func scrollViewContentOffset(of index: Int) -> CGPoint {
        switch self.navigationOrientation {
        case .horizontal:
            return CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0)
        case .vertical:
            return CGPoint(x: 0, y: CGFloat(index) * scrollView.bounds.height)
        }
    }
}

// MARK: -  Public Methods
extension PageViewController {
    
    /// 重新加载数据
    open func reloadData(_ reloadType: PageViewController.Reload = .all) {
        clearCaches(reloadType)
        reloadChildViewControllers(shouldForwardAppearance: true)
    }
    
    /// 重新设置当前页
    open func setCurrentIndex(_ index: Int, animated: Bool) {
        /// 如果还没加载成功，说明是设置默认index
        if !isViewLoaded {
            currentIndex = index
            return
        }
        /// 如果index越界或index等于currentIndex，不处理
        if index < 0 || index >= numberOfChildViewControllers() || currentIndex == index {
            return
        }
        potentialIndex = index
        beginUpdateChildViewControllers()
        if !animated { /// 如果不执行滚动动画
            scrollView.contentOffset = CGPoint(x: CGFloat(index) * scrollView.bounds.width, y: 0)
            endUpdateChildViewControllers()
        } else {
            /// 自定义滚动动画
            customScrollAnimation(fromIndex: currentIndex, toIndex: potentialIndex)
        }
    }
}

// MARK: -  UIScrollViewDelegate
extension PageViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        /// 如果不是拖动的，不做处理
        if !scrollView.isTracking && !scrollView.isDecelerating {
            return
        }
        
        switch self.navigationOrientation {
        case .horizontal:
            let diffX = scrollView.contentOffset.x - lastOffset.x
            let percent = abs(diffX / scrollView.bounds.width)
            /// 滑动状态回调
            delegate?.pageViewController?(self, dragging: currentIndex, toIndex: potentialIndex, percent: percent)
            if diffX > 0 { /// 向左
                if !hasProcessAppearance || potentialIndex != currentIndex + 1 {
                    hasProcessAppearance = true
                    /// 如果已经向右滑动过又向左滑动
                    if potentialIndex == currentIndex - 1 {
                        endTransitionChildViewController(fromIndex: currentIndex, toIndex: potentialIndex)
                    }
                    potentialIndex = currentIndex + 1
                    beginUpdateChildViewControllers()
                }
            } else if diffX < 0 { /// 向右
                if !hasProcessAppearance || potentialIndex != currentIndex - 1 {
                    hasProcessAppearance = true
                    /// 如果已经向左滑动过又向右滑动
                    if potentialIndex == currentIndex + 1 {
                        endTransitionChildViewController(fromIndex: currentIndex, toIndex: potentialIndex)
                    }
                    potentialIndex = currentIndex - 1
                    beginUpdateChildViewControllers()
                }
            }
        case .vertical:
            let diffY = scrollView.contentOffset.y - lastOffset.y
            let percent = abs(diffY / scrollView.bounds.height)
            /// 滑动状态回调
            delegate?.pageViewController?(self, dragging: currentIndex, toIndex: potentialIndex, percent: percent)
            if diffY > 0 { /// 向下
                if !hasProcessAppearance || potentialIndex != currentIndex + 1 {
                    hasProcessAppearance = true
                    /// 如果已经向右滑动过又向左滑动
                    if potentialIndex == currentIndex - 1 {
                        endTransitionChildViewController(fromIndex: currentIndex, toIndex: potentialIndex)
                    }
                    potentialIndex = currentIndex + 1
                    beginUpdateChildViewControllers()
                }
            } else if diffY < 0 { /// 向上
                if !hasProcessAppearance || potentialIndex != currentIndex - 1 {
                    hasProcessAppearance = true
                    /// 如果已经向左滑动过又向右滑动
                    if potentialIndex == currentIndex + 1 {
                        endTransitionChildViewController(fromIndex: currentIndex, toIndex: potentialIndex)
                    }
                    potentialIndex = currentIndex - 1
                    beginUpdateChildViewControllers()
                }
            }
        }
        
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate && hasProcessAppearance {
            endUpdateChildViewControllers()
        }
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if hasProcessAppearance {
            endUpdateChildViewControllers()
        }
    }
    
    public func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        endUpdateChildViewControllers()
    }
}
