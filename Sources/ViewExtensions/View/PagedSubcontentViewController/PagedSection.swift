//
//  PagedSection.swift
//  PagedSection
//
//  Created by Ilya Senchukov on 10.08.2021.
//

import UIKit
import RxDataSources

extension UIViewController: IdentifiableType {

    public var identity: Int {
        hashValue
    }

}

struct PagedSection: AnimatableSectionModelType, Hashable {

    var items: [UIViewController]

    init(original: PagedSection, items: [UIViewController]) {
        self = original
        self.items = items
    }

    init(items: [UIViewController]) {
        self.items = items
    }

}

extension PagedSection: IdentifiableType {

    var identity: Int {
        hashValue
    }

}
