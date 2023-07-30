
//
//  Error.swift
//  Speed Shopping List
//
//  Created by mac on 13/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

enum NetworkError: Error {
    case network(String)
    case parser
    case encoding
}
