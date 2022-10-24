//
//  ContentView.swift
//  DS100ify
//
//  Created by Karl Beecken on 24.10.22.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    @State private var searchText = ""
    @State var showAbout: Bool = false
    
    @ObservedObject var data: DS100Data
    
    var filteredData: [IntEntry] {
        if searchText.isEmpty {
            return data.intData
        } else {
            return data.intData.filter { !($0.RL100Langname.replacingOccurrences(of: "-", with: " ").fuzzyMatch(searchText)!.isEmpty) }.sorted { $0.RL100Code < $1.RL100Code }
        }
    }

    var body: some View {
        
        NavigationView {
            
            if (data.intData.isEmpty) {
                ProgressView().onAppear(perform: loadData)
            } else {
                List(filteredData) { item in
                    HStack {
                        VStack(alignment: .leading) {
                            HStack {
                                Text(item.RL100Code).bold()
                                Text(item.RL100Langname)
                            }
                            
                        }
                    }
                    
                }
                .refreshable {
                    print("refresh")
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
                .navigationTitle("Betriebsstellen")
                .toolbar {
                    ToolbarItem(placement: .primaryAction) {
                        Button(action: {
                            showAbout = true
                        }, label: {
                            Label("About", systemImage: "info.circle")
                        })
                    }
                }
                .sheet(isPresented: $showAbout) {
                    NavigationView {
                        VStack(alignment: .leading) {
                            Text("Data by [Deutsche Bahn AG](https://data.deutschebahn.com/dataset/data-betriebsstellen.html), CC BY 4.0").multilineTextAlignment(.leading)
                            Spacer()
                            Text("© \(String(Calendar.current.component(.year, from: Date()))) Karl Beecken. Source code available under the [MIT license](https://github.com/karlbeecken/DS100ify/blob/main/LICENSE).").italic().multilineTextAlignment(.center)
                        }
                        .padding()
                        .navigationTitle("About")
                        .toolbar {
                            ToolbarItem(placement: .primaryAction) {
                                Button(action: {
                                    showAbout = false
                                }, label: {
                                    Text("Done")
                                })
                            }
                        }
                    }
                }

            }
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func loadData() {
        data.load()
        data.loadInt()
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(data: DS100Data()).environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
