//
//  BarDataProvider.swift
//  
//
//  Created by Ilya Senchukov on 17.10.2021.
//

public protocol BarDataProvider: AnyObject {

    associatedtype Key

    func startKey() -> Key
    func title(for key: Key) -> String
    func data(for key: Key) -> [BarData]

}
