//
//  Result.swift
//  Speed Shopping List
//
//  Created by mac on 13/04/18.
//  Copyright © 2018 mac. All rights reserved.
//



enum Result<T, E: Error> {
    case success(T)
    case failure(E)
}
