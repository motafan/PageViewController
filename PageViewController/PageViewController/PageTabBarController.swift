//
//  PageViewController.swift
//  PageViewController
//
//  Created by Fanfan Tan on 2021/12/5.
//  Copyright © 2021年 Fan. All rights reserved.
//

import UIKit

// MARK: -  行为代理
@objc public protocol PageTabBarControllerDelegate: AnyObject {
    
    /// 将要切换子控制器
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromController: fromController
    ///   - toController: toController
    @objc optional func pageTabBarController(_ pageTabBarController: PageTabBarController, willTransition fromController: UIViewController, toController: UIViewController)
    
    /// 完成切换子控制器
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromController: fromController
    ///   - toController: toController
    @objc optional func pageTabBarController(_ pageTabBarController: PageTabBarController, didFinishedTransition fromController: UIViewController, toController: UIViewController)
    
    /// 取消切换子控制器
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromController: fromController
    ///   - toController: toController
    @objc optional func pageTabBarController(_ pageTabBarController: PageTabBarController, didCancelledTransition fromController: UIViewController, toController: UIViewController)
    
    /// 拖动状态回调
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - fromIndex: fromIndex
    ///   - toIndex: toIndex
    ///   - percent: 进度百分比
    @objc optional func pageTabBarController(_ pageTabBarController: PageTabBarController, dragging fromIndex: Int, toIndex: Int, percent: CGFloat)
    
    /// 选中index的回调
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 当前index
    @objc optional func pageTabBarController(_ pageTabBarController: PageTabBarController, didSelected index: Int)
    
}

// MARK: -  数据源代理
@objc public protocol PageTabBarControllerDataSource: AnyObject {
    
    /// 选项数目
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 选项数目
    func numberOfItems(in pageViewController: PageTabBarController) -> Int
    
    /// index位置的item标题
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 位置
    /// - Returns: index位置的item标题
    func pageViewController(_ pageViewController: PageTabBarController, titleForItemAt index: Int) -> String
    
    /// index位置的childViewController
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 位置
    /// - Returns: index位置的childViewController
    func pageViewController(_ pageViewController: PageTabBarController, childViewContollerAt index: Int) -> UIViewController
    
    /// tabbar的frame，默认为 (0, 0, bounds.width, 50)
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: tabbar的frame
    @objc optional func tabbarFrame(in pageViewController: PageTabBarController) -> CGRect
    
    /// container的frame，默认为 (0, 50, bounds.width, bounds.height - 50)
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: container的frame
    @objc optional func containerFrame(in pageViewController: PageTabBarController) -> CGRect
    
    /// 默认选中位置，默认为0
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 默认选中位置
    @objc optional func defaultSelectedIndex(in pageViewController: PageTabBarController) -> Int
    
    /// index位置的item宽度，默认为自适应
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 位置
    /// - Returns: index位置的item宽度
    @objc optional func pageViewController(_ pageViewController: PageTabBarController, widthForItemAt index: Int) -> CGFloat
    
    /// 默认字体，默认为15号系统字体
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 默认字体
    @objc optional func titleFontForItem(in pageViewController: PageTabBarController) -> UIFont
    
    /// 高亮字体，默认为15号系统字体
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 高亮字体
    @objc optional func titleHighlightedFontForItem(in pageViewController: PageTabBarController) -> UIFont
    
    /// 默认字体颜色，默认为浅灰色
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 默认字体颜色
    @objc optional func titleColorForItem(in pageViewController: PageTabBarController) -> UIColor
    
    /// 高亮字体颜色，默认为黑色
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 高亮字体颜色
    @objc optional func titleHighlightedColorForItem(in pageViewController: PageTabBarController) -> UIColor
    
    /// item之间的间距，默认为10
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: item之间的间距
    @objc optional func spacingForItem(in pageViewController: PageTabBarController) -> CGFloat
    
    /// 是否开启当item总宽度小于总的宽度时居中显示所有item，并重新计算item之间的间距，默认开启
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 是否开启
    @objc optional func relayoutWhenWidthNotEnough(in pageViewController: PageTabBarController) -> Bool
    
    /// 是否需要指示器，默认为true
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 是否需要指示器
    @objc optional func needsIndicatorView(in pageViewController: PageTabBarController) -> Bool
    
    /// 指示器的颜色，默认为选中字体颜色
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 指示器的颜色
    @objc optional func colorForIndicatorView(in pageViewController: PageTabBarController) -> UIColor
    
    /// 指示器的高度，默认为3
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 指示器的高度
    @objc optional func heightForIndicatorView(in pageViewController: PageTabBarController) -> CGFloat
    
    /// 指示器距离底部的位置，默认为5
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 指示器距离底部的位置
    @objc optional func bottomForIndicatorView(in pageViewController: PageTabBarController) -> CGFloat
    
    /// 指示器的宽度，默认自适应
    ///
    /// - Parameters:
    ///   - pageViewController: pageViewController
    ///   - index: 位置
    /// - Returns: 宽度
    @objc optional func pageViewController(_ pageViewController: PageTabBarController, widthForIndicatorViewAt index: Int) -> CGFloat
    
    /// 切换动画，默认为none
    ///
    /// - Parameter pageViewController: pageViewController
    /// - Returns: 切换动画
    @objc optional func transitionAnimationType(in pageViewController: PageTabBarController) -> PageTabBarItemTransitionAnimation
    
}





// MARK: -  封装了PageViewController和PageTabBar的控制器
open class PageTabBarController: UIViewController {

    // MARK: -  Properties
    
    ///数据源代理
    open weak var dataSource: PageTabBarControllerDataSource?
    
    /// 行为代理
    open weak var delegate: PageTabBarControllerDelegate?
    
    /// 当前选中的下标
    open var selectedIndex: Int {
        return pageTabBar.selectedIndex
    }
    
    /// container
    private lazy var pageViewController: PageViewController = {
        let pageViewController = PageViewController(navigationOrientation: .horizontal)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        return pageViewController
    }()
    
    /// tabbar
    private lazy var pageTabBar: PageTabBar = {
        let pageTabBar = PageTabBar(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: 50))
        pageTabBar.dataSource = self
        return pageTabBar
    }()
    
    // MARK: -  Life Cycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    open override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageTabBar.frame = preferredTabbarFrame()
        pageViewController.view.frame = preferredContainerFrame()
    }
    
    // MARK: - Private Methods
    
    private func setup() {
        addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        view.addSubview(pageViewController.view)
        pageTabBar.contentScrollView = pageViewController.scrollView
        view.addSubview(pageTabBar)
    }
    
    // MARK: -  Public Methods，各种配置，子类可以覆写这些方法

    open func preferredNumberOfItems() -> Int {
        return dataSource?.numberOfItems(in: self) ?? 0
    }
    
    open func preferredTitleForItem(at index: Int) -> String {
        return dataSource?.pageViewController(self, titleForItemAt: index) ?? ""
    }
    
    open func preferredChildViewContoller(at index: Int) -> UIViewController {
        return dataSource?.pageViewController(self, childViewContollerAt: index) ?? UIViewController()
    }
    
    open func preferredTabbarFrame() -> CGRect {
        return dataSource?.tabbarFrame?(in: self) ?? CGRect(x: 0, y: 0, width: view.bounds.width, height: 50)
    }
    
    open func preferredContainerFrame() -> CGRect {
        return dataSource?.containerFrame?(in: self) ?? CGRect(x: 0, y: 50, width: view.bounds.width, height: view.bounds.height - 50)
    }
    
    open func preferredDefaultSelectedIndex() -> Int {
        return dataSource?.defaultSelectedIndex?(in: self) ?? 0
    }
    
    open func preferredWidthForItem(at index: Int) -> CGFloat {
        return dataSource?.pageViewController?(self, widthForItemAt: index) ?? PageViewAutomaticDimension
    }
    
    open func preferredTitleFontForItem() -> UIFont {
        return dataSource?.titleFontForItem?(in: self) ?? UIFont.systemFont(ofSize: 15)
    }
    
    open func preferredTitleHighlightedFontForItem() -> UIFont {
        return dataSource?.titleHighlightedFontForItem?(in: self) ?? UIFont.systemFont(ofSize: 15)
    }
    
    open func preferredTitleColorForItem() -> UIColor {
        return dataSource?.titleColorForItem?(in: self) ?? .lightGray
    }
    
    open func preferredTitleHighlightedColorForItem() -> UIColor {
        return dataSource?.titleHighlightedColorForItem?(in: self) ?? .black
    }
    
    open func preferredSpacingForItem() -> CGFloat {
        return dataSource?.spacingForItem?(in: self) ?? 10
    }
    
    open func preferredRelayoutWhenWidthNotEnough() -> Bool {
        return dataSource?.relayoutWhenWidthNotEnough?(in: self) ?? true
    }
    
    open func preferredNeedsIndicatorView() -> Bool {
        return dataSource?.needsIndicatorView?(in: self) ?? true
    }
    
    open func preferredColorForIndicatorView() -> UIColor {
        return dataSource?.colorForIndicatorView?(in: self) ?? preferredTitleHighlightedColorForItem()
    }
    
    open func preferredHeightForIndicatorView() -> CGFloat {
        return dataSource?.heightForIndicatorView?(in: self) ?? 3
    }
   
    open func preferredBottomForIndicatorView() -> CGFloat {
        return dataSource?.bottomForIndicatorView?(in: self) ?? 5
    }
    
    open func preferredWidthForIndicatorView(at index: Int) -> CGFloat {
        return dataSource?.pageViewController?(self, widthForIndicatorViewAt: index) ?? PageViewAutomaticDimension
    }
    
    open func preferredTransitionAnimationType() -> PageTabBarItemTransitionAnimation {
        return dataSource?.transitionAnimationType?(in: self) ?? .none
    }
}

// MARK: -  PageContainerDataSource
extension PageTabBarController: PageViewControllerDataSource {
    
    public func numberOfChildViewControllers(in pageViewController: PageViewController) -> Int {
        return preferredNumberOfItems()
    }
    
    public func pageViewController(_ pageViewController: PageViewController, childViewContollerAt index: Int) -> UIViewController {
        return preferredChildViewContoller(at: index)
    }
    
    public func defaultCurrentIndex(in pageViewController: PageViewController) -> Int {
        return preferredDefaultSelectedIndex()
    }
    
}

// MARK: -  PageContainerDelegate
extension PageTabBarController: PageViewControllerDelegate {
    
    public func pageViewController(_ pageViewController: PageViewController, willTransition fromController: UIViewController, toController: UIViewController) {
        delegate?.pageTabBarController?(self, willTransition: fromController, toController: toController)
    }
    
    public func pageViewController(_ pageViewController: PageViewController, didFinishedTransition fromController: UIViewController, toController: UIViewController) {
        delegate?.pageTabBarController?(self, didFinishedTransition: fromController, toController: toController)
    }
    
    public func pageViewController(_ pageViewController: PageViewController, didCancelledTransition fromController: UIViewController, toController: UIViewController) {
        delegate?.pageTabBarController?(self, didCancelledTransition: fromController, toController: toController)
    }
    
    public func pageViewController(_ pageViewController: PageViewController, dragging fromIndex: Int, toIndex: Int, percent: CGFloat) {
        delegate?.pageTabBarController?(self, dragging: fromIndex, toIndex: toIndex, percent: percent)
    }
    
    public func pageViewController(_ pageViewController: PageViewController, didSelected index: Int) {
        delegate?.pageTabBarController?(self, didSelected: index)
    }
    
}

// MARK: -  PageTabBarDelegate
extension PageTabBarController: PageTabBarDataSource {
    
    public func numberOfItems(in pageTabBar: PageTabBar) -> Int {
        return preferredNumberOfItems()
    }
    
    public func pageTabBar(_ pageTabBar: PageTabBar, titleForItemAt index: Int) -> String {
        return preferredTitleForItem(at: index)
    }
    
    public func defaultSelectedIndex(in pageTabBar: PageTabBar) -> Int {
        return preferredDefaultSelectedIndex()
    }
    
    public func pageTabBar(_ pageTabBar: PageTabBar, widthForIndicatorViewAt index: Int) -> CGFloat {
        return preferredWidthForIndicatorView(at: index)
    }
    
    public func pageTabBar(_ pageTabBar: PageTabBar, widthForItemAt index: Int) -> CGFloat {
        return preferredWidthForItem(at: index)
    }
    
    public func colorForIndicatorView(in pageTabBar: PageTabBar) -> UIColor {
        return preferredColorForIndicatorView()
    }
    
    public func spacingForItem(in pageTabBar: PageTabBar) -> CGFloat {
        return preferredSpacingForItem()
    }
    
    public func needsIndicatorView(in pageTabBar: PageTabBar) -> Bool {
        return preferredNeedsIndicatorView()
    }
    
    public func titleFontForItem(in pageTabBar: PageTabBar) -> UIFont {
        return preferredTitleFontForItem()
    }
    
    public func titleColorForItem(in pageTabBar: PageTabBar) -> UIColor {
        return preferredTitleColorForItem()
    }
    
    public func bottomForIndicatorView(in pageTabBar: PageTabBar) -> CGFloat {
        return preferredBottomForIndicatorView()
    }
    
    public func heightForIndicatorView(in pageTabBar: PageTabBar) -> CGFloat {
        return preferredHeightForIndicatorView()
    }
    
    public func relayoutWhenWidthNotEnough(in pageTabBar: PageTabBar) -> Bool {
        return preferredRelayoutWhenWidthNotEnough()
    }
    
    public func titleHighlightedFontForItem(in pageTabBar: PageTabBar) -> UIFont {
        return preferredTitleHighlightedFontForItem()
    }
    
    public func titleHighlightedColorForItem(in pageTabBar: PageTabBar) -> UIColor {
        return preferredTitleHighlightedColorForItem()
    }
    
    public func transitionAnimationType(in pageTabBar: PageTabBar) -> PageTabBarItemTransitionAnimation {
        return preferredTransitionAnimationType()
    }
}

