//
//  MainScreen.swift
//  Asanas
//
//  Created by Steve Pham on 2/12/21.
//

import Foundation
import SwiftUI

struct MainPage: View{
    @State var viewRouter: ViewRouter
    var body: some View {
        VStack{
            Text("Main Page")
        }
    }
    
}
struct Main_Previews: PreviewProvider {
    static var previews: some View {
        MainPage(viewRouter :ViewRouter())
    }
    
}
