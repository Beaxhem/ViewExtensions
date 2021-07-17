//
//  TopReachObserving.swift
//  Dyet
//
//  Created by Ilya Senchukov on 14.07.2021.
//

import UIKit

public protocol TopReachObserving: UIViewController {

    var topReachState: TopViewState? { get set }

}
