//
//  ContentView.swift
//  Shared
//
//  Created by Steve Pham on 25/11/21.
//

import SwiftUI

//Button Handler
//Button Handler end
//Page Declare
enum Page{
    case loginpage
    case registerpage
    //case mainpage
}
//Page Declare end

//Defined class end
struct ContentView: View {
    @StateObject var viewRouter: ViewRouter
    var body: some View{
        switch viewRouter.currentPage {
        case .loginpage:
            LoginPage(viewRouter: viewRouter)
        case .registerpage:
            RegisterPage(viewRouter: viewRouter)
        }
    }
}
struct LoginPage: View{
    @State var viewRouter: ViewRouter
    @State var username: String = ""
    @State var password: String = ""
    var body: some View{
    //Login Page
    VStack{
        Text("Username");
        TextField("Username", text:$username).padding()
            .background()
        Text("Password");
        TextField("Password", text:$password).padding()
            .background()
            .cornerRadius(5.0)
            .padding(.bottom,20)
        HStack{
            Button("Sign in",action:{})
            Button("Register",action:{viewRouter.currentPage = .registerpage
            })
        }
        Button("Skip",action:{})
    }
        }
    //Login Page end
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewRouter: ViewRouter())
    }
}



