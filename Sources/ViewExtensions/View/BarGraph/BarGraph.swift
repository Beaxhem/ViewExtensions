//
//  BarGraph.swift
//  
//
//  Created by Ilya Senchukov on 10.10.2021.
//

import UIKit

public struct BarData<T> {
    var value: T
    var label: String
}

public class BarGraph<T>: UIView {

    @IBOutlet weak var stackView: UIStackView!

    private let data: [BarData<T>]

    public init(data: [BarData<T>]) {
        self.data = data
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

private extension BarGraph {

    func commonInit() {

    }

}
