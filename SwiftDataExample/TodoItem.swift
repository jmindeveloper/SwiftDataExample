//
//  TodoItem.swift
//  SwiftDataExample
//
//  Created by J_Min on 2023/06/06.
//

import Foundation
import SwiftData

@Model
class TodoItem {
    let id: UUID
    
    var title: String
    var isCompleted: Bool
    var createdAt: Date
    
    init(title: String, isCompleted: Bool, createdAt: Date) {
        self.id = UUID()
        self.title = title
        self.isCompleted = isCompleted
        self.createdAt = createdAt
    }
}

extension Date {
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.mm.dd"
        
        return formatter.string(from: self)
    }
}
