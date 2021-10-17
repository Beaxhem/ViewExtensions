//
//  BarGraph.swift
//  
//
//  Created by Ilya Senchukov on 10.10.2021.
//

import UIKit

public class BarGraphViewController<DataProvider: BarDataProvider>: UIViewController {

    public static func create(dataProvider: DataProvider, styleProvider: StyleProvider? = nil) -> BarGraphViewController {
        let vc = BarGraphViewController()
        vc.dataProvider = dataProvider
        vc.styleProvider = styleProvider
        return vc
    }

    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var barsContainerView: UIView!

    private weak var dataProvider: DataProvider? {
        didSet {
            key = dataProvider?.startKey()
        }
    }
    private var key: DataProvider.Key?

    private weak var styleProvider: StyleProvider?

    private lazy var pageViewController: UIPageViewController = {
        UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }()

    public init() {
        super.init(nibName: "BarGraphViewController", bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        styleView()
    }

    @IBAction func prevButtonTapped() {
        pushNewChart(direction: .reverse)
    }

    @IBAction func nextButtonTapped() {
        pushNewChart(direction: .forward)
    }

}

private extension BarGraphViewController {

    func setupView() {
        pageViewController.moveAndFit(to: self, viewPath: \.barsContainerView)
        displayChart(direction: .forward, animated: false)
        setButtonsVisibility()
    }

    func displayChart(direction: UIPageViewController.NavigationDirection, animated: Bool = true) {
        guard let key = key,
              let dataProvider = dataProvider else {
            return
        }

        titleLabel.text = dataProvider.title(for: key)

        let vc = BarsViewController.create(data: dataProvider.data(for: key), styleProvider: styleProvider)
        pageViewController.setViewControllers([vc],
                                              direction: direction,
                                              animated: animated)
    }

    func pushNewChart(direction: UIPageViewController.NavigationDirection, animated: Bool = true) {
        guard let key = key as? Navigatable else {
            return
        }

        switch direction {
            case .forward:
                self.key = key.next() as? DataProvider.Key
            case .reverse:
                self.key = key.previous() as? DataProvider.Key
            @unknown default:
                fatalError("Not implemented")
        }

        displayChart(direction: direction, animated: animated)
    }

    func setButtonsVisibility() {
        guard let _ = key as? Navigatable else {
            previousButton.isHidden = true
            nextButton.isHidden = true
            return
        }
    }

    func styleView() {
        guard let styleProvider = styleProvider else { return }

        styleProvider.styleTitleLabel(titleLabel)
        styleProvider.styleControlButton(previousButton)
        styleProvider.styleControlButton(nextButton)
    }

}
