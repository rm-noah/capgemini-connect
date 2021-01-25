//
//  CollectionExt.swift
//  Connect
//
//  Created by Noah Quinn on 19/12/2020.
//  Copyright © 2020 Noah Quinn. All rights reserved.
//

import Foundation

extension Collection where Element == Optional<Any> {

    func allNotNil() -> Bool {
        return !allNil()
    }
    
    func atleastOneNil() -> Bool {
        return self.first(where: { $0 == nil }) != nil
    }

    func atleastOneNotNil() -> Bool {
        return self.compactMap() { $0 }.count > 0
    }

    func allNil() -> Bool {
        return self.compactMap() { $0 }.count == 0
    }
}
