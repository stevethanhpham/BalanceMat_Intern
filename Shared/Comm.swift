//
//  Comm.swift
//  Asanas (macOS)
//
//  Created by Steve Pham on 14/12/21.
//

import Darwin
import SwiftUI
// Setup of Research mat. Use this when you want to connect to research mat. Need for adaption to research mat
public class Comms
{
    enum TState { case eLookStart
                  case eGetHeader
                  case eCollectData
                  case eVerifyData};
    var state : TState = .eLookStart;
    //-------------------------------------------------------------------------------
    public enum TMsgType:Int
    {
        case eptERROR = 0

        case eptINFO = 1

        case eptGETSTATUS = 2
        case eptSTATUS = 3

        case eptGETSETTINGS = 6
        case eptSETTINGS = 7

        case eptUPDATESETTINGS = 8
        case eptUPDATEACK = 9

        case eptSTORESETTINGS = 10
        case eptSTOREACK = 11

        case eptGETRAWDATA = 12
        case eptRAWDATA = 13

        case eptSETSYSTEMNAME = 14
        case eptSETSYSTEMNAMEACK = 15

        case eptGETSYSTEMNAME = 16
        case eptSYSTEMNAME = 17

        case eptGETSERIALNUMBER = 18
        case eptSERIALNUMBER = 19

        // -----------------
        case eptSTREAMRAW = 40
        case eptSTREAMBIAS = 41
        

        case eptRAWARRAY = 43
        case eptBIASARRAY = 45

        case eptSTREAMACK = 48
        case eptSTREAMSTOP = 49
        // -----------------

        case eptSETMATSETTINGS = 68
        case eptSETMATSETTINGSACK = 69

        case eptGETMATSETTINGS = 70
        case eptMATSETTINGS = 71

        case eptFORCEMATTEST = 74
        case eptFORCEMATTESTACK = 75

        case eptSOFTRESET = 99

        case eptBROADCAST = 200
        case eptBROADCASTACK = 201

        case eptASSIGNID = 202
        case eptASSIGNIDACK = 203
        case eptASSIGNIDNACK = 204

        case eptGETFWDETAILS = 210
        case eptFWDETAILS = 211

        case eptENTERBOOTLOADER = 254
        case eptENTERBOOTLOADERACK = 255
    }
    //-------------------------------------------------------------------------------
    public enum DeviceType:Int
    {
        case PC = 0
        case CONTROLLER = 1
    }
    //-------------------------------------------------------------------------------
    public struct tMsg
    { init(){
        self.ID = 0
        self.data = []
        self.dataLen = 0
        self.chkSum = 0
        self.msgType = 0
    }
        var ID:UInt8
        var msgType:UInt8;
        var dataLen:UInt8;
        var chkSum:UInt8;
        var data:[UInt8];
    };
    //-------------------------------------------------------------------------------
    init(){
        self.header=[]
        self.data=[]
        self.data_len=0
        self.head_len=0
        self.msgRx = tMsg.init()
        self.state = .eLookStart
    }
    //-------------------------------------------------------------------------------
    var header:[UInt8]=[]
    var data:[UInt8]=[]
    var data_len:Int = 0
    var head_len:Int = 0
    var msgRx:tMsg;
    //-------------------------------------------------------------------------------
    public static func CalcChkSum(d:[UInt8], start:UInt8, len:UInt8)->UInt8
    {
        var chksum:UInt8 = 0x00
        for i in start...start+len
        {
            chksum ^= (UInt8)((chksum << 1) | d[Int(i)]);
        }
        return chksum;
    }
    //-------------------------------------------------------------------------------
    public func processMsg()
    {/*
        switch (TMsgType(rawValue: Int(msgRx.msgType)))
        {
            case .eptERROR:      ERRORMsg(msgRx);       break;
            case .eptSTATUS:       STATUSMsg(msgRx);      break;
            case .eptSETTINGS:     SETTINGSMsg(msgRx);    break;
            case .eptRAWDATA:    RAWVALUESMsg(msgRx);   break;
            case .eptUPDATEACK:    UPDATEAck(msgRx);      break;
            
            case .eptBROADCASTACK: BROADCASTAck(msgRx);   break;

            case .eptRAWARRAY: RAWARRAYMsg(msgRx); break;
            case .eptBIASARRAY: BIASARRAYMsg(msgRx); break;
            case .eptSTREAMACK: STREAMAck(msgRx); break;

            case .eptASSIGNIDACK: ASSIGNIDAck(msgRx); break;
            case .eptASSIGNIDNACK: ASSIGNIDNack(msgRx); break;

            case .eptSERIALNUMBER: SERIALNUMBERMsg(msgRx); break;
            case .eptFWDETAILS: FIRMWAREDETAILSMsg(msgRx); break;
        }*/
    }
    //-------------------------------------------------------------------------------
    public func CommsReset()
    {
        state = TState.eLookStart;
        data_len = 0;
        head_len = 0;
    }
    //-------------------------------------------------------------------------------
    public func MSGError()
    {
        debugPrint("ERROR")
    }
    //-------------------------------------------------------------------------------
    public func lookForMsg(c:UInt8)
    {
        if (state == TState.eLookStart)
        {
            if (c == Character("$").asciiValue)
            {
                state = TState.eGetHeader;
                head_len = 0;
            }
        }
        else if (state == TState.eGetHeader)
        {
            if (head_len < 4)
            {
                // get header bytes
                header[head_len] = c;
                head_len+=1;
                if (head_len == 4)
                {
                    // extract msg details from header
                    msgRx.ID = header[0];
                    msgRx.msgType = header[1];
                    msgRx.dataLen = header[2];
                    msgRx.chkSum = header[3];
                    if (msgRx.chkSum == Comms.CalcChkSum(d:header,start:0, len:3))
                    {
                        if (msgRx.dataLen <= 0)
                        {
                            // no data to follow
                            processMsg();
                            CommsReset();
                        }
                        else
                        {
                            // data to follow
                            state = TState.eCollectData;
                            msgRx.data = [];
                            data_len = 0;
                        }
                    }
                    else
                    {
                        // header checksum is bad - reset comms
                        MSGError();
                        CommsReset();
                    }
                }
            }
            else
            {
                //something gone bad - reset
                MSGError();
                CommsReset();
            }
        }
        else if (state == TState.eCollectData)
        {
            if (data_len < msgRx.dataLen)
            {
                //stick each char in buffer for later processing
                msgRx.data[data_len] = c;
                data_len+=1;
                if (data_len == msgRx.dataLen)
                {
                    //got all the data
                    state = TState.eVerifyData;
                }
            }
            else
            {
                //something gone bad - reset
                MSGError();
                CommsReset();
            }
        }
        else if (state == TState.eVerifyData)
        {
            if (c == Comms.CalcChkSum(d:msgRx.data, start:0, len:msgRx.dataLen))
            {
                // data checksum is ok - process msg
                processMsg();
                CommsReset();
            }
            else
            {
                // data corrupted - reset
                MSGError();
                CommsReset();
            }
        }
    }
    //-------------------------------------------------------------------------------
}
