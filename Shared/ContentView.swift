//
//  ContentView.swift
//  Shared
//
//  Created by Steve Pham on 25/11/21.
//

import SwiftUI


//Page Declare
enum Page{
    case loginpage
    case registerpage
    case mainpage
    case selectionpage
}
//Page Declare end

//Defined class end
//declare list of view and information passing
struct ContentView: View {
    @StateObject var viewRouter: ViewRouter
    @StateObject var serial: Serial_Comm

    var body: some View{
        switch viewRouter.currentPage {
        case .loginpage:
            LoginPage(viewRouter: viewRouter )
        case .registerpage:
            RegisterPage(viewRouter: viewRouter)
        case .selectionpage:
            SelectionPage(viewRouter: viewRouter)
        case .mainpage:
            MainPage(viewRouter: viewRouter, serial: serial)
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
        Image("asenesa_logo")
            .resizable()
            .scaledToFit()
        //field for username
        Text("Username");
        TextField("Username", text:$username)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
        //field for password
        Text("Password");
        TextField("Password", text:$password)
            .padding()
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()
        HStack{
            //Sign in button
            Button("Sign in",action:{
                self.failedLogin = true
                for user in users {
                    debugPrint("name",user.username)
                    debugPrint("password",user.password)
                    if(user.username==username&&password==user.password)
                    {//Success login
                        self.failedLogin = false
                        viewRouter.user_first_name=user.firstname ?? "Default First Name"
                        viewRouter.user_last_name=user.lastname ?? "Default Last Name"
                        viewRouter.user_dob=user.dob ?? Date.init()
                        break
                    }
                    else{//Fail login
                        self.failedLogin = true
                    }}
                    self.showAlert = true
                //error message
            }).alert(isPresented: $showAlert) {if self.failedLogin {return Alert(title: Text("Failed to login"), message: Text("Username or password is invalid"), dismissButton: .default(Text("OK")))}
                else {
                    viewRouter.currentPage = .selectionpage
                    return Alert(title: Text("Successful login"), message: Text("Login"), dismissButton: .default(Text("OK")))
                }

        }//go to register
            Button("Register",action:{
                self.showAlert = false
                viewRouter.currentPage = .registerpage
            })
        }//go to selection
        Button("Skip",action:{                   self.showAlert = false
            viewRouter.currentPage  = .selectionpage
        })
    }.frame(width: 960, height: 480, alignment: .center)
    .background(Color.white)
            .foregroundColor(.black)
        }
    //Login Page end
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewRouter: ViewRouter(), serial: Serial_Comm())
    }
}



