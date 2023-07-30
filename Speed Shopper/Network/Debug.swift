//
//  Debug.swift
//  Speed Shopping List
//
//  Created by mac on 13/04/18.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation

extension Sequence where Iterator.Element == (key: String, value: Any)  {
    var apiDebug: String {
        var string = "";
        for (_, value) in self.enumerated() {
            string += "\(value.0)=\(value.1)&"
        }
        return string
    }
}
extension Server: CustomDebugStringConvertible{
    var debugDescription: String {
        return "ServerEnviroment: \((self.isProduction) ? ("Production") : ("SandBox") )\nDomain: \(self.domain)\nHost: \(self.hostName)\npath: \(self.path)\nFileDirectory: \(self.fileDirectory)"
    }
}
