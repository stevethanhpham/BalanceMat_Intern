//
//  SelectionScreen.swift
//  Asanas (macOS)
//
//  Created by Steve Pham on 1/2/22.
//
import SwiftUI
import Foundation


struct standView: View{
    var name: String
    var isSelected: Bool
    var symbol: String
    var body: some View{
        Text(symbol).font(isSelected ? .system(size: 120) : .system(size: 45))
    }
}
struct SelectionPage: View{
    @State var standnameArray=["Headstand","Shoulderstand","Plough","Fish","Sitting Forward Bend","Cobra","Locust","Bow","Half Spinal Twist","Crow","Standing Forward Bend","Triangle"]
    @State var standsymbolArray=["1","2","3","4","5","6","7","8","9","10","11","12"]
    @State var selectedIndex=0
    @State var viewRouter: ViewRouter
    var body: some View{
        VStack{
        Image("asenesa_logo")
            .resizable()
            .scaledToFit()
        ScrollView(.horizontal){
            LazyHStack(spacing:60 ){
                ForEach(0..<standsymbolArray.count){item in
                    standView(name: self.standnameArray[item],isSelected: item==self.selectedIndex ? true:false, symbol: self.standsymbolArray[item]).onTapGesture {
                        debugPrint(standnameArray[item])
                        self.selectedIndex=item
                    }
                    
                }
            }
        }
        HStack{
        Button("Confirm",action:{
            viewRouter.currentPage = .mainpage})
        Button("Cancel",action:{
            viewRouter.currentPage = .loginpage})}
        }.background(Color.white)
            .foregroundColor(.black)
            .frame(width: 960, height: 480, alignment: .center)
    }
}
struct Selection_Previews: PreviewProvider {
    static var previews: some View {
        SelectionPage(viewRouter :ViewRouter())
    }
}
