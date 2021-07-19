//
//  TopReachObserving.swift
//  Dyet
//
//  Created by Ilya Senchukov on 14.07.2021.
//

import UIKit
import RxSwift

public protocol TopReachObserving: UIViewController {

    var topReachState: BehaviorSubject<TopViewState> { get set }

}
