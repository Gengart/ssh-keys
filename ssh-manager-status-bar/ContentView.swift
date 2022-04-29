//
//  ContentView.swift
//  ssh-manager-status-bar
//
//  Created by Angel Rada on 28/4/22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    
    private let path = "/Users/radagv/.ssh"
    
    @AppStorage("current_key") var currentKey = "id_rsa_personal"
    @State var keys: [String] = []
    var onSelection: (String) -> Void
    
    @discardableResult
    func shell(_ command: String) -> String {
        let task = Process()
        let pipe = Pipe()
    
        task.standardOutput = pipe
        task.standardError = pipe
        task.arguments = ["-c", command]
        task.launchPath = "/bin/zsh"
        task.launch()
    
        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)!
    
        return output
    }
    
    init(onSelection handler: @escaping (String) -> Void) {
        onSelection = handler
        select(key: currentKey)
    }
    
    func load() {
        do {
            let manager = FileManager.default
            let files = try manager.contentsOfDirectory(atPath: path)
            let filtered = files.filter { $0.hasPrefix("id_rsa") && !$0.hasSuffix(".pub") }
        
            keys = filtered
//                .filter { $0 != "id_rsa" }
        } catch let error {
            print(error)
        }
    }
    
    func select(key: String) {
        shell("ssh-add -D")
        shell("ssh-add \(path.appending("/\(key)"))")
        
        currentKey = key
        onSelection(key)
    }
    
    func copy(key: String) {
        let p = path.appending("/\(key)").appending(".pub")
        
        shell("pbcopy < \(p)")
    }

    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                VStack(alignment: .center) {
                    Text("SSH KEYS")
                        .font(.title)
                }
                .frame(maxWidth: .infinity)
                ForEach(keys, id: \.self) { item in
                    HStack(spacing: 12) {
                        Button(action: { select(key: item) }) {
                            HStack {
                                Text(item == "id_rsa" ? "General" : item.replacingOccurrences(of: "id_rsa_", with: "").capitalized)
                                    .padding()
                                    .contentShape(Rectangle())
                                Spacer()
                            }
                            .foregroundColor(item == currentKey ? .white : .primary)
                            .background(item == currentKey ? Color.accentColor : Color("background"))
                        }
                        .buttonStyle(.plain)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        
                        Button(action: { copy(key: item) }) {
                            Image(systemName: "doc.on.clipboard")
                                .padding()
                                .background(Color("background"))
                        }
                        .buttonStyle(.plain)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }
            }
            .padding()
        }
        .frame(height: 400)
        .onAppear(perform: load)
    }
}
