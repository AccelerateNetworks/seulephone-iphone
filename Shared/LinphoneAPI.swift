//
//  Account.swift
//  accelnet
//
//  Created by piajesse on 10/19/21.
//
import Foundation
import linphonesw

public class LinphoneAPI : ObservableObject {
	var mCore: Core!
	@Published var coreVersion: String = Core.getVersion
	var mCoreDelegate : CoreDelegate!
	var accountsList: [JSONConfig.AccountDetails]?
	@Published var loggedIn: Bool = false
	
	// Outgoing call related variables
	@Published var callMsg : String = ""
	@Published var isCallIncoming : Bool = false
	@Published var callDestination : String = ""
	@Published var callStateText : String = "Not Logged In Yet...."
	@Published var isCallRunning : Bool = false
	@Published var isCallActive : Bool = false
	@Published var isSpeakerEnabled : Bool = false
	@Published var isMicrophoneEnabled : Bool = false
	@Published var callStartTime : Date = Date()


	init(){
		LoggingService.Instance.logLevel = .Debug
		let factory = Factory.Instance
		
		try! mCore = factory.createCore(configPath: "", factoryConfigPath: "", systemContext: nil)
		try! mCore.start()
		
		mCoreDelegate = CoreDelegateStub( onCallStateChanged: { (core: Core, call: Call, state: Call.State, message: String) in
			// This function will be called each time a call state changes,
			// which includes new incoming/outgoing calls
			self.callMsg = message
			
			if (state == .OutgoingInit) {
				self.callStateText = "Initializing."
				self.isCallActive = true
				// First state an outgoing call will go through
			} else if (state == .OutgoingProgress) {
				// Right after outgoing init
				self.callStateText = "Initializing.."
			} else if (state == .OutgoingRinging) {
				// This state will be reached upon reception of the 180 RINGING
				self.callStateText = "Ringing..."
			} else if (state == .Connected) {
				// When the 200 OK has been received
				self.callStateText = "Connected"
			} else if (state == .StreamsRunning) {
				// This state indicates the call is active.
				// You may reach this state multiple times, for example after a pause/resume
				// or after the ICE negotiation completes
				// Wait for the call to be connected before allowing a call update
				self.callStateText = "In call"
				self.callStartTime = Date()
				self.isCallRunning = true
				self.callDestination = call.remoteAddress!.username
			} else if (state == .Paused) {
				// When you put a call in pause, it will became Paused
				self.callStateText = "Paused"
			} else if (state == .PausedByRemote) {
				// When the remote end of the call pauses it, it will be PausedByRemote
				self.callStateText = "Paused"
			} else if (state == .Updating) {
				// When we request a call update, for example when toggling video
				self.callStateText = "Updating"
			} else if (state == .UpdatedByRemote) {
				// When the remote requests a call update
				self.callStateText = "Updating"
			} else if (state == .Released) {
				// Call state will be released shortly after the End state
				self.callStateText = "Initializing"
				self.isCallRunning = false
				self.callDestination = ""
				self.isCallActive = false
			} else if (state == .Error) {
				self.isCallRunning = false
				self.callDestination = ""
				
			}
		}, onAccountRegistrationStateChanged: { (core: Core, account: Account, state: RegistrationState, message: String) in
			NSLog("New registration state is \(state) for user id \( String(describing: account.params?.identityAddress?.asString()))\n")
			if (state == .Ok) {
				self.loggedIn = true
			} else if (state == .Cleared) {
				self.loggedIn = false
			}
		})
		mCore.addDelegate(delegate: mCoreDelegate)
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
				addressToDial = "sips:" + numberToDial + "@" + (accountsList?[0].tenant)! + ".sip.callpipe.com"
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
	func getTimeOnCall() -> String {
		if isCallActive && !isCallRunning{
			return callStateText
		}
		let timeInCall = Int (abs(callStartTime.timeIntervalSinceNow))
		var timeInCallText: String = ""
		if timeInCall > 3599 {
			timeInCallText = String(timeInCall / 3600) + ":"
		}
		if (timeInCall % 3600 / 60) < 10 {
			timeInCallText = timeInCallText + "0" +  String((timeInCall % 3600) / 60) + ":"
		} else {
			timeInCallText = timeInCallText + "0" +  String((timeInCall % 3600) / 60) + ":"
		}
		if (timeInCall % 60) < 10 {
			timeInCallText = timeInCallText + "0" + String(timeInCall % 60)
		} else {
			timeInCallText = timeInCallText + String(timeInCall % 60)
		}
		return timeInCallText

	}
	func getCallerDestination() -> String {
		return callDestination
	}
	func hangUp() {
		try! mCore.currentCall?.terminate()
	}
	func toggleSpeaker() {
		// Get the currently used audio device
		let currentAudioDevice = mCore.currentCall?.outputAudioDevice
		let speakerEnabled = currentAudioDevice?.type == AudioDeviceType.Speaker
		
//		let test = currentAudioDevice?.deviceName
		// We can get a list of all available audio devices using
		// Note that on tablets for example, there may be no Earpiece device
		for audioDevice in mCore.audioDevices {
			
			// For IOS, the Speaker is an exception, Linphone cannot differentiate Input and Output.
			// This means that the default output device, the earpiece, is paired with the default phone microphone.
			// Setting the output audio device to the microphone will redirect the sound to the earpiece.
			if (speakerEnabled && audioDevice.type == AudioDeviceType.Microphone) {
				mCore.currentCall?.outputAudioDevice = audioDevice
				isSpeakerEnabled = false
				return
			} else if (!speakerEnabled && audioDevice.type == AudioDeviceType.Speaker) {
				mCore.currentCall?.outputAudioDevice = audioDevice
				isSpeakerEnabled = true
				return
			}
			/* If we wanted to route the audio to a bluetooth headset
			 else if (audioDevice.type == AudioDevice.Type.Bluetooth) {
			 core.currentCall?.outputAudioDevice = audioDevice
			 }*/
		}

	}
	func toggleMic() {
		mCore.micEnabled = !mCore.micEnabled
		isMicrophoneEnabled = !isMicrophoneEnabled
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
