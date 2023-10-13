//
//  Item.swift
//  moonPhaseDiary2
//
//  Created by Masahiro Yamashita on 2023/10/12.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
