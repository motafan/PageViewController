//
//  PageContentView.swift
//  PageViewController
//
//  Created by Fanfan Tan on 2021/12/5.
//  Copyright © 2021年 Fan. All rights reserved.
//

import UIKit

/// 设置contentOffset之后的回调
typealias PageContentViewDidSetContentOffsetCallback = (_ index: Int, _ animated: Bool) -> ()

open class PageContentView: UIScrollView {
    

    let navigationOrientation: PageViewController.NavigationOrientation

    // MARK: -  Properties
    
    /// 设置contentOffset之后的回调
    var didSetContentOffsetCallback: PageContentViewDidSetContentOffsetCallback?
    
    // MARK: -  init
    
    public init(navigationOrientation: PageViewController.NavigationOrientation) {
        self.navigationOrientation = navigationOrientation
        super.init(frame: .zero)
        setup()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        self.navigationOrientation = .horizontal
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        isPagingEnabled = true
        backgroundColor = .clear
        scrollsToTop = false
        bounces = false
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior =  .never
        }
    }

    // MARK: -  override
    
    open override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if let didSetContentOffsetCallback = didSetContentOffsetCallback {
            /// 手动设置contentOffset的动画
            let index = calculateIndex(of: contentOffset)
            didSetContentOffsetCallback(index, animated)
        } else {
            super.setContentOffset(contentOffset, animated: animated)
        }
    }
    
}

// MARK: -  Public Methods
extension PageContentView {
    
    /// 计算index
    ///
    /// - Parameter contentOffsetX: x偏移量
    /// - Returns: index
    func calculateIndex(of contentOffset: CGPoint = CGPoint(x: -1, y: -1)) -> Int {
        
        switch self.navigationOrientation {
        case .horizontal:
            var offsetX = contentOffset.x
            if contentOffset.x == -1 {
                offsetX = self.contentOffset.x
            }
            var index = Int(offsetX / bounds.width)
            if index < 0 {
                index = 0
            }
            return index
        case .vertical:
            var offsetY = contentOffset.y
            if contentOffset.y == -1 {
                offsetY = self.contentOffset.y
            }
            var index = Int(offsetY / bounds.height)
            if index < 0 {
                index = 0
            }
            return index
        }
    }
    
    /// 计算偏移
    ///
    /// - Parameter index: 位置
    /// - Returns: 偏移
    func calculateContentOffset(with index: Int) -> CGPoint {
        switch self.navigationOrientation {
        case .horizontal:
            let width = bounds.width
            let maxWidth = contentSize.width
            var offsetX = CGFloat(index) * width
            if offsetX < 0 {
                offsetX = 0
            }
            if maxWidth > 0 && offsetX > maxWidth - width {
                offsetX = maxWidth - width
            }
            return CGPoint(x: offsetX, y: 0)
        case .vertical:
            let height = bounds.height
            let maxHeight = contentSize.height
            var offsetY = CGFloat(index) * height
            if offsetY < 0 {
                offsetY = 0
            }
            if maxHeight > 0 && offsetY > maxHeight - height {
                offsetY = maxHeight - height
            }
            return CGPoint(x: 0, y: offsetY)
        }
    }
    
    /// 计算某一页的frame
    ///
    /// - Parameter index: 位置
    /// - Returns: frame
    func calculateVisibleViewControllerFrame(with index: Int) -> CGRect {
        switch self.navigationOrientation {
        case .horizontal:
            let offsetX = CGFloat(index) * bounds.width
            return CGRect(x: offsetX, y: 0, width: bounds.width, height: bounds.height)
        case .vertical:
            let offsetY = CGFloat(index) * bounds.height
            return CGRect(x: 0, y: offsetY, width: bounds.width, height: bounds.height)
        }
    }
    
}
