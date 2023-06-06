//
//  SwiftDataExampleApp.swift
//  SwiftDataExample
//
//  Created by J_Min on 2023/06/06.
//

import SwiftUI

@main
struct SwiftDataExampleApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [TodoItem.self])
        }
    }
}
