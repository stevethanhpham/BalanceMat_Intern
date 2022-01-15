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
    let serialPortManager = ORSSerialPortManager.shared()
    let serial = Serial_Comm()
    var body: some View {
        VStack{
            Text("Main Page")
            
            Button("Connect to Mat",action:{
                let ports = ORSSerialPortManager.shared().availablePorts
                debugPrint(ports.debugDescription)
                serial.serialPort = ports.first
                do
                {
                    if ((serial.serialPort?.isOpen) == nil){
                        serial.serialPort?.close()}

                    serial.serialPort?.baudRate = 57600;

                    do
                    {   debugPrint("Baudrate",serial.serialPort?.baudRate)
                        debugPrint("Open?",String(serial.serialPort?.isOpen ?? false))
                        for i in 0...10{
                            Serial_Comm().sendBroadcast(matport: serial)
                        }
                        //flagLoggerAppeared = true;
                    }
                    catch
                    {
                       
                    }
                }
                catch {
                }
            })
            }
        }
    }
struct Main_Previews: PreviewProvider {
    static var previews: some View {
        MainPage(viewRouter :ViewRouter())
    }
    
}
