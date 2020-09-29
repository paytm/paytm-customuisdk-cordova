import PaytmNativeSDK

@objc(CustomUISDK) public class CustomUISDK: CDVPlugin {
    
    private enum CardType: String {
        case creditCard = "CREDIT_CARD"
        case debitCard = "DEBIT_CARD"
        
        var paymentMode: AINativePaymentModes {
            switch self {
            case .creditCard:
                return .creditCard
            case .debitCard:
                return .debitCard
            }
        }
    }
    
    private enum AuthMode: String {
        case atm
        case otp
        
        var nativeAuthMode: PaytmNativeSDK.AuthMode {
            switch self {
            case .atm:
                return .atm
            case .otp:
                return .otp
            }
        }
    }
    
    private var callbackId = ""
    private var merchantId = ""
    private var orderId = ""
    private var txnToken = ""
    private var amount: Double = 0.0
    private var callbackUrl = ""
    
    private var aiHandler: PaytmNativeSDK.AIHandler!
    
    private var redirectionUrl: String {
        switch aiHandler.getEnvironent() {
        case .production:
            return "https://securegw.paytm.in/theia/paytmCallback"
        case .staging:
            return "https://securegw-stage.paytm.in/theia/paytmCallback"
        }
    }
        
    public override func pluginInitialize() {
        aiHandler = PaytmNativeSDK.AIHandler()
    }

    public override func handleOpenURL(_ notification: Notification!) {
        if let url = notification.object as? URL {
            handleURL(url)
        }
    }
}

public extension CustomUISDK {
    
    @objc(initPaytmSDK:)
    func initPaytmSDK(command: CDVInvokedUrlCommand) {
        
        guard let mid = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Merchant id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !mid.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid merchant id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let orderId = command.arguments[1] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Order id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !orderId.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid order id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let txnToken = command.arguments[2] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Transaction token is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !txnToken.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid transaction token")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let amountString = command.arguments[3] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Amount is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let amountDouble = Double(amountString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid amount")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let isStaging = command.arguments[4] as? Bool else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid environment")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        self.merchantId = mid
        self.orderId = orderId
        self.txnToken = txnToken
        self.amount = amountDouble
        
        let env: AIEnvironment = (isStaging ? .staging : .production)
        aiHandler.setEnvironment(env)
        
        if let callbackUrl = command.arguments[5] as? String {
            self.callbackUrl = callbackUrl
        }
        
        let pluginResult = CDVPluginResult(status: .ok)
        commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(isPaytmAppInstalled:)
    func isPaytmAppInstalled(command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: .ok, messageAs: aiHandler.isPaytmAppInstall)
        commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc(getEnvironment:)
    func getEnvironment(command: CDVInvokedUrlCommand) {
        
        switch aiHandler.getEnvironent() {
        case .production:
            let pluginResult = CDVPluginResult(status: .ok, messageAs: "production".uppercased())
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            
        case .staging:
            let pluginResult = CDVPluginResult(status: .ok, messageAs: "staging".uppercased())
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }

    @objc(setEnvironment:)
    func setEnvironment(command: CDVInvokedUrlCommand) {

        guard let environment = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Environment is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        switch environment.lowercased() {
        case "production":
            aiHandler.setEnvironment(.production)
            let pluginResult = CDVPluginResult(status: .ok)
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            
        case "staging":
            aiHandler.setEnvironment(.staging)
            let pluginResult = CDVPluginResult(status: .ok)
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            
        default:
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid environment")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
        }
    }
    
    @objc(checkHasInstrument:)
    func checkHasInstrument(command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: .error, messageAs: "Method not implemented")
        commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }

    @objc(fetchAuthCode:)
    func fetchAuthCode(command: CDVInvokedUrlCommand) {
        
        showConsentView { [weak self] in
            
            guard let weakSelf = self else {
                return
            }
            if AINativeConsentManager.shared.getConsentState() {
                
                guard let clientId = command.arguments[0] as? String else {
                    let pluginResult = CDVPluginResult(status: .error, messageAs: "Client id is required")
                    weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    return
                }
                
                guard !clientId.isEmpty else {
                    let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid client id")
                    weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    return
                }
                
                guard let mid = command.arguments[1] as? String else {
                    let pluginResult = CDVPluginResult(status: .error, messageAs: "Merchant id is required")
                    weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    return
                }
                
                guard !mid.isEmpty else {
                    let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid merchant id")
                    weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                    return
                }
                
                weakSelf.commandDelegate.run { [weak self] in
                    DispatchQueue.main.async { [weak self] in
                        
                        guard let weakSelf = self else {
                            return
                        }
                        weakSelf.callbackId = command.callbackId
                        
                        weakSelf.aiHandler.getAuthToken(clientId: clientId, mid: mid) { status in
                            switch status {
                                
                            case .error:
                                let pluginResult = CDVPluginResult(status: .error, messageAs: "ERROR")
                                weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                                
                            case .appNotInstall:
                                weakSelf.openRedirectionFlow()
                                fallthrough
                                
                            case .inProcess:
                                return
                            }
                        }
                    }
                }
                
            } else {
                let pluginResult = CDVPluginResult(status: .error, messageAs: "APP NOT INSTALLED")
                weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            }
        }
    }
    
    @objc(getInstrumentFromLocalVault:)
    func getInstrumentFromLocalVault(command: CDVInvokedUrlCommand) {
        
        guard let custId = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Customer id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !custId.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid customer id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let mid = command.arguments[1] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Merchant id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !mid.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid merchant id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let checksum = command.arguments[2] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Checksum is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !checksum.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid checksum")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        let ssoToken: String
        if let sToken = command.arguments[3] as? String {
            ssoToken = sToken
        } else {
            ssoToken = ""
        }
        
        callbackId = command.callbackId
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.getInstrumentFromLocalVault(custId: custId, mid: mid, ssoToken: ssoToken, checksum: checksum, delegate: weakSelf)
            }
        }
    }
    
    @objc(getConsentState:)
    func getConsentState(command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: .ok, messageAs: AINativeConsentManager.shared.getConsentState())
        commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc(isAuthCodeValid:)
    func isAuthCodeValidisAuthCodeValid(command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: .error, messageAs: "Method not implemented")
        commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc(applyOffer:)
    func applyOffer(command: CDVInvokedUrlCommand) {
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.applyOffer()
            }
        }
    }
    
    @objc(fetchAllOffers:)
    func fetchAllOffers(command: CDVInvokedUrlCommand) {
        
        guard let mid = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Merchant id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !mid.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid merchant id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        callbackId = command.callbackId
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.fetchAllOffers(mid: mid, delegate: weakSelf)
            }
        }
    }
}

// MARK: Wallet related methods
public extension CustomUISDK {
    
    @objc (goForWalletTransaction:)
    func goForWalletTransaction(command: CDVInvokedUrlCommand) {
        
        guard let paymentFlowString = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Payment flow is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let flowType = AINativePaymentFlow(rawValue: paymentFlowString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid payment flow")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        callbackId = command.callbackId
        let model = AINativeInhouseParameterModel(withTransactionToken: txnToken, orderId: orderId, shouldOpenNativePlusFlow: true, mid: merchantId, flowType: flowType, paymentModes: .wallet, redirectionUrl: redirectionUrl)
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.callProcessTransactionAPI(selectedPayModel: model, delegate: weakSelf)
            }
        }
    }
}

// MARK: Credit/Debit card related methods
public extension CustomUISDK {
    
    @objc(goForNewCardTransaction:)
    func goForNewCardTransaction(command: CDVInvokedUrlCommand) {
        
        guard let cardNumber = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Card number is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !cardNumber.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid card number")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard var cardExpiry = command.arguments[1] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Card expiry is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        let components = cardExpiry.split(separator: "/")
        
        if (components.count == 2), let expMonth = components.first, let yearMonth = components.last {
            cardExpiry = "\(expMonth)20\(yearMonth)"
        } else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid card expiry")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let cardCvv = command.arguments[2] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Card cvv is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !cardCvv.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid card cvv")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let cardTypeString = command.arguments[3] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Card type is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let cardType = CardType(rawValue: cardTypeString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid card type")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let paymentFlowString = command.arguments[4] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Payment flow is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let flowType = AINativePaymentFlow(rawValue: paymentFlowString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid payment flow")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let channelCode = command.arguments[5] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Channel code is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !channelCode.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid channel code")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let issuingBankCode = command.arguments[6] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Issuing bank code is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !issuingBankCode.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid issuing bank code")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        /*
        guard let emiChannelId = command.arguments[7] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Emi channel id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !emiChannelId.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid emi channel id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        */
        
        guard let authModeString = command.arguments[8] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Auth mode is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        let authMode: PaytmNativeSDK.AuthMode
        if let aMode = AuthMode(rawValue: authModeString) {
            authMode = aMode.nativeAuthMode
        } else {
            authMode = .none
        }
        
        guard let saveCard = command.arguments[9] as? Bool else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Should save card is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        callbackId = command.callbackId
        let shouldSaveCard = (saveCard ? "1" : "0")
        
        let model = AINativeSavedCardParameterModel(withTransactionToken: txnToken, tokenType: .txntoken, orderId: orderId, shouldOpenNativePlusFlow: true, mid: merchantId, flowType: flowType, paymentModes: cardType.paymentMode, authMode: authMode, cardId: nil, cardNumber: cardNumber, cvv: cardCvv, expiryDate: cardExpiry, newCard: true, saveInstrument: shouldSaveCard, redirectionUrl: redirectionUrl)
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.callProcessTransactionAPI(selectedPayModel: model, delegate: weakSelf)
            }
        }
    }
    
    @objc(goForSavedCardTransaction:)
    func goForSavedCardTransaction(command: CDVInvokedUrlCommand) {
        
        guard let cardId = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Card id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !cardId.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid card id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let cardCvv = command.arguments[1] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Card cvv is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !cardCvv.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid card cvv")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let cardTypeString = command.arguments[2] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Card type is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let cardType = CardType(rawValue: cardTypeString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid card type")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let paymentFlowString = command.arguments[3] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Payment flow is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let flowType = AINativePaymentFlow(rawValue: paymentFlowString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid payment flow")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let channelCode = command.arguments[4] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Channel code is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !channelCode.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid channel code")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let issuingBankCode = command.arguments[5] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Issuing bank code is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !issuingBankCode.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid issuing bank code")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        /*
        guard let emiChannelId = command.arguments[6] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Emi channel id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !emiChannelId.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid emi channel id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        */
        
        guard let authModeString = command.arguments[7] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Auth mode is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        let authMode: PaytmNativeSDK.AuthMode
        if let aMode = AuthMode(rawValue: authModeString) {
            authMode = aMode.nativeAuthMode
        } else {
            authMode = .none
        }
        
        callbackId = command.callbackId
        let model = AINativeSavedCardParameterModel(withTransactionToken: txnToken, tokenType: .txntoken, orderId: orderId, shouldOpenNativePlusFlow: true, mid: merchantId, flowType: flowType, paymentModes: cardType.paymentMode, authMode: authMode, cardId: cardId, cardNumber: nil, cvv: cardCvv, expiryDate: nil, newCard: false, saveInstrument: "0", redirectionUrl: redirectionUrl)
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.callProcessTransactionAPI(selectedPayModel: model, delegate: weakSelf)
            }
        }
    }
    
    @objc(getBin:)
    func getBin(command: CDVInvokedUrlCommand) {
        
        guard let cardSixDigit = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "First six card digits string is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !cardSixDigit.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid card digits")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let tokenTypeString = command.arguments[1] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Token type is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let tokenType = TokenType(rawValue: tokenTypeString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid token type")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let token = command.arguments[2] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Token is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !token.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid token")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let mid = command.arguments[3] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Merchant id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !mid.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid merchant id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        /*
        guard let refId = command.arguments[4] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Reference id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !refId.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid reference id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        */
        
        callbackId = command.callbackId
        let model = AINativeSavedCardParameterModel(withTransactionToken: txnToken, tokenType: tokenType, orderId: orderId, shouldOpenNativePlusFlow: true, mid: mid, flowType: .none, paymentModes: .debitCard, authMode: .none, cardId: nil, cardNumber: cardSixDigit, cvv: nil, expiryDate: nil, newCard: false, saveInstrument: "0", redirectionUrl: redirectionUrl)
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.fetchBin(selectedPayModel: model, delegate: weakSelf)
            }
        }
    }
        
    @objc(fetchEmiDetails:)
    func fetchEmiDetails(command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: .error, messageAs: "Method not implemented")
        commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    
}

// MARK: Net Banking related methods
public extension CustomUISDK {
    
    @objc(goForNetBankingTransaction:)
    func goForNetBankingTransaction(command: CDVInvokedUrlCommand) {
        
        guard let netBankingCode = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Net banking code is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !netBankingCode.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid net banking code")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let paymentFlowString = command.arguments[1] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Payment flow is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let flowType = AINativePaymentFlow(rawValue: paymentFlowString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid payment flow")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        callbackId = command.callbackId
        aiHandler.saveNetBankingMethod(channelCode: netBankingCode)
        
        let model = AINativeNBParameterModel(withTransactionToken: txnToken, orderId: orderId, shouldOpenNativePlusFlow: true, mid: merchantId, flowType: flowType, paymentModes: .netBanking, channelCode: netBankingCode, redirectionUrl: redirectionUrl)
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.callProcessTransactionAPI(selectedPayModel: model, delegate: weakSelf)
            }
        }
    }
        
    @objc(fetchNBList:)
    func fetchNBList(command: CDVInvokedUrlCommand) {
        
        /*
        guard let tokenTypeString = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Token type is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let tokenType = TokenType(rawValue: tokenTypeString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid token type")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        */
        
        guard let token = command.arguments[1] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Token is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !token.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid token")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let mid = command.arguments[2] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Merchant id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !mid.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid merchant id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let orderId = command.arguments[3] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Order id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !orderId.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid order id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let refId = command.arguments[3] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Reference id is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !refId.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid reference id")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        callbackId = command.callbackId
        let model = AINativeNBParameterModel(withTransactionToken: txnToken, orderId: orderId, shouldOpenNativePlusFlow: true, mid: mid, flowType: .none, paymentModes: .netBanking, channelCode: refId, redirectionUrl: redirectionUrl)
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.fetchNetBankingChannels(selectedPayModel: model, delegate: weakSelf)
            }
        }
    }
    
    @objc(getLastNBSavedBank:)
    func getLastNBSavedBank(command: CDVInvokedUrlCommand) {
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                if let savedNetBankingMethod = weakSelf.aiHandler.getSavedNetBankingMethod(),
                    !savedNetBankingMethod.isEmpty {
                    let pluginResult = CDVPluginResult(status: .ok, messageAs: savedNetBankingMethod)
                    weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                } else {
                    let pluginResult = CDVPluginResult(status: .error, messageAs: "No saved net banking method")
                    weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
        }
    }
    
}

// MARK: UPI related methods
public extension CustomUISDK {
    
    @objc(goForUpiCollectTransaction:)
    func goForUpiCollectTransaction(command: CDVInvokedUrlCommand) {
        
        guard let upiCode = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Upi code is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !upiCode.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid upi code")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let paymentFlowString = command.arguments[1] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Payment flow is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let flowType = AINativePaymentFlow(rawValue: paymentFlowString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid payment flow")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        if let shouldSaveVpa = command.arguments[2] as? Bool,
            (upiCode != aiHandler.getSavedVPA() && shouldSaveVpa) {
            aiHandler.saveVPA(vpa: upiCode)
        }
        callbackId = command.callbackId
        
        let model = AINativeNUPIarameterModel(withTransactionToken: txnToken, orderId: orderId, shouldOpenNativePlusFlow: true, mid: merchantId, flowType: flowType, amount: CGFloat(amount), paymentModes: .upi, vpaAddress: upiCode, upiFlowType: .collect, merchantInfo: nil, bankDetail: nil, redirectionUrl: redirectionUrl)
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                let upiConfig = UpiCollectConfigurations(shouldAllowCustomPolling: false, isAutoPolling: true)
                weakSelf.aiHandler.callProcessTransitionAPIForCollect(selectedPayModel: model, delegate: weakSelf, upiPollingConfig: upiConfig) { [weak self] _ in
                    weakSelf.aiHandler.upiCollectPollingCompletion = { [weak self] (status, model) in
                        guard let weakSelf = self else {
                            return
                        }
                        let pluginResult: CDVPluginResult
                        switch status {
                        case .none:
                            pluginResult = CDVPluginResult(status: .ok, messageAs: "Upi collect completed with status - NONE")
                        case .pending:
                            pluginResult = CDVPluginResult(status: .ok, messageAs: "Upi collect completed with status - PENDING")
                        case .failure:
                            pluginResult = CDVPluginResult(status: .ok, messageAs: "Upi collect completed with status - FAILURE")
                        case .success:
                            pluginResult = CDVPluginResult(status: .ok, messageAs: "Upi collect completed with status - SUCCESS")
                        case .timeElapsed:
                            pluginResult = CDVPluginResult(status: .ok, messageAs: "Upi collect completed with status - TIME ELAPSED")
                        }
                        weakSelf.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                    }
                }
            }
        }
    }
    
    @objc(goForUpiPushTransaction:)
    func goForUpiPushTransaction(command: CDVInvokedUrlCommand) {
        
        guard let paymentFlowString = command.arguments[0] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Payment flow is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let flowType = AINativePaymentFlow(rawValue: paymentFlowString) else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid payment flow")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let bankDetails = command.arguments[1] as? [String: Any] else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Bank details are required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let vpaName = command.arguments[2] as? String else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Vpa name is required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard !vpaName.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid vpa name")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        
        guard let merchantDetails = command.arguments[3] as? [String: Any] else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Bank details are required")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }

        callbackId = command.callbackId
        let model = AINativeNUPIarameterModel(withTransactionToken: txnToken, orderId: orderId, shouldOpenNativePlusFlow: true, mid: merchantId, flowType: flowType, amount: CGFloat(amount), paymentModes: .upi, vpaAddress: vpaName, upiFlowType: .push, merchantInfo: merchantDetails, bankDetail: bankDetails, redirectionUrl: redirectionUrl)
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.callProcessTransactionAPIForUPI(selectedPayModel: model) { [weak self] status in
                    guard let weakSelf = self else {
                        return
                    }
                    let pluginResult: CDVPluginResult
                    
                    switch status {
                    case .appNotInstall:
                        pluginResult = CDVPluginResult(status: .ok, messageAs: "Upi collect completed with status - NONE")
                    case .error:
                        pluginResult = CDVPluginResult(status: .ok, messageAs: "Upi collect completed with status - PENDING")
                    case .inProcess:
                        return
                    }
                    weakSelf.commandDelegate.send(pluginResult, callbackId: command.callbackId)
                }
            }
        }
    }
    
    @objc(fetchUpiBalance:)
    func fetchUpiBalance(command: CDVInvokedUrlCommand) {
        
        guard let bankDetails = command.arguments[0] as? [String: Any] else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid bank detail object")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        callbackId = command.callbackId
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.getUPIBalance(bankDetails: bankDetails, mid: weakSelf.merchantId) { [weak self] status in
                    guard let weakSelf = self else {
                        return
                    }
                    let pluginResult: CDVPluginResult
                    
                    switch status {
                    case .appNotInstall:
                        pluginResult = CDVPluginResult(status: .error, messageAs: "Paytm is not installed")
                    case .error:
                        pluginResult = CDVPluginResult(status: .error, messageAs: "Something went wrong")
                    case .inProcess:
                        return
                    }
                    weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
        }
    }
    
    @objc(setUpiMpin:)
    func setUpiMpin(command: CDVInvokedUrlCommand) {
        
        guard let bankDetailDict = command.arguments[0] as? [String: Any] else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid bank detail object")
            commandDelegate!.send(pluginResult, callbackId: command.callbackId)
            return
        }
        callbackId = command.callbackId
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.setupUPIPin(bankDetails: bankDetailDict, mid: weakSelf.merchantId) { [weak self] status in
                    guard let weakSelf = self else {
                        return
                    }
                    let pluginResult: CDVPluginResult
                    
                    switch status {
                    case .appNotInstall:
                        pluginResult = CDVPluginResult(status: .error, messageAs: "Paytm is not installed")
                    case .error:
                        pluginResult = CDVPluginResult(status: .error, messageAs: "Something went wrong")
                    case .inProcess:
                        return
                    }
                    weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
        }
    }
    
    @objc(getUpiIntentList:)
    func getUpiIntentList(command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: .error, messageAs: "Method not implemented")
        commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc(goForUpiIntentTransaction:)
    func goForUpiIntentTransaction(command: CDVInvokedUrlCommand) {
        let pluginResult = CDVPluginResult(status: .error, messageAs: "Method not implemented")
        commandDelegate!.send(pluginResult, callbackId: command.callbackId)
    }
    
    @objc(getLastSavedVPA:)
    func getLastSavedVPA(command: CDVInvokedUrlCommand) {
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                if let savedVpa = weakSelf.aiHandler.getSavedVPA(),
                    !savedVpa.isEmpty {
                    let pluginResult = CDVPluginResult(status: .ok, messageAs: savedVpa)
                    weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                } else {
                    let pluginResult = CDVPluginResult(status: .error, messageAs: "No saved vpa")
                    weakSelf.commandDelegate!.send(pluginResult, callbackId: command.callbackId)
                }
            }
        }
    }
}

extension CustomUISDK: AIDelegate {
    
    public func didFinish(with success: Bool, response: [String: Any], error: String?, withUserCancellation hasUserCancelledTransaction: Bool) {
        let pluginResult: CDVPluginResult
        if hasUserCancelledTransaction {
            pluginResult = CDVPluginResult(status: .error, messageAs: hasUserCancelledTransaction)
        } else if let err = error {
            pluginResult = CDVPluginResult(status: .error, messageAs: err)
        } else if success {
            pluginResult = CDVPluginResult(status: .ok, messageAs: response)
        } else {
            pluginResult = CDVPluginResult(status: .error, messageAs: response)
        }
        commandDelegate!.send(pluginResult, callbackId: callbackId)
        if let presentedViewController = viewController.presentedViewController {
            presentedViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    public func openPaymentController(_ controller: UIViewController) {
        viewController.present(controller, animated: true, completion: nil)
    }
}

private extension CustomUISDK {
    
    func showConsentView(completion: @escaping (() -> Void)) {
        let alertController = UIAlertController(title: "Provide Consent", message: nil, preferredStyle: .actionSheet)
        let customView = AINativeConsentView()
        alertController.view.addSubview(customView)
        customView.translatesAutoresizingMaskIntoConstraints = false
        customView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 45).isActive = true
        customView.rightAnchor.constraint(equalTo: alertController.view.rightAnchor, constant: -100).isActive = true
        customView.leftAnchor.constraint(equalTo: alertController.view.leftAnchor, constant: 100).isActive = true
        customView.heightAnchor.constraint(equalToConstant: 70).isActive = true
        
        let width = (UIScreen.main.bounds.width - 17)
        customView.widthAnchor.constraint(equalToConstant: width).isActive = true

        alertController.view.translatesAutoresizingMaskIntoConstraints = false
        alertController.view.heightAnchor.constraint(equalToConstant: 180).isActive = true
        
        let doneAction = UIAlertAction(title: "Done", style: .cancel) { _ in
            alertController.dismiss(animated: true) {
                completion()
            }
        }
        alertController.addAction(doneAction)
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    func openRedirectionFlow() {
        
        guard !orderId.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid order id")
            commandDelegate!.send(pluginResult, callbackId: callbackId)
            return
        }
        
        guard !txnToken.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid transaction token")
            commandDelegate!.send(pluginResult, callbackId: callbackId)
            return
        }
        
        guard !merchantId.isEmpty else {
            let pluginResult = CDVPluginResult(status: .error, messageAs: "Invalid merchant id")
            commandDelegate!.send(pluginResult, callbackId: callbackId)
            return
        }
        
        commandDelegate.run { [weak self] in
            DispatchQueue.main.async { [weak self] in
                guard let weakSelf = self else {
                    return
                }
                weakSelf.aiHandler.openRedirectionFlow(orderId: weakSelf.orderId, txnToken: weakSelf.txnToken, mid: weakSelf.merchantId, delegate: weakSelf)
            }
        }
    }
    
    func handleURL(_ url: URL) {
        let queryParams = separateDeeplinkParamsIn(url: url.absoluteString, byRemovingParams: nil)
        let pluginResult = CDVPluginResult(status: .ok, messageAs: queryParams)
        commandDelegate!.send(pluginResult, callbackId: callbackId)
    }
    
    func separateDeeplinkParamsIn(url: String?, byRemovingParams rparams: [String]?)  -> [String: String] {
        var parameters = [String: String]()
        
        guard let url = url else {
            return parameters
        }
        /// This url gets mutated until the end. The approach is working fine in current scenario. May need a revisit.
        var urlString = stringByRemovingDeeplinkSymbolsIn(url: url)
        let components = urlString.components(separatedBy: CharacterSet(charactersIn: "&?//"))
        
        for keyValuePair in components {
            let info = keyValuePair.components(separatedBy: CharacterSet(charactersIn: "="))
            if let fst = info.first , let lst = info.last, info.count == 2 {
                parameters[fst] = lst.removingPercentEncoding
                if let rparams = rparams, rparams.contains(info.first!) {
                    urlString = urlString.replacingOccurrences(of: keyValuePair + "&", with: "")
                    // Please dont interchage the order
                    urlString = urlString.replacingOccurrences(of: keyValuePair, with: "")
                }
            }
        }
        if let trimmedURL = components.first {
            parameters["trimmedurl"] = trimmedURL
        }
        return parameters
    }
    
    func stringByRemovingDeeplinkSymbolsIn(url: String) -> String {
        var urlString = url.replacingOccurrences(of: "$", with: "&")
        
        /// This may need a revisit. This is doing more than just removing the deeplink symbol.
        if let range = urlString.range(of: "&"), urlString.contains("?") == false {
            urlString = urlString.replacingCharacters(in: range, with: "?")
        }
        return urlString
    }
}
