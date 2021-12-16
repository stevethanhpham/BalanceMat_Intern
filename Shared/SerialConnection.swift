//
//  SerialConnection.swift
//  Asanas (macOS)
//
//  Created by Steve Pham on 9/12/21.
//
// Retrieve from https://github.com/armadsen/ORSSerialPort/blob/master/Examples/PacketParsingDemo/Swift/Sources/SerialCommunicator.swift
import Foundation
import ORSSerial
class Serial_Comm: NSObject, ORSSerialPortDelegate{
    deinit {
        self.serialPort = nil
    }
    
    func serialPortWasRemovedFromSystem(_ serialPort: ORSSerialPort) {
        debugPrint("Portname: ","removed")
        self.serialPort = nil
    }
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port \(serialPort) encountered an error: \(error)")
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        let str = String(data: data, encoding: String.Encoding.utf32BigEndian)
        debugPrint(str)
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
