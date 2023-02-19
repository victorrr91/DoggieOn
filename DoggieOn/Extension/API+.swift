//
//  API+.swift
//  DoggieOn
//
//  Created by Victor Lee on 2023/02/10.
//

import Foundation

extension Bundle {
    var DOG_API_KEY: String {
        guard let file = self.path(forResource: "Info", ofType: "plist") else { return "" }

        guard let resource = NSDictionary(contentsOfFile: file) else { return "" }
        guard let key = resource["DOG_API_KEY"] as? String else {
            fatalError("API_KEY_ERROR")
        }
        return key
    }
}
