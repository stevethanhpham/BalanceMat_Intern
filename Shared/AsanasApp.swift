//
//  AsanasApp.swift
//  Shared
//
//  Created by Steve Pham on 25/11/21.
//

import SwiftUI
import CoreData


class UserDataController: ObservableObject {
    let persistentContainer: NSPersistentContainer = {
        let user_container = NSPersistentContainer(name:"UserInfo")
        user_container.loadPersistentStores{_,error in
            if let error = error as NSError? {fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        return user_container
    }()
}
@main
struct AsanasApp: App {
    @StateObject var viewRouter = ViewRouter()
    @StateObject private var userdataController = UserDataController()
    @StateObject var serial = Serial_Comm()
    var body: some Scene {
        WindowGroup {
            ContentView(viewRouter: viewRouter, serial: serial)
                .environment(\.managedObjectContext, userdataController.persistentContainer.viewContext)
        }
    }
}
