//
//  ViewRouter.swift
//  Asanas
//
//  Created by Steve Pham on 27/11/21.
//  Retrieve from blckbirds.com/post/how-to-navigate-between-views-in-swiftui-by-using-an-observableobject/

import SwiftUI

class ViewRouter: ObservableObject{
    @Published var currentPage: Page = .loginpage
}
