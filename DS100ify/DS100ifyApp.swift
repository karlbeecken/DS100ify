//
//  DS100ifyApp.swift
//  DS100ify
//
//  Created by Karl Beecken on 24.10.22.
//

import SwiftUI

@main
struct DS100ifyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(data: DS100Data())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
