//
//  BaseService.swift
//  Bars
//
//  Created by Mariano Latorre on 13/06/2017.
//  Copyright © 2017 Mariano Latorre. All rights reserved.
//

import Foundation

enum Result<T> {
    case success(response: T)
    case error(message: String)
}

class BaseService {
    var session = URLSession(configuration: URLSessionConfiguration.default)
}
