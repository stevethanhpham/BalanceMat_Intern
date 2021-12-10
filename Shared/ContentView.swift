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
    case mainpage
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
        case .mainpage:
            MainPage(viewRouter: viewRouter)
        }
    }
}
struct LoginPage: View{
    @State var viewRouter: ViewRouter
    @State var username: String = ""
    @State var password: String = ""
    @State private var failedLogin = false
    @State private var showAlert = false
    @FetchRequest (sortDescriptors:[]) var users: FetchedResults<User>
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
            Button("Sign in",action:{
                self.failedLogin = false
                for user in users {
                    debugPrint("Name",user.username)
                    debugPrint("Password",user.password)
                    if(user.username==username&&password==user.password)
                    {//Sucess login
                        self.failedLogin = false
                        break
                    }
                    else{//Fail login
                        self.failedLogin = true
                    }}
                    self.showAlert = true
            }).alert(isPresented: $showAlert) {if self.failedLogin {return Alert(title: Text("Failed to login"), message: Text("Username or password is invalid"), dismissButton: .default(Text("OK")))}
                else {                viewRouter.currentPage = .mainpage
                    return Alert(title: Text("Successful login"), message: Text("Login"), dismissButton: .default(Text("OK")))
                }

        }
            Button("Register",action:{
                self.showAlert = false
                viewRouter.currentPage = .registerpage
            })
        }
        Button("Skip",action:{                   self.showAlert = false
            viewRouter.currentPage = .mainpage
        })
    }
        }
    //Login Page end
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewRouter: ViewRouter())
    }
}



