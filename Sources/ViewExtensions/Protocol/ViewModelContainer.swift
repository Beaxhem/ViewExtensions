//
//  ViewModelContainer.swift
//  ViewModelContainer
//
//  Created by Ilya Senchukov on 21.07.2021.
//

import UIKit

@MainActor
public protocol ViewModelContainer {

    associatedtype VM: ViewModel
    var viewModel: VM? { get set }

}
