//
//  TYPageViewController.swift
//  TYPageViewController
//
//  Created by 藤井陽介 on 2017/06/05.
//  Copyright © 2017年 touyou. All rights reserved.
//

import UIKit

@objc public protocol TYPageViewControllerDelegate: class {
    @objc optional func pageViewController(_ pageViewController: TYPageViewController, willTransitionTo pendingViewControllers: [UIViewController])
    @objc optional func pageViewController(_ pageViewController: TYPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool)
    @objc optional func pageViewController(_ pageViewController: TYPageViewController, spineLocationFor orientation: UIInterfaceOrientation) -> UIPageViewControllerSpineLocation
    @objc optional func pageViewControllerSupportedInterfaceOrientations(_ pageViewController: TYPageViewController) -> UIInterfaceOrientationMask
    @objc optional func pageViewControllerPreferredInterfaceOrientationForPresentation(_ pageViewController: UIPageViewController) -> UIInterfaceOrientation
}

@objc public protocol TYPageViewControllerDataSource: class {
    func pageViewController(_ pageViewController: TYPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?
    func pageViewController(_ pageViewController: TYPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?
    @objc optional func presentationCount(for pageViewController: TYPageViewController) -> Int
    @objc optional func presentationIndex(for pageViewController: TYPageViewController)-> Int
}

open class TYPageViewController: UIViewController {
    
    // MARK: - Properties
    weak open var delegate: TYPageViewControllerDelegate?
    weak open var dataSource: TYPageViewControllerDataSource?
    
    fileprivate var _transitionStyle: UIPageViewControllerTransitionStyle?
    open var transitionStyle: UIPageViewControllerTransitionStyle {
        
        get {
            
            guard let transitionStyle = self._transitionStyle else {
        
                return .scroll
            }
            
            return transitionStyle
        }
    }
    
    fileprivate var _navigationOrientation: UIPageViewControllerNavigationOrientation?
    open var navigationOrientation: UIPageViewControllerNavigationOrientation {
        
        get {
            
            guard let navigationOrientation = self._navigationOrientation else {
        
                return .horizontal
            }
            
            return navigationOrientation
        }
    }
    
    fileprivate var _spineLocation: UIPageViewControllerSpineLocation?
    open var spineLocation: UIPageViewControllerSpineLocation {
        
        get {
            
            guard let spineLocation = self._spineLocation else {
                
                return .none
            }
            
            return spineLocation
        }
    }
    open var isDoubleSided: Bool = false
    
    fileprivate var _gestureRecognizers: [UIGestureRecognizer]?
    open var gestureRecognizers: [UIGestureRecognizer] {
        
        get {
            
            guard let gestureRecognizers = self._gestureRecognizers else {
                
                return []
            }
            
            return gestureRecognizers
        }
    }
    
    fileprivate var _viewControllers: [UIViewController]?
    open var viewControllers: [UIViewController]? {
        
        get {
            
            return _viewControllers
        }
    }
    
    fileprivate var backView = UIScrollView()
    fileprivate var isDragging = false

    // MARK: - Initializer
    
    fileprivate override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    public init(transitionStyle style: UIPageViewControllerTransitionStyle, navigationOrientation: UIPageViewControllerNavigationOrientation, options: [String : Any]? = nil) {
        self.init()
        _transitionStyle = style
        _navigationOrientation = navigationOrientation
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override open func loadView() {
        self.automaticallyAdjustsScrollViewInsets = false
        backView.delegate = self
        backView.decelerationRate = UIScrollViewDecelerationRateFast
        self.view = backView
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let width: CGFloat = 3.0 * self.view.bounds.size.width
        backView.contentSize = CGSize(width: width, height: self.view.bounds.size.height)
    }

    override open func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - open
    
    open func setViewControllers(_ viewControllers: [UIViewController]?, direction: UIPageViewControllerNavigationDirection, animated: Bool, completion: ((Bool) -> Swift.Void)? = nil) {
        
        // TODO: - Scroll and Change appeared ViewController
        guard var newViewControllers = viewControllers else {
            
            completion?(false)
            return
        }
        
        delegate?.pageViewController?(self, willTransitionTo: newViewControllers)
        
        guard var currentViewControllers = _viewControllers else {
            
            // 最初のviewController
            var viewFrame = self.view.bounds
            viewFrame.origin.x = self.view.bounds.size.width
            newViewControllers[0].view.frame = viewFrame
            addChildViewController(newViewControllers[0])
            backView.addSubview(newViewControllers[0].view)
            newViewControllers[0].didMove(toParentViewController: self)
            completion?(true)
            return
        }
        
        _viewControllers = newViewControllers
        
        switch direction {
        case .forward:
            currentViewControllers[0].willMove(toParentViewController: nil)
            currentViewControllers[0].view.removeFromSuperview()
            currentViewControllers[0].removeFromParentViewController()
            
            var viewFrame = self.view.bounds
            viewFrame.origin.x = self.view.bounds.size.width
            newViewControllers[0].view.frame = viewFrame
            addChildViewController(newViewControllers[0])
            backView.addSubview(newViewControllers[0].view)
            newViewControllers[0].didMove(toParentViewController: self)
            
        case .reverse:
            break
            
        }
        
        delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: currentViewControllers, transitionCompleted: true)
    }
    
    // TODO: - GestureRecognizer Function
}

extension TYPageViewController: UIScrollViewDelegate {
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        isDragging = true
    }
    
    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        isDragging = false
    }
}
