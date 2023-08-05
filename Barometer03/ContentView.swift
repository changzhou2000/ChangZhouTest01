//
//  ContentView.swift
//  TestSafariExtension01
//
//  Created by Chang Zhou on 2023-07-15.
//

import SwiftUI
import CoreData


struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
        animation: .default)
    private var items: FetchedResults<Item>
    
//    let healthStore = HKHealthStore()
//    let number = HKMetadataKeyBarometricPressure
//    let lm = LocationDataManager()
    let cm = MyCoreMotionHelper()
    @State var baroData: Double = 0.0
    let diff: Double = 0.01

    func startTimer() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            updateTime()
        }
    }

    func updateTime() {
        if (cm.enabled) {
            let baroData2 = cm.getBaroData()  // kilopascals
            
//            print(String(format: "%.8f kilopascals (original %.8f) d1= %.8f diff= %.8f", baroData2, baroData, abs(baroData2 - baroData), diff))
            
            if abs(baroData2 - baroData) > diff {
                baroData = baroData2
                addItem()
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp!, formatter: itemFormatter) \(extractValue(item:item))")
                    } label: {
                        Text("\(item.timestamp!, formatter: itemFormatter) \(extractValue(item:item))")
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
#if os(iOS)
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
#endif
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
                
                ToolbarItem {
                    Button(action: export) {
                        Label("Export Items", systemImage: "square.and.arrow.up.fill")
                    }
//                    .confirmationDialog("Are you sure?", isPresented: true) {
//                        Button("Delete all items?", role: .destructive) {
//                            deleteAllItems()
//                        }
//                    }
                }
            }
            Text("Select an item")
        }.onAppear {
            startTimer()
        }
    }

    private func export() {
        var text: String = ""
        
        for item in items {
            text += "Item at \(itemFormatter.string(from: item.timestamp!)) \(extractValue(item:item))\n"
        }

        let res = share(items: [text])
        if (res) {
            deleteAllItems()
        }
    }

    @discardableResult
    func share(
        items: [Any],
        excludedActivityTypes: [UIActivity.ActivityType]? = nil
    ) -> Bool {
        guard let source = UIApplication.shared.windows.last?.rootViewController else {
            return false
        }
        let vc = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        vc.excludedActivityTypes = excludedActivityTypes
        vc.popoverPresentationController?.sourceView = source.view
        source.present(vc, animated: true)
        return true
    }
    
    private func extractValue(item: Item) -> String {
        var text:String
        
        if (item.barodata != nil) {
            text = " " + item.barodata!
        }
        else{
            text = "N/A"
        }
        return text
    }
    
    private func getBaroData() -> String {
        if (cm.enabled) {
            return cm.getBaroDataFormatted()
        }
        return "lm not enabled"
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
            newItem.barodata = getBaroData()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate.
                // You should not use this function in a shipping application, although it may be useful during development.
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
    
    private func deleteAllItems() {
        items.forEach(viewContext.delete)

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

private let itemFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.dateStyle = .short
//    formatter.timeStyle = .medium
    
    let formatter2 = DateFormatter()
    formatter2.locale = Locale(identifier: "en_US_POSIX")
    formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    formatter2.timeZone = TimeZone.init(abbreviation: "UTC")
    
    return formatter2
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
