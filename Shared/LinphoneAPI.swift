//
//  Account.swift
//  accelnet
//
//  Created by piajesse on 10/19/21.
//
import Foundation
import Alamofire
import linphonesw
import CallKit


public class LinphoneAPI : ObservableObject {
	var mCore: Core!
	@Published var coreVersion: String = Core.getVersion
	var mCoreDelegate : CoreDelegate!
	var accountsList: [AccountDetails]?
	@Published var loggedIn: Bool = false
	
	// Outgoing call related variables
	@Published var callMsg : String = ""
	@Published var isCallIncoming : Bool = false
	@Published var callDestination : String = ""
	@Published var callStateText : String = "Not Logged In Yet...."
	@Published var isCallRunning : Bool = false
	@Published var isCallActive : Bool = false
	@Published var isCallPaused: Bool = false
	@Published var isSpeakerEnabled : Bool = false
	@Published var isMicrophoneEnabled : Bool = false
	@Published var callStartTime : Date = Date()
	@Published var currentCall : Call?
	@Published var conference : Conference? = nil


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
				self.callDestination = call.remoteAddress!.username
				self.isCallActive = true
				self.currentCall = call
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
				self.isCallPaused = false
				self.callDestination = call.remoteAddress!.username
			} else if (state == .Paused) {
				// When you put a call in pause, it will became Paused
				self.callStateText = "Paused"
				self.isCallPaused = true
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
				self.isCallPaused = false
				self.isCallRunning = false
				self.callDestination = ""
				self.isCallActive = false
				self.currentCall = nil
				self.conference = nil
			} else if (state == .Error) {
				self.isCallPaused = false
				self.isCallRunning = false
				self.callDestination = ""
				self.currentCall = nil
				self.conference = nil
				
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
	// call a number, returns true if the call worked
	public func callNumber(numberToDial: String) -> Bool {
		do {
			if accountsList == nil {
				NSLog("There appears to be no accounts, but the user was able to get past first launch, and tried to call")
				return false
			}
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
			return true
		} catch {
			NSLog(error.localizedDescription)
			return false
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
				if result {
					UserDefaults.standard.set(provisioningData, forKey: "ProvisioningURL")
				}
				return
			}.resume()
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
	// Sends DTMF in call
	func dialToneInCall(tone: CChar) {
		do {
			try! currentCall!.sendDtmf(dtmf: tone)
		}
	}
	// Sends DTMF Sound locally
	func dialTone(tone: CChar) {
		mCore.playDtmf(dtmf: tone, durationMs: 100)
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
		try! currentCall?.terminate()
	}
	func toggleSpeaker() {
		// Get the currently used audio device
		let currentAudioDevice = currentCall?.outputAudioDevice
		let speakerEnabled = currentAudioDevice?.type == AudioDeviceType.Speaker
		
//		let test = currentAudioDevice?.deviceName
		// We can get a list of all available audio devices using
		// Note that on tablets for example, there may be no Earpiece device
		for audioDevice in mCore.audioDevices {
			
			// For IOS, the Speaker is an exception, Linphone cannot differentiate Input and Output.
			// This means that the default output device, the earpiece, is paired with the default phone microphone.
			// Setting the output audio device to the microphone will redirect the sound to the earpiece.
			if (speakerEnabled && audioDevice.type == AudioDeviceType.Microphone) {
				currentCall?.outputAudioDevice = audioDevice
				isSpeakerEnabled = false
				return
			} else if (!speakerEnabled && audioDevice.type == AudioDeviceType.Speaker) {
				currentCall?.outputAudioDevice = audioDevice
				isSpeakerEnabled = true
				return
			}
			/* If we wanted to route the audio to a bluetooth headset
			 else if (audioDevice.type == AudioDevice.Type.Bluetooth) {
			 core.currentCall?.outputAudioDevice = audioDevice
			 }*/
		}

	}
	func conferenceDial(destination: String) {
		if (conference == nil) {
			guard let cp = try? mCore.createConferenceParams() else {
				NSLog("Unable to create conference parameters")
				return
			}
			if let currentParams = currentCall?.currentParams  {
				cp.videoEnabled = currentParams.videoEnabled
			}
			conference = try? mCore.createConferenceWithParams(params: cp)
		}
		mCore.calls.forEach { call in
			if (call.conference == nil || call.conference?.participantCount == 1) {
				try? conference?.addParticipant(call: call)
			}
		}
	}
	func transferCall(destination: String) {
		do {
			let remoteAddress = try! Factory.Instance.createAddress(addr: "sips:" + destination + "@" + (accountsList?[0].tenant)! + ".sip.callpipe.com")
			try! currentCall?.transferTo(referTo: remoteAddress)
		}
	}
	func toggleMic() {
		mCore.micEnabled = !mCore.micEnabled
		isMicrophoneEnabled = !isMicrophoneEnabled
	}
	func toggleHold() {
		do {
			if isCallPaused {
				try! currentCall?.resume()
			} else {
				try! currentCall?.pause()
			}
		}
	}
	func deleteAll() {
		hangUp()
		let accounts = mCore.accountList
		for account in accounts {
			mCore.removeAccount(account: account)
		}
		mCore.clearAccounts()
		mCore.clearAllAuthInfo()
		UserDefaults.standard.set(nil, forKey: "JSONString")
		UserDefaults.standard.set(nil, forKey: "ProvisioningURL")
		NSLog("Killing app so user can reenter details on startup")
		exit(0)
	}
	func processJSON(jsonString: String)  -> Bool {
		do {
			var result = false
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
				if account.params!.registerEnabled {
					result = true
					if defaultAccount == nil {
						defaultAccount = account
						mCore.defaultAccount = defaultAccount
					}
				}
			}
			UserDefaults.standard.set(jsonString, forKey: "JSONString")
			return result
		} catch let DecodingError.dataCorrupted(context) {
			print(context)
		} catch let DecodingError.keyNotFound(key, context) {
			print("Key '\(key)' not found:", context.debugDescription)
			print("codingPath:", context.codingPath)
		} catch let DecodingError.valueNotFound(value, context) {
			print("Value '\(value)' not found:", context.debugDescription)
			print("codingPath:", context.codingPath)
		} catch let DecodingError.typeMismatch(type, context)  {
			print("Type '\(type)' mismatch:", context.debugDescription)
			print("codingPath:", context.codingPath)
		} catch {
			print("error: ", error)
		}
		return false
	}
	public func parseJSON(jsonString: String) throws -> JSONConfig {
		return try JSONDecoder().decode(JSONConfig.self, from: jsonString.data(using: .utf8)!)
	}
}
public struct JSONConfig: Codable {
	var accounts: [AccountDetails]
}
public struct AccountDetails: Codable {
	var tenant, username, password: String
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
