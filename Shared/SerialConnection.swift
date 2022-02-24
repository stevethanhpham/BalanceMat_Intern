//
//  SerialConnection.swift
//  Asanas (macOS)
//
//  Created by Steve Pham on 9/12/21.
//
// Retrieve from https://github.com/armadsen/ORSSerialPort/blob/master/Examples/PacketParsingDemo/Swift/Sources/SerialCommunicator.swift
import Foundation
import ORSSerial
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

class Serial_Comm: NSObject, ObservableObject, ORSSerialPortDelegate{
    static var PKT_START:UInt8=0x24
    static var BROADCAST:UInt8=0xc8
    static var BROADCAST_ACK:UInt8=0xc9
    static var PKT_END:UInt8=0x30
    static var RAW_ARRAY:UInt8=0x2b
    static var SUB_RAW:UInt8=0x28
    //static var MAX_BUFF:UInt8=1024
    static var HEADER_LEN:UInt8=8
    static var SEN_STATUS_LEN: UInt8=6
    var bufIndex:UInt8=0
    var messageBuf:[UInt8] = []
    var addData: Bool = true
    @Published var mesurement:[Double]=[]
    deinit {
        self.serialPort = nil
    }
    public func CalcChkSum(d:[UInt8], len:UInt8, offset:UInt8)->UInt8
    {
        var chksum:UInt8 = 0x00
        for i in 0...len-1
        {
            chksum ^= (UInt8)((chksum << 1) | d[Int(i+1)]);
        }
        return (chksum & 0x00ff);
    }
    func clearMessage(){
        messageBuf.removeAll()
        bufIndex=0
    }
    public func sendBroadcast(matport:Serial_Comm){
        var buff:[UInt8]=[0x24,0x00,0x00,0x00,0x00,0x28,0x00,0x00,0x30]
        buff[7] = CalcChkSum(d:buff,len:6,offset:1)
        matport.serialPort?.send(Data(buff))
    }
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        debugPrint("Portname: ","removed")
        self.clearMessage()
        self.serialPort = nil
        self.mesurement=[]
    }
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port \(serialPort) encountered an error: \(error)")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        var list_hex_str:[String] = []
        let data_str = data.hexEncodedString()
        var index:Int=0
        var new_num=false
        var hex_str=""
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
        let list_dec=list_hex_str.flatMap { UInt8($0, radix: 16) }
        messageBuf.append(contentsOf: list_dec)
        bufIndex = bufIndex + UInt8(list_dec.count)
        let start_idx = messageBuf.firstIndex(of: 36)
        if(start_idx != nil && start_idx!+5<messageBuf.count){
            let info_idx = start_idx!+5
            let str_info = messageBuf[info_idx]
            //debugPrint("Info",str_info)
            if(str_info==201){
            
            }else if (str_info==43 && messageBuf.count>6){
                let payload:UInt8? = messageBuf[start_idx!+6]
                let packetSize:UInt8? = payload! + UInt8(Serial_Comm.HEADER_LEN)
                //debugPrint("mbuff",messageBuf.count)
                //debugPrint("bindex",bufIndex)
                if (bufIndex >= UInt8(start_idx!)+packetSize!+UInt8(2)){
                    //let chkSumShouldBe = CalcChkSum(d: messageBuf, len: UInt8(packetSize!-Serial_Comm.HEADER_LEN), offset: UInt8(start_idx!+Serial_Comm.HEADER_LEN))
                    //let chkSum = messageBuf[start_idx!+packetSize!]
                    //debugPrint("shouldbe",chkSumShouldBe)
                    //debugPrint("chk",chkSum)
                    //if(chkSumShouldBe==chkSum){
                    //    debugPrint("YESSS")
                    //}
                    var numSamples = messageBuf[start_idx!+Int(packetSize!)-2]
                    if (numSamples>27){
                        numSamples=27
                    }
                    var samIndx=0
                    var samples:[UInt8]=[]
                    for value in stride(from: UInt8(start_idx!)+Serial_Comm.HEADER_LEN+Serial_Comm.SEN_STATUS_LEN, to: UInt8(start_idx!)+Serial_Comm.HEADER_LEN+Serial_Comm.SEN_STATUS_LEN+(numSamples*2), by: 2){
                        let lw = 0x00FF & messageBuf[Int(value)]
                        let hw = 0x00FF & messageBuf[Int(value+1)]
                        let val = lw+(hw<<8)
                        samples.insert(val, at: samIndx)
                        samIndx+=1
                    }
                    if(samples.count>0){
                        var avg=0.0
                        for value in samples{
                            avg+=Double(value)
                        }
                        avg=avg/Double(samples.count)
                        if (self.addData){
                            self.mesurement.append(avg)}
                    //debugPrint(samples)
                    //debugPrint(mesurement)
                        
                    }
                    clearMessage()
                }
                
            }else{
                bufIndex=0;
            }
        }
    }
    // MARK: - Properties
    
    @objc dynamic fileprivate(set) var sliderPosition: Int = 0
    
    @objc dynamic var serialPort: ORSSerialPort? {
        willSet {
            if let port = serialPort {
                debugPrint("Portname: ","removed")
                port.close()
                port.delegate = nil
            }
        }
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
