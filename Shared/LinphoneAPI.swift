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
	var mRegistrationDelegate : CoreDelegate!
	var accountsList: [JSONConfig.AccountDetails]?
	
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
//		return ["account1", "account2"]
		var result = [String]()
		for account in mCore.accountList {
			result.append(account.contactAddress?.displayName ?? "Account Not setup yet")
		}
		return result
	}
	// Returns the LinphoneSDK version number
	public func getVersion() -> String {
		return coreVersion
	}
	// call a number
	public func callNumber(numberToDial: String) {
		do {
			let addressToDial: String
			if numberToDial == "" {
				addressToDial = "sips:4254997999@" + (accountsList?[0].tenant)! + ".sip.callpipe.com"
			} else {
				addressToDial = "sips:" + numberToDial + "@" + (mCore.defaultAccount?.contactAddress?.domain)!
			}
			NSLog("Attempting to dial " + addressToDial)
			let remoteAddress = try Factory.Instance.createAddress(addr: addressToDial)
			let params = try mCore.createCallParams(call: nil)
			params.mediaEncryption = MediaEncryption.SRTP
			let _ = mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
		} catch {
			NSLog(error.localizedDescription)
		}
	}
	// Uses a JSON string directly or a URL to grab a JSON string to provision the app, if the app is provisioned already, it will ask to confirm the change
	func setupAccounts(provisioningData: String) -> Bool {
		if provisioningData.isValidURL {
			NSLog("Data provided appears to be a valid URL, going to download it now")
			NSLog("URL is: " + provisioningData)
			let url = NSURL(string: provisioningData)
			var result: Bool = false
			URLSession.shared.dataTask(with: url! as URL) { data, response, error in
				let jsonString = NSString(data: data!, encoding: String.Encoding.utf8.rawValue)! as String
				result = self.processJSON(jsonString: jsonString)
				return
			}.resume()
			if result {
				UserDefaults.standard.set(provisioningData, forKey: "ProvisioningURL")
			}
			return result
		} else {
			NSLog("Data provided doesn't not appear to be a URL, lets try it as a JSON object")
			let result = processJSON(jsonString: provisioningData)
			if result {
				UserDefaults.standard.set("manual", forKey: "ProvisioningURL")
			}
			return result
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
	func processJSON(jsonString: String)  -> Bool {
		do {
			NSLog("JSON data to be processed: " + jsonString)
			var defaultAccount: Account?
			accountsList = try parseJSON(jsonString: jsonString).accounts
			for a in accountsList! {
				let domain = a.tenant + ".sip.callpipe.com"
				let authInfo = try Factory.Instance.createAuthInfo(username: a.username, userid: "", passwd: a.password, ha1: "", realm: "", domain: domain)
				let accountParams = try mCore.createAccountParams()
				let identity = try Factory.Instance.createAddress(addr: String("sips:" + a.username + "@" + domain))
				try! accountParams.setIdentityaddress(newValue: identity)
				let address = try Factory.Instance.createAddress(addr: String("sips:flexisip.callpipe.com"))
				try address.setPort(newValue: 5061)
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
			UserDefaults.standard.set(jsonString, forKey: "JSONString")
			return true
		} catch {
			NSLog(error.localizedDescription)
			return false
		}
	}
	public func parseJSON(jsonString: String) throws -> JSONConfig {
		return try JSONDecoder().decode(JSONConfig.self, from: jsonString.data(using: .utf8)!)
	}
}
public struct JSONConfig: Codable {
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
