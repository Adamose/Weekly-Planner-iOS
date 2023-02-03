import SwiftUI

//Entry point of program
@main
struct Weekly_PlannerApp: App {
    
    //Loadin dataManager for local storage access
    @StateObject private var dataManager = DataManager()
    
    var body: some Scene {
        WindowGroup {

            //Creating instance of ContentView view and adding dataManager as environment variable
            ContentView()
                .environment(\.managedObjectContext, dataManager.container.viewContext)
        }
    }
}