//
//  HorizontalPagedView.swift
//  HorizontalPagedView
//
//  Created by Ilya Senchukov on 14.08.2021.
//

import UIKit

public class HorizontalPagedView: UIScrollView {

    weak var parent: UIViewController!
    private var pages: [UIViewController] = []

    public var currentPage: UIViewController?
    public var currentIndex = 0

    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }

    func commonInit() {
        showsHorizontalScrollIndicator = false
        showsVerticalScrollIndicator = false
        setupGestureRecognizer()
    }

}

extension HorizontalPagedView {

    // Execute after layouting subviews of view controller
    func start() {
        guard let firstPage = pages.first else { return }
        firstPage.view.frame.size.height = frame.height
        currentPage = firstPage
        addSubview(firstPage.view)
    }

    // Execute when size of container view has changed
    func didChangeSize() {
        subviews.forEach { subview in
            subview.frame.size = frame.size
        }
    }

    func addPages(_ pages: [UIViewController]) {
        pages.forEach { addPage($0) }
    }

    func addPage(_ page: UIViewController) {
        page.view.frame.origin = .init(x: contentSize.width, y: 0)
        contentSize = .init(width: contentSize.width + frame.width,
                            height: frame.height)
        pages.append(page)
        page.move(to: parent)
        addSubview(page.view)
    }

}

private extension HorizontalPagedView {

    func setupGestureRecognizer() {
        let scrollGestureRecognizer = UIPanGestureRecognizer(target: self,
                                                             action: #selector(handleScroll))
        addGestureRecognizer(scrollGestureRecognizer)
    }

}

private extension HorizontalPagedView {

    func addNonVisibleSubviews(for index: Int) {
        pages.enumerated().forEach { idx, page in
            page.view.isHidden = !(idx == max(index - 1, 0) || idx == min(index + 1, pages.count) || idx == index)
        }

    }

    func removeNonVisibleSubviews() {
        pages.forEach { page in
            page.view.isHidden = Int(page.view.frame.origin.x / frame.width) != currentIndex
        }

        currentPage = pages[currentIndex]
    }

}

private extension HorizontalPagedView {

    func scrollDidBegan(gesture: UIPanGestureRecognizer) {
        addNonVisibleSubviews(for: currentIndex)
    }

    func didScroll(gesture: UIPanGestureRecognizer) {
        let translationX = gesture.translation(in: self).x
        contentOffset.x = CGFloat(currentIndex) * frame.width - translationX

        if contentOffset.x < 0 {
            contentOffset.x = 0
            gesture.state = .ended
        } else if contentOffset.x > contentSize.width - frame.width {
            contentOffset.x = contentSize.width - frame.width
            gesture.state = .ended
        }
    }

    func didEndScroll(gesture: UIPanGestureRecognizer) {
        let width = frame.width
        let offsetX = contentOffset.x
        let threshold = width * Constants.threshold

        if offsetX > CGFloat(currentIndex) * width + threshold {
            currentIndex += 1
        } else if offsetX < CGFloat(currentIndex) * width - threshold {
            currentIndex -= 1
        }

        UIView.animate(withDuration: Constants.animationDuration) { [weak self] in
            guard let self = self else { return }
            self.contentOffset.x = CGFloat(self.currentIndex) * width
        } completion: { [weak self] in
            if $0 {
                self?.removeNonVisibleSubviews()
            }
        }
    }

    @objc func handleScroll(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
            case .began:
                scrollDidBegan(gesture: gesture)
            case .changed:
                didScroll(gesture: gesture)
            case .ended:
                didEndScroll(gesture: gesture)
            default:
                return
        }
    }

}

private extension HorizontalPagedView {

    enum Constants {
        static let animationDuration: TimeInterval = 0.3
        static let threshold: CGFloat = 1/3
    }

}
