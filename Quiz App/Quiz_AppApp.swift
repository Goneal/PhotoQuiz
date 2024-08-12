//
//  Quiz_AppApp.swift
//  Quiz App
//
//  Created by Geovani Oneal on 8/12/24.
//

import SwiftUI

@main
struct Quiz_AppApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
