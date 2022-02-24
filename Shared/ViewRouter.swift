//
//  ViewRouter.swift
//  Asanas
//
//  Created by Steve Pham on 27/11/21.
//  Retrieve from blckbirds.com/post/how-to-navigate-between-views-in-swiftui-by-using-an-observableobject/

import SwiftUI

class ViewRouter: ObservableObject{
    @Published var currentPage: Page = .loginpage
    @Published var user_first_name: String = "Default_First_Name"
    @Published var user_last_name: String = "Default_Last_Name"
    @Published var user_dob: Date = Date.init()
    @Published var stand_selection: String = "No_Stand"
}
