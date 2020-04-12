//
//  Functions.swift
//  IOSApprenticeLocation
//
//  Created by Thien Tran on 4/12/20.
//  Copyright © 2020 Thien Tran. All rights reserved.
//

import Foundation

func afterDelay(_ seconds: Double, run: @escaping () -> Void) { DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: run) }
