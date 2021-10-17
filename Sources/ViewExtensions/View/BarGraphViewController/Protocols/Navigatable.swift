//
//  Navigatable.swift
//  
//
//  Created by Ilya Senchukov on 17.10.2021.
//

public protocol Navigatable {
    func next() -> Self
    func previous() -> Self
}
