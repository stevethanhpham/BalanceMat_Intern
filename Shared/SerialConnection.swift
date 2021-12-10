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
        self.serialPort = nil
    }
    func serialPort(_ serialPort: ORSSerialPort, didEncounterError error: Error) {
        print("Serial port \(serialPort) encountered an error: \(error)")
    }
    
    func serialPortWasOpened(_ serialPort: ORSSerialPort) {
        let descriptor = ORSSerialPacketDescriptor(prefixString: "!pos", suffixString: ";", maximumPacketLength: 8, userInfo: nil)
        serialPort.startListeningForPackets(matching: descriptor)
    }
    
    func serialPort(_ serialPort: ORSSerialPort, didReceive data: Data) {
        let string = String(data: data, encoding: .utf8)
        print("Got \(string) from the serial port!")
    }
    // MARK: - Properties
    
    @objc dynamic fileprivate(set) var sliderPosition: Int = 0
    
    @objc dynamic var serialPort: ORSSerialPort? {
        willSet {
            if let port = serialPort {
                port.close()
                port.delegate = nil
            }
        }
        didSet {
            if let port = serialPort {
                port.baudRate = 115200
                port.rts = true
                port.delegate = self
                port.open()
            }
        }
    }
}
