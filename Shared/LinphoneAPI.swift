//
//  Account.swift
//  accelnet
//
//  Created by piajesse on 10/19/21.
//
import Foundation
import linphonesw

class LinphoneAPI : ObservableObject {
	var mCore: Core!
	@Published var coreVersion: String = Core.getVersion
	private var accounts = [Response.AccountDetails]()
	
	var mRegistrationDelegate : CoreDelegate!
	
	init(){
		LoggingService.Instance.logLevel = .Debug
		let factory = Factory.Instance
		
		try! mCore = factory.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
		try! mCore.start()
		
		
		mRegistrationDelegate = CoreDelegateStub(onAccountRegistrationStateChanged: { (core: Core, account: Account, state: RegistrationState, message: String) in
			NSLog("New registration state is \(state) for user id \( String(describing: account.params?.identityAddress?.asString()))\n")
		})
		mCore.addDelegate(delegate: mRegistrationDelegate)
		coreVersion = Core.getVersion
	}
	public func getAccounts() -> [String] {
		return ["account1", "account2"]
//		var result = [String]()
//		for account in accounts {
//			result.append(account.username)
//		}
//		return result
	}
	// Returns the LinphoneSDK version number
	public func getVersion() -> String {
		return coreVersion
	}
	// Uses a JSON string directly or a URL to grab a JSON string to provision the app, if the app is provisioned already, it will ask to confirm the change
	func setupAccounts(provisioningData: String) -> Bool {
		
		if provisioningData.isValidURL {
			NSLog("Data provided appears to be a valid URL, going to download it now")
			let url = NSURL(string: provisioningData)
			var result: Bool = false
			URLSession.shared.dataTask(with: url! as URL) { data, response, error in
				let jsonString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
				result = self.parseJSON(jsonString: jsonString)
				return
			}.resume()
			return result
		} else {
			NSLog("Data provided doesn't not appear to be a URL, lets try it as a JSON object")
			return parseJSON(jsonString: provisioningData)
		}
	}
	func unregister() {
		let accounts = mCore.accountList
		for account in accounts {
			let params = account.params
			let clonedParams = params?.clone()
			clonedParams?.registerEnabled = false
			account.params = clonedParams
		}
	}
	func deleteAll() {
		let accounts = mCore.accountList
		for account in accounts {
			mCore.removeAccount(account: account)
		}
		mCore.clearAccounts()
		mCore.clearAllAuthInfo()
	}
	func parseJSON(jsonString: String)  -> Bool {
		do {
			var defaultAccount: Account?
			let jsonData = try JSONDecoder().decode(Response.self, from: jsonString.data(using: .utf8)!)
			accounts = jsonData.accounts
			for a in accounts {
				let domain = a.tenant + ".sip.callpipe.com"
				let authInfo = try Factory.Instance.createAuthInfo(username: a.username, userid: "", passwd: a.password, ha1: "", realm: "", domain: domain)
				let accountParams = try mCore.createAccountParams()
				let identity = try Factory.Instance.createAddress(addr: String("sip:" + a.username + "@" + domain))
				try! accountParams.setIdentityaddress(newValue: identity)
				let address = try Factory.Instance.createAddress(addr: "sip:flexsip.callpipe.com")
				try address.setTransport(newValue: TransportType.Tls)
				try accountParams.setServeraddress(newValue: address)
				accountParams.registerEnabled = true
				let account = try mCore.createAccount(params: accountParams)
				mCore.addAuthInfo(info: authInfo)
				try mCore.addAccount(account: account)
				if defaultAccount == nil {
					defaultAccount = account
					mCore.defaultAccount = defaultAccount
				}
			}
			return true
		} catch {
			NSLog(error.localizedDescription)
			return false
		}
	}
}

struct Response: Codable {
	struct AccountDetails: Codable {
		var tenant: String
		var username: String
		var password: String
	}
	var accounts: [AccountDetails]
}


/* Example json string
{
	"accounts": [
		{
			"tenant": "weirdname",
			"username": "69",
			"password": "passw0rd"
		},
		{
			"tenant": "foobar",
			"username": "42",
			"password": "p4ssword"
		}
	]
}
 
{"accounts":[{"tenant":"weirdname","username":"69","password":"passw0rd"},{"tenant":"foobar","username":"42","password":"p4ssword"}]}

*/
