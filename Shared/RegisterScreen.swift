//
//  Register Screen.swift
//  Asanas App
//
//  Created by Steve Pham on 25/11/21.
//
import SwiftUI
import Foundation


struct RegisterPage: View{
    
    //declare function
    func isValidEmail (email: String)->Bool {
        var returnValue = true
        let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
        do {
            let regex = try NSRegularExpression(pattern: emailRegEx)
            let nsString = email as NSString
            let results = regex.matches(in: email, range: NSRange(location: 0, length: nsString.length))
            if results.count == 0{
                returnValue = false
            }
        }
        catch let error as NSError{
            returnValue = false
        }
        return returnValue
    }

    //declare function end
    
    //declare variable
    @Environment (\.managedObjectContext) var user_edit
    @State var usernamereg: String = ""
    @State var firstnamereg: String = ""
    @State var lastnamereg: String = ""
    @State var emailreg: String = ""
    @State private var emailvalid = false
    @State private var passwordvalid = false
    let dateFormatter: DateFormatter = {let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    @State var passwordreg: String = ""
    @State var confirmpasswordreg: String = ""
    @State private var birthDate = Date()
    @State var genderreg: String = "Male"
    
    var gender_list = ["Male","Female","Other"]
    @State var viewRouter: ViewRouter
    //declare variable end
    
    var body: some View {
    //Register Page
        ScrollView{
        VStack{
            Group{
        Text("Firstname");
        TextField("Firstname", text:$firstnamereg)
        Text("Lastname");
        TextField("Lastname", text:$lastnamereg)
        Text("Email");
            TextField("Email", text:$emailreg)
        Text("Username");
            TextField("Username", text:$usernamereg)}
        Text("Password");
        TextField("Password", text:$passwordreg)
        Text("ConfirmPassword");
        TextField("ConfirmPassword", text:$confirmpasswordreg)
            
        Text("DOB");
            DatePicker(selection: $birthDate, in: ...Date(), displayedComponents: .date){Text("Select a date")}
        Text("Gender");
            Picker("", selection: $genderreg){ForEach(gender_list, id: \.self){Text($0)}}
        HStack{
                Button("Confirm",action:{
                    //validate email
                    emailvalid = isValidEmail(email: emailreg)
                    passwordvalid = (passwordreg == confirmpasswordreg)
                    //validate password
                    if emailvalid && passwordvalid {
                        let newuser = User(context: user_edit)
                        newuser.dob = birthDate
                        newuser.email = emailreg
                        newuser.firstname =
                        firstnamereg
                        newuser.lastname = lastnamereg
                        newuser.username = usernamereg
                        newuser.password = passwordreg
                        newuser.gender = genderreg
                        try? user_edit.save()
                        viewRouter.currentPage = .loginpage}}
                )
                Button("Cancel",action:{viewRouter.currentPage = .loginpage})
            }
        }
        }
        }
    //child struct
    
    //Register Page end
}
struct Register_Previews: PreviewProvider {
    static var previews: some View {
        RegisterPage(viewRouter :ViewRouter())
    }
}
