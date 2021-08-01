//
//  NoRemindersViewModel.swift
//  NoRemindersViewModel
//
//  Created by Ilya Senchukov on 01.08.2021.
//

import RxDataSources
import RxCocoa
import RxSwift

public struct NoRemindersViewModel: ViewModel {

    let message: String
    let buttonText: String

    public init(message: String, buttonText: String) {
        self.message = message
        self.buttonText = buttonText
    }

}
