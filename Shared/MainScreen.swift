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
    func startTimer(){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            if (self.Testing){
                self.TimeRemaing -= 1
            }
            if (self.TimeRemaing==0){
                self.Testing=false
                self.serial.addData=false
            }
            }
    }
    @State var viewRouter: ViewRouter
    @State var output : String = ""
    @State var Testing: Bool = false
    @State var TimeRemaing: Int = 30
    @State var timer: Timer? = nil
    var time_select: [Int] = [30,60,90]
    let serialPortManager = ORSSerialPortManager.shared()
    @ObservedObject var serial:Serial_Comm
    var record:[Double] = []
    var body: some View {
        VStack{
            Text("Asenesa")
            ZStack {
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 3.0)
                                .frame(width: 960, height: 400, alignment: .center)
            LineShape(measurement : $serial.mesurement)
                                .stroke(Color.red, lineWidth: 2.0)
                .frame(width: 960, height: 350, alignment: .top)}
            Picker("Time Select", selection: $TimeRemaing){ForEach(time_select, id: \.self){Text(String($0))}}
            .colorInvert()
            .colorMultiply(Color.cyan)
            HStack{
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
            Button("Start Test",action:{
                serial.addData=true
                self.Testing = true
                serial.mesurement=[]
                serial.addData=true
                self.startTimer()
            })
             Text("\(TimeRemaing)")
            }
        }
        .background(Color.white)
        .frame(width: 960, height: 480, alignment: .center)
            .foregroundColor(.black)
    }
}

struct Main_Previews: PreviewProvider {
    static var previews: some View {
        MainPage(viewRouter :ViewRouter(), serial: Serial_Comm())
    }
    
}
