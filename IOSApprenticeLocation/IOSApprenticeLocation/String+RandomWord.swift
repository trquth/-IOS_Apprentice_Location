//
//  String+RandomWord.swift
//  IOSApprenticeLocation
//
//  Created by Thien Tran on 4/15/20.
//  Copyright © 2020 Thien Tran. All rights reserved.
//

import Foundation

extension String { func addRandomWord() -> String {
    let words = ["rabbit", "banana", "boat"]
    let value = Int.random(in: 0 ..< words.count)
    let word = words[value]
    return self + word
    }
}
