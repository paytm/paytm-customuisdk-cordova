//
//  CDVInitializer.swift
//  App
//
//  Created by Aakash Srivastava on 01/09/20.
//

import PaytmNativeSDK

extension AINativeInhouseParameterModel {
    
    convenience init(argument: [String: Any]) throws {
        
        guard let tansactionToken = argument["txnToken"] as? String else {
            throw AppError.error(message: "Transaction token is required")
        }
        guard !tansactionToken.isEmpty else {
            throw AppError.error(message: "Invalid transaction token")
        }
        guard let orderId = argument["orderId"] as? String else {
            throw AppError.error(message: "Order id is required")
        }
        guard !orderId.isEmpty else {
            throw AppError.error(message: "Invalid order id")
        }
        guard let shouldOpenNativePlusFlow = argument["shouldOpenNativePlusFlow"] as? Bool else {
            throw AppError.error(message: "Should open native plus flow is required")
        }
        guard let merchantId = argument["mid"] as? String else {
            throw AppError.error(message: "Merchant id is required")
        }
        guard !merchantId.isEmpty else {
            throw AppError.error(message: "Invalid merchant id")
        }
        guard let paymentFlowString = argument["paymentFlowType"] as? String else {
            throw AppError.error(message: "Native payment flow is required")
        }
        guard let nativePaymentFlow = AINativePaymentFlow(rawValue: paymentFlowString) else {
            throw AppError.error(message: "Invalid native payment flow")
        }
        guard let paymentModesString = argument["paymentModes"] as? Int else {
            throw AppError.error(message: "Native pay modes is required")
        }
        guard let paymentModes = AINativePaymentModes(rawValue: paymentModesString) else {
            throw AppError.error(message: "Invalid native pay modes")
        }
        if let redirectionUrl = argument["redirectionUrl"] as? String, !redirectionUrl.isEmpty {
            self.init(withTransactionToken: tansactionToken, orderId: orderId, shouldOpenNativePlusFlow: shouldOpenNativePlusFlow, mid: merchantId, flowType: nativePaymentFlow, paymentModes: paymentModes, redirectionUrl: redirectionUrl)
        } else {
            self.init(withTransactionToken: tansactionToken, orderId: orderId, shouldOpenNativePlusFlow: shouldOpenNativePlusFlow, mid: merchantId, flowType: nativePaymentFlow, paymentModes: paymentModes)
        }
    }
}

extension AINativeNBParameterModel {
    
    convenience init(argument: [String: Any]) throws {
        
        guard let tansactionToken = argument["txnToken"] as? String else {
            throw AppError.error(message: "Transaction token is required")
        }
        guard !tansactionToken.isEmpty else {
            throw AppError.error(message: "Invalid transaction token")
        }
        guard let orderId = argument["orderId"] as? String else {
            throw AppError.error(message: "Order id is required")
        }
        guard !orderId.isEmpty else {
            throw AppError.error(message: "Invalid order id")
        }
        guard let shouldOpenNativePlusFlow = argument["shouldOpenNativePlusFlow"] as? Bool else {
            throw AppError.error(message: "Should open native plus flow is required")
        }
        guard let merchantId = argument["mid"] as? String else {
            throw AppError.error(message: "Merchant id is required")
        }
        guard !merchantId.isEmpty else {
            throw AppError.error(message: "Invalid merchant id")
        }
        guard let paymentFlowString = argument["paymentFlowType"] as? String else {
            throw AppError.error(message: "Native payment flow is required")
        }
        guard let nativePaymentFlow = AINativePaymentFlow(rawValue: paymentFlowString) else {
            throw AppError.error(message: "Invalid native payment flow")
        }
        guard let paymentModesString = argument["paymentModes"] as? Int else {
            throw AppError.error(message: "Native pay modes is required")
        }
        guard let paymentModes = AINativePaymentModes(rawValue: paymentModesString) else {
            throw AppError.error(message: "Invalid native pay modes")
        }
        guard let channelCode = argument["channelCode"] as? String else {
            throw AppError.error(message: "Channel code is required")
        }
        guard !channelCode.isEmpty else {
            throw AppError.error(message: "Invalid channel code")
        }
        if let redirectionUrl = argument["redirectionUrl"] as? String, !redirectionUrl.isEmpty {
            self.init(withTransactionToken: tansactionToken, orderId: orderId, shouldOpenNativePlusFlow: shouldOpenNativePlusFlow, mid: merchantId, flowType: nativePaymentFlow, paymentModes: paymentModes, channelCode: channelCode, redirectionUrl: redirectionUrl)
        } else {
            self.init(withTransactionToken: tansactionToken, orderId: orderId, shouldOpenNativePlusFlow: shouldOpenNativePlusFlow, mid: merchantId, flowType: nativePaymentFlow, paymentModes: paymentModes, channelCode: channelCode)
        }
    }
}

extension AINativeNUPIarameterModel {
    
    convenience init(argument: [String: Any]) throws {
        
        guard let tansactionToken = argument["txnToken"] as? String else {
            throw AppError.error(message: "Transaction token is required")
        }
        guard !tansactionToken.isEmpty else {
            throw AppError.error(message: "Invalid transaction token")
        }
        guard let orderId = argument["orderId"] as? String else {
            throw AppError.error(message: "Order id is required")
        }
        guard !orderId.isEmpty else {
            throw AppError.error(message: "Invalid order id")
        }
        guard let shouldOpenNativePlusFlow = argument["shouldOpenNativePlusFlow"] as? Bool else {
            throw AppError.error(message: "Should open native plus flow is required")
        }
        guard let merchantId = argument["mid"] as? String else {
            throw AppError.error(message: "Merchant id is required")
        }
        guard !merchantId.isEmpty else {
            throw AppError.error(message: "Invalid merchant id")
        }
        guard let paymentFlowString = argument["paymentFlowType"] as? String else {
            throw AppError.error(message: "Native payment flow is required")
        }
        guard let nativePaymentFlow = AINativePaymentFlow(rawValue: paymentFlowString) else {
            throw AppError.error(message: "Invalid native payment flow")
        }
        guard let amount = argument["amount"] as? Int else {
            throw AppError.error(message: "Invalid amount")
        }
        guard let paymentModesString = argument["paymentModes"] as? Int else {
            throw AppError.error(message: "Native pay modes is required")
        }
        guard let paymentModes = AINativePaymentModes(rawValue: paymentModesString) else {
            throw AppError.error(message: "Invalid native pay modes")
        }
        guard let vpaAddress = argument["vpaAddress"] as? String else {
            throw AppError.error(message: "Vpa address is required")
        }
        guard !vpaAddress.isEmpty else {
            throw AppError.error(message: "Invalid vpa address")
        }
        guard let upiFlowString = argument["upiFlowType"] as? String else {
            throw AppError.error(message: "Upi flow is required")
        }
        guard let upiFlowType = AINativeUPIFlow(rawValue: upiFlowString) else {
            throw AppError.error(message: "Invalid upi flow")
        }
        let merchantInfo = argument["merchantInfo"] as? [String: Any]
        let bankDetail = argument["bankDetail"] as? [String: Any]
        
        if let redirectionUrl = argument["redirectionUrl"] as? String, !redirectionUrl.isEmpty {
            self.init(withTransactionToken: tansactionToken, orderId: orderId, shouldOpenNativePlusFlow: shouldOpenNativePlusFlow, mid: merchantId, flowType: nativePaymentFlow, amount: CGFloat(amount), paymentModes: paymentModes, vpaAddress: vpaAddress, upiFlowType: upiFlowType, merchantInfo: merchantInfo, bankDetail: bankDetail, redirectionUrl: redirectionUrl)
        } else {
            self.init(withTransactionToken: tansactionToken, orderId: orderId, shouldOpenNativePlusFlow: shouldOpenNativePlusFlow, mid: merchantId, flowType: nativePaymentFlow, amount: CGFloat(amount), paymentModes: paymentModes, vpaAddress: vpaAddress, upiFlowType: upiFlowType, merchantInfo: merchantInfo, bankDetail: bankDetail)
        }
    }
}

extension AINativeSavedCardParameterModel {
    
    convenience init(argument: [String: Any]) throws {
        
        guard let tansactionToken = argument["txnToken"] as? String else {
            throw AppError.error(message: "Transaction token is required")
        }
        guard !tansactionToken.isEmpty else {
            throw AppError.error(message: "Invalid transaction token")
        }
        guard let orderId = argument["orderId"] as? String else {
            throw AppError.error(message: "Order id is required")
        }
        guard !orderId.isEmpty else {
            throw AppError.error(message: "Invalid order id")
        }
        guard let shouldOpenNativePlusFlow = argument["shouldOpenNativePlusFlow"] as? Bool else {
            throw AppError.error(message: "Should open native plus flow is required")
        }
        guard let merchantId = argument["mid"] as? String else {
            throw AppError.error(message: "Merchant id is required")
        }
        guard !merchantId.isEmpty else {
            throw AppError.error(message: "Invalid merchant id")
        }
        guard let paymentFlowString = argument["paymentFlowType"] as? String else {
            throw AppError.error(message: "Native payment flow is required")
        }
        guard let nativePaymentFlow = AINativePaymentFlow(rawValue: paymentFlowString) else {
            throw AppError.error(message: "Invalid native payment flow")
        }
        guard let paymentModesString = argument["paymentModes"] as? Int else {
            throw AppError.error(message: "Native pay modes is required")
        }
        guard let paymentModes = AINativePaymentModes(rawValue: paymentModesString) else {
            throw AppError.error(message: "Invalid native pay modes")
        }
        guard let authModeString = argument["authMode"] as? Int else {
            throw AppError.error(message: "Auth mode is required")
        }
        guard let authMode = AuthMode(rawValue: authModeString) else {
            throw AppError.error(message: "Invalid auth mode")
        }
        let cardId = argument["cardId"] as? String
        let cardNumber = argument["cardNumber"] as? String
        let cvv = argument["cvv"] as? String
        let expiryDate = argument["expiryDate"] as? String
        
        guard let newCard = argument["newCard"] as? Bool else {
            throw AppError.error(message: "New card is required")
        }
        guard let saveInstrument = argument["saveInstrument"] as? String else {
            throw AppError.error(message: "Save instrument is required")
        }
        guard !saveInstrument.isEmpty else {
            throw AppError.error(message: "Invalid save instrument")
        }
        
        if let redirectionUrl = argument["redirectionUrl"] as? String, !redirectionUrl.isEmpty {
            
            if let tokenTypeString = argument["tokenType"] as? String,
                let tokenType = TokenType(rawValue: tokenTypeString) {
                
                self.init(withTransactionToken: tansactionToken, tokenType: tokenType, orderId: orderId, shouldOpenNativePlusFlow: shouldOpenNativePlusFlow, mid: merchantId, flowType: nativePaymentFlow, paymentModes: paymentModes, authMode: authMode, cardId: cardId, cardNumber: cardNumber, cvv: cvv, expiryDate: expiryDate, newCard: newCard, saveInstrument: saveInstrument, redirectionUrl: redirectionUrl)
                
            } else {
                self.init(withTransactionToken: tansactionToken, orderId: orderId, shouldOpenNativePlusFlow: shouldOpenNativePlusFlow, mid: merchantId, flowType: nativePaymentFlow, paymentModes: paymentModes, authMode: authMode, cardId: cardId, cardNumber: cardNumber, cvv: cvv, expiryDate: expiryDate, newCard: newCard, saveInstrument: saveInstrument, redirectionUrl: redirectionUrl)
            }
            
        } else {
            self.init(withTransactionToken: tansactionToken, orderId: orderId, shouldOpenNativePlusFlow: shouldOpenNativePlusFlow, mid: merchantId, flowType: nativePaymentFlow, paymentModes: paymentModes, authMode: authMode, cardId: cardId, cardNumber: cardNumber, cvv: cvv, expiryDate: expiryDate, newCard: newCard, saveInstrument: saveInstrument)
        }
    }
}

extension UpiCollectConfigurations {
    
    init(argument: [String: Any]) throws {
        
        guard let shouldAllowCustomPolling = argument["shouldAllowCustomPolling"] as? Bool else {
            throw AppError.error(message: "Should allow custom polling is required")
        }
        guard let isAutoPolling = argument["isAutoPolling"] as? Bool else {
            throw AppError.error(message: "Is auto polling is required")
        }
        self.init(shouldAllowCustomPolling: shouldAllowCustomPolling, isAutoPolling: isAutoPolling)
    }
}

enum AppError {
    case error(message: String)
}

extension AppError: LocalizedError {
    var errorDescription: String? {
        switch self {
            case .error(let message):
                return message
        }
    }
}
