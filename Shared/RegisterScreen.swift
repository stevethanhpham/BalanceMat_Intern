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
    //Field variable
    @State var usernamereg: String = ""
    @State var firstnamereg: String = ""
    @State var lastnamereg: String = ""
    @State var emailreg: String = ""
    @State var passwordreg: String = ""
    @State var confirmpasswordreg: String = ""
    @State private var birthDate = Date()
    @State var genderreg: String = "Male"
    //Boolean for logic
    @State private var empty_field = false
    @State private var showAlert2 = false
    @State private var emailvalid = false
    @State private var passwordvalid = false
    @State private var uservalid = true
    //List and Format
    let dateFormatter: DateFormatter = {let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()

    @FetchRequest (sortDescriptors:[]) var users: FetchedResults<User>
    var gender_list = ["Male","Female","Other"]
    @State var viewRouter: ViewRouter
    //declare variable end
    
    var body: some View {
    //Register Page
        //Field start
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
            Group{
        Text("Password");
                SecureField("Password", text:$passwordreg)
        Text("ConfirmPassword");
                SecureField("Confirm Password", text:$confirmpasswordreg)
            
        Text("DOB");
                DatePicker(selection: $birthDate, in: ...Date(), displayedComponents: .date){Text("Select a date").foregroundColor(.black)}
                .colorInvert()
                .colorMultiply(Color.blue)
        Text("Gender");
                Picker("", selection: $genderreg){ForEach(gender_list, id: \.self){Text($0)}}
                .colorInvert()
                .colorMultiply(Color.blue)
            }
        //field end
        HStack{
                Button("Confirm",action:{
                    self.showAlert2 = true
                    if ((usernamereg.isEmpty || firstnamereg.isEmpty || lastnamereg.isEmpty) ||
                        (emailreg  .isEmpty  ||
                        passwordreg.isEmpty ||
                        confirmpasswordreg.isEmpty)
                    )
                    {empty_field = true}
                    else{empty_field = false}
                    //validate email
                    emailvalid = isValidEmail(email: emailreg)
                    //validate email end
                    //validate password
                    passwordvalid = (passwordreg == confirmpasswordreg)
                    //validate password end
                    //validate user
                    for user in users{
                        if (user.username==usernamereg){
                       uservalid = false
                            break
                        }
                    }
                    //validate user end
                    
                    if emailvalid && passwordvalid && uservalid && !empty_field{
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
          //return to login page              //viewRouter.currentPage = .loginpage
                        
                    }
                        
                    }
                       //validate password
                )
                Button("Cancel",action:{
                    self.showAlert2=false
                    viewRouter.currentPage = .loginpage})
        }.alert(isPresented: $showAlert2) {if self.emailvalid && self.uservalid && self.passwordvalid && !self.empty_field {return Alert(title: Text("Message"), message: Text("Create account successful"), dismissButton: .default(Text("OK")))}
            else {var mess = "";
                if (!emailvalid) {mess+="Invalid email \n"}
                if (!passwordvalid) {mess+="Unmatched password \n"}
                if (!uservalid) {mess+="User existed \n"}
                if(empty_field){mess+="Empty Field"}
                return Alert(title: Text("Message"), message: Text(mess), dismissButton: .default(Text("OK")))}
        }
        }
        }.frame(width: 960, height: 480)
        .background(Color.white)
            .foregroundColor(.black)
    }
    //Register Page end
}
struct Register_Previews: PreviewProvider {
    static var previews: some View {
        RegisterPage(viewRouter :ViewRouter())
    }
}
