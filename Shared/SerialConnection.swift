//
//  SerialConnection.swift
//  Asanas (macOS)
//
//  Created by Steve Pham on 9/12/21.
//
// Retrieve from https://github.com/armadsen/ORSSerialPort/blob/master/Examples/PacketParsingDemo/Swift/Sources/SerialCommunicator.swift
// Modified by Steve Pham
import Foundation
import ORSSerial
// extension to output signal to HEX String
extension Data {
    struct HexEncodingOptions: OptionSet {
        let rawValue: Int
        static let upperCase = HexEncodingOptions(rawValue: 1 << 0)
    }
    func hexEncodedString(options: HexEncodingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return self.map { String(format: format, $0) }.joined()
    }
}
// Main class to control serial connection
class Serial_Comm: NSObject, ObservableObject, ORSSerialPortDelegate{
    //Header to communicate with the mat
    static var PKT_START:UInt8=0x24
    static var BROADCAST:UInt8=0xc8
    static var BROADCAST_ACK:UInt8=0xc9
    static var PKT_END:UInt8=0x30
    static var RAW_ARRAY:UInt8=0x2b
    static var SUB_RAW:UInt8=0x28
    //static var MAX_BUFF:UInt8=1024
    static var HEADER_LEN:UInt8=8
    static var SEN_STATUS_LEN: UInt8=6
    //store buffer message
    var bufIndex:UInt8=0
    var messageBuf:[UInt8] = []
    //optional bool to add new data to measurement or not
    var addData: Bool = true
    //measurement data recored in array
    @Published var mesurement:[Double]=[]
    //set serialPort to nil
    deinit {
        self.serialPort = nil
    }
    //Method to check the message sent is complete using CalChkSum algorithm
    public func CalcChkSum(d:[UInt8], len:UInt8, offset:UInt8)->UInt8
    {
        var chksum:UInt8 = 0x00
        for i in 0...len-1
        {
            chksum ^= (UInt8)((chksum << 1) | d[Int(i+1)]);
        }
        return (chksum & 0x00ff);
    }
    //clear all message from message Buffer and reset Buffer index
    func clearMessage(){
        messageBuf.removeAll()
        bufIndex=0
    }
    //Send broadcast message to the mat (important, this message allows the sensor to send data back)
    public func sendBroadcast(matport:Serial_Comm){
        var buff:[UInt8]=[0x24,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x30]
        buff[7] = CalcChkSum(d:buff,len:6,offset:1)
        matport.serialPort?.send(Data(buff))
    }
    //Handler function to the event where serialPort physical removed
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        debugPrint("Portname: ","removed")
        self.clearMessage()
        self.serialPort = nil
        self.mesurement=[]
    }
    //Handler function for error. Printout error
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port \(serialPort) encountered an error: \(error)")
    }
    //Main function to handler data packet from the mat
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        //list to later convert the string to list
        var list_hex_str:[String] = []
        //convert data to hex string
        let data_str = data.hexEncodedString()
        // index for converting hex to list of hex
        var index:Int=0
        // bool for converting hex to list of hex
        var new_num=false
        // storage for hex number
        var hex_str=""
        // this for loop is to convert the string to list of hex number string
        for char in data_str
        {if (new_num){
            hex_str+=String(char)
            list_hex_str.insert(hex_str, at: index)
            index+=1
            hex_str=""
            new_num=false
        }else{
            hex_str+=String(char)
            new_num=true
        }
        }
        
        //debugPrint(list_hex_str)
        //map function to convert hex str to decimal
        let list_dec=list_hex_str.flatMap { UInt8($0, radix: 16) }
        //add all receive decimal to message buff
        messageBuf.append(contentsOf: list_dec)
        //put buff Index to the end of list
        bufIndex = bufIndex + UInt8(list_dec.count)
        //find start index in the messageBuf
        let start_idx = messageBuf.firstIndex(of: 36)
        //The message is long enough to extract data
        if(start_idx != nil && start_idx!+5<messageBuf.count){
            // extract the info index
            let info_idx = start_idx!+5
            // extract the info string from info_idx
            let str_info = messageBuf[info_idx]
            //debugPrint("Info",str_info)
            // if info string is 201 is error message and 43 is data message
            if(str_info==201){
            
            }else if (str_info==43 && messageBuf.count>6){
            //this part is confirmation the message is complete by compare the mess length with expectation
                let payload:UInt8? = messageBuf[start_idx!+6]
                //default maximum size of packet
                let packetSize:UInt8? = payload! + UInt8(Serial_Comm.HEADER_LEN)
                //debugPrint("mbuff",messageBuf.count)
                //debugPrint("bindex",bufIndex)
                //compart the earlier bufIndex which is the end message length with possible message length
                if (bufIndex >= UInt8(start_idx!)+packetSize!+UInt8(2)){
                    //let chkSumShouldBe = CalcChkSum(d: messageBuf, len: UInt8(packetSize!-Serial_Comm.HEADER_LEN), offset: UInt8(start_idx!+Serial_Comm.HEADER_LEN))
                    //let chkSum = messageBuf[start_idx!+packetSize!]
                    //debugPrint("shouldbe",chkSumShouldBe)
                    //debugPrint("chk",chkSum)
                    //if(chkSumShouldBe==chkSum){
                    //    debugPrint("YESSS")
                    //}
            //this part is extracting the sample from the message buffer
                    //check if number of samples>27
                    var numSamples = messageBuf[start_idx!+Int(packetSize!)-2]
                    if (numSamples>27){
                        numSamples=27
                    }
                    //index of sample
                    var samIndx=0
                    //list to store sample
                    var samples:[UInt8]=[]
                    //for loop to apply extracting method from sample
                    for value in stride(from: UInt8(start_idx!)+Serial_Comm.HEADER_LEN+Serial_Comm.SEN_STATUS_LEN, to: UInt8(start_idx!)+Serial_Comm.HEADER_LEN+Serial_Comm.SEN_STATUS_LEN+(numSamples*2), by: 2){
                        let lw = 0x00FF & messageBuf[Int(value)]
                        let hw = 0x00FF & messageBuf[Int(value+1)]
                        let val = lw+(hw<<8)
                        samples.insert(val, at: samIndx)
                        samIndx+=1
                    }
                    //message contains few samples
                    if(samples.count>0){
                        var avg=0.0
                        for value in samples{
                            avg+=Double(value)
                        }
                        //calculate the average
                        avg=avg/Double(samples.count)
                        //add avg to measurement
                        if (self.addData){
                            self.mesurement.append(avg)}
                    //debugPrint(samples)
                    //debugPrint(mesurement)
                        
                    }
                    //otherwise throw away the message
                    clearMessage()
                }
                
            }else{// if info is not error or data, reset the bufferIdx
                bufIndex=0;
            }
        }
    }
    // MARK: - Properties
    
    @objc dynamic fileprivate(set) var sliderPosition: Int = 0
    
    @objc dynamic var serialPort: ORSSerialPort? {
        //if the port disconnected
        willSet {
            if let port = serialPort {
                debugPrint("Portname: ","removed")
                port.close()
                port.delegate = nil
            }
        }
        //open the port
        didSet {
            if let port = serialPort {
                port.baudRate = 57600 
                debugPrint("Portname: ","open")
                port.delegate = self
                port.open()
            }
        }
    }

}
