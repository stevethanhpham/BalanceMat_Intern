//
//  MainScreen.swift
//  Asanas
//
//  Created by Steve Pham on 2/12/21.
//
import Foundation
import SwiftUI
import ORSSerial
public func CalcChkSum(d:[UInt8], len:UInt8, offset:UInt8)->UInt8
{
    var chksum:UInt8 = 0x00
    for i in 0...len-1
    {
        chksum ^= (UInt8)((chksum << 1) | d[Int(i+1)]);
    }
    return (chksum & 0x00ff);
}
func sendBroadcast(matport:Serial_Comm){
    var buff:[UInt8]=[0x24,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x30]
    buff[7] = CalcChkSum(d:buff,len:6,offset:1)
    matport.serialPort?.send(Data(buff))
}
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
                            sendBroadcast(matport: serial)
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
