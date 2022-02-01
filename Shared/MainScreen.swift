//
//  MainScreen.swift
//  Asanas
//
//  Created by Steve Pham on 2/12/21.
//
import Foundation
import SwiftUI
import ORSSerial

class Measument: ObservableObject{
    @Published var measurement=[]
}
struct LineShape: Shape {
    @Binding var measurement:[Double]

    func path(in rect: CGRect) -> Path {

        var path = Path()
        if measurement.count>0{
                    let xIncrement = (rect.width / (CGFloat(measurement.count) - 1))
                    let factor = rect.height / CGFloat(measurement.max() ?? 1.0)
                    var path = Path()
                    path.move(to: CGPoint(x: 0.0,
                                          y: (rect.height - (measurement[0] * factor))))
                   for i in 1..<measurement.count {
                       let pt = CGPoint(x: (Double(i) * Double(xIncrement)),
                                        y: (rect.height - (measurement[i] * factor)))
                       path.addLine(to: pt)
                   }
                   return path
        }
        return path
    }
}
//struct LineGraph: View{
//    @Binding var measurement:[Int]
//}
struct MainPage: View{
    @State var viewRouter: ViewRouter
    @State var output : String = ""
    let serialPortManager = ORSSerialPortManager.shared()
    @ObservedObject var serial:Serial_Comm
    var body: some View {
        VStack{
            Text("Main Page")
            ZStack {
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 3.0)
                                .frame(width: 300, height: 300, alignment: .center)
            LineShape(measurement : $serial.mesurement)
                                .stroke(Color.red, lineWidth: 2.0)
                .frame(width: 300, height: 300, alignment: .center)}
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
                        for _ in 0...10{
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
        MainPage(viewRouter :ViewRouter(), serial: Serial_Comm())
    }
    
}
