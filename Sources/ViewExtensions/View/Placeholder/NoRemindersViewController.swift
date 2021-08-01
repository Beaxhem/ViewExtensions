//
//  NoRemindersViewController.swift
//  NoRemindersViewController
//
//  Created by Ilya Senchukov on 01.08.2021.
//

import UIKit
import RxDataSources
import RxCocoa
import RxSwift

public class NoRemindersViewController: UIViewController, ViewModelContainer {

    public static func create(size: CGSize) -> NoRemindersViewController {
        let vc = NoRemindersViewController()
        vc.view.frame.size = size
        return vc
    }

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var goToButton: UIButton!

    public var viewModel: NoRemindersViewModel? {
        didSet {
            update()
        }
    }

    private let goToButtonTappedRelay = PublishRelay<Void>()
    private var disposeBag: DisposeBag?

    public var goToButtonTapObservable: Observable<Void> {
        goToButtonTappedRelay.asObservable()
    }

    init() {
        super.init(nibName: Self.reuseIdentifier, bundle: .module)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        goToButton.contentEdgeInsets = .init(top: 15, left: 15, bottom: 15, right: 15)

        setupBindings()
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        goToButton.layer.cornerRadius = 15
    }
}

private extension NoRemindersViewController {

    func update() {
        guard let viewModel = viewModel else { return }

        messageLabel.text = viewModel.message
        goToButton.setTitle(viewModel.buttonText, for: .normal)

    }

    func setupBindings() {

        disposeBag = DisposeBag {

            goToButton.rx.tap
                .bind(to: goToButtonTappedRelay)

        }

    }

}
