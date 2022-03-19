//
//  MainScreen.swift
//  Asanas
//
//  Created by Steve Pham on 2/12/21.
//
import Foundation
import SwiftUI
import ORSSerial
// Main screen for the app
// Class to observe measurement from serial connection
class Measument: ObservableObject{
    @Published var measurement=[]
}
// Struct to draw graph visualize the data gotten from the mat
// Retrive from https://swdevnotes.com/swift/2021/create-a-line-chart-in-swiftui/
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
// WIP to make better graph
//struct LineGraph: View{
//    @Binding var measurement:[Int]
//}
struct MainPage: View{
    //export csv function for main page after test
    func exportCSV(from user_info: Dictionary<String, AnyObject>){
        // all parameter to output
        var csv_data = "\("First Name"),\("Last Name"),\("DOB"),\("Stand"),\("Measurement")\n"
        //all information get from the user info
        csv_data=csv_data.appending("\(String(describing: user_info["First_Name"]!)),\(String(describing: user_info["Last_Name"]!)),\(String(describing: user_info["Dob"]!)),\(String(describing: user_info["Stand"]!)),\(String(describing: user_info["Measurement"]!))")
        //opent file to write
        let fileManager = FileManager.default
        do {
            let path = try fileManager.url(for: .documentDirectory, in: .allDomainsMask, appropriateFor: nil, create: false)
            let fileURL = path.appendingPathComponent("CSV_Output.csv")
            try csv_data.write(to: fileURL, atomically: true, encoding: .utf8)
        } catch {
            print("error creating file")
        }
    }
    //Timer to do stand session
    func startTimer(){
        //create timer
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true){ tempTimer in
            //testing is in process
            if (self.Testing){
                self.TimeRemaing -= 1
            }
            //count down to 0. stop testing and output file
            if (self.TimeRemaing==0){
                var user_info = Dictionary<String, AnyObject>()
                user_info.updateValue(viewRouter.user_first_name as AnyObject, forKey: "First_Name")
                user_info.updateValue(viewRouter.user_last_name as AnyObject, forKey: "Last_Name")
                user_info.updateValue(viewRouter.user_dob as AnyObject, forKey: "Dob")
                user_info.updateValue(viewRouter.stand_selection as AnyObject, forKey: "Stand")
                user_info.updateValue(serial.mesurement as AnyObject, forKey: "Measurement")
                exportCSV(from: user_info)
                self.Testing=false
                self.serial.addData=false
                self.TimeRemaing -= 1
            }
            }
    }
    // viewRouter to handle switching page
    @State var viewRouter: ViewRouter
    @State var output : String = ""
    // user start testing or not
    @State var Testing: Bool = false
    // default time
    @State var TimeRemaing: Int = 30
    // timer
    @State var timer: Timer? = nil
    // List of time that user can select
    var time_select: [Int] = [30,60,90]
    // Manager from serialPort library
    let serialPortManager = ORSSerialPortManager.shared()
    @ObservedObject var serial:Serial_Comm
    var record:[Double] = []
    var body: some View {
        VStack{
            Text("Asenesa")
            //background for the graph
            ZStack {
                            Rectangle()
                                .stroke(Color.gray, lineWidth: 3.0)
                                .frame(width: 960, height: 400, alignment: .center)
            LineShape(measurement : $serial.mesurement)
                                .stroke(Color.red, lineWidth: 2.0)
                .frame(width: 960, height: 350, alignment: .top)}
            //picker to select timer
            Picker("Time Select", selection: $TimeRemaing){ForEach(time_select, id: \.self){Text(String($0))}}
            .colorInvert()
            .colorMultiply(Color.cyan)
            HStack{
            Button("Connect to Mat",action:{
                //set up the connection and send broad cast message
                let ports = ORSSerialPortManager.shared().availablePorts
                debugPrint(ports.debugDescription)
                serial.serialPort = ports.first
                do
                {   //if serialPort is nil close the serial port
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
            })//start testing
            Button("Start Test",action:{
                serial.addData=true
                self.Testing = true
                serial.mesurement=[]
                serial.addData=true
                self.startTimer()
            })//print TimeRemaining
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
