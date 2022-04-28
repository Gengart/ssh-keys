//
//  ssh_manager_status_barApp.swift
//  ssh-manager-status-bar
//
//  Created by Angel Rada on 28/4/22.
//

import SwiftUI

@main
struct ssh_manager_status_barApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
