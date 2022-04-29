//
//  ssh_manager_status_barApp.swift
//  ssh-manager-status-bar
//
//  Created by Angel Rada on 28/4/22.
//

import Cocoa
import SwiftUI

class AppDelegate: NSObject, NSApplicationDelegate {

    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    @AppStorage("current_key") var currentKey = "id_rsa_personal"
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        if let window = NSApplication.shared.windows.first {
                    window.close()
                }
        
        // Create the SwiftUI view that provides the window contents.
        let contentView = ContentView(onSelection: { key in
            if let button = self.statusBarItem?.button {
                button.title = self.apply(name: key)
            }
        })

        // Create the popover
        let popover = NSPopover()
        popover.contentSize = NSSize(width: 400, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        // Create the status item
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.variableLength))
        
        if let button = self.statusBarItem.button {
            button.title = self.apply(name: currentKey)
            button.action = #selector(togglePopover(_:))
        }
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
    
    private func apply(name: String) -> String {
        return "􀢕 [\(name == "id_rsa" ? "General" : name.replacingOccurrences(of: "id_rsa_", with: "").capitalized)]"
    }
    
}


@main
struct ssh_manager_status_barApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            EmptyView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
