//
//  MainScreen.swift
//  Asanas
//
//  Created by Steve Pham on 2/12/21.
//
import Foundation
import SwiftUI
import ORSSerial
struct MainPage: View{
    @State var viewRouter: ViewRouter
    @State var output : String = ""

    var body: some View {
        VStack{
            Text("Main Page")
            Button("Connect to Mat",action:{
                let ports = ORSSerialPortManager.shared().availablePorts
                let serial = Serial_Comm()
                debugPrint(ports.debugDescription)
                serial.serialPort = ports.first
                let dataToSend = "Hello".data(using: .utf8)
                serial.serialPort?.send(dataToSend!)
                debugPrint("Portname: ","\(serial.serialPort?.name)")
            })
            }
        }
    }
struct Main_Previews: PreviewProvider {
    static var previews: some View {
        MainPage(viewRouter :ViewRouter())
    }
    
}
