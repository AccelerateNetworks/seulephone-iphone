//
//  CallMenu.swift
//  testbed
//
//  Created by piajesse on 11/12/21.
//

import SwiftUI
import PhoneNumberKit
import Alamofire

struct CallMenu: View {
	@ObservedObject var linphone = getLinphoneAPI()
	let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
	@State var menu: String
	@State var timeStamp: String = "Initializing"
	@State var dialedNumbers: String = ""
	@State var displayData: String = ""
	
	init() {
		menu = "main"
	}
	var body: some View {
		switch(menu) {
			// MARK: Main Screen
		case "main" :
			ZStack {
				Color("ANBlue")
					.ignoresSafeArea(edges: .all)
				VStack{
					Text(PartialFormatter().formatPartial(linphone.callDestination))
						.font(.title)
					Text(timeStamp)
						.onReceive(timer) { input in
							timeStamp = linphone.getTimeOnCall()
						}
					Spacer()
					Group {
						Text(dialedNumbers)
						Spacer()
						Group{
							Spacer()
							HStack{
								Spacer()
								Button(action: {
									linphone.toggleMic()
								}, label: {
									VStack{
										Image(systemName: linphone.isMicrophoneEnabled ? "mic.slash" : "mic.fill")
											.resizable()
											.frame(width: linphone.isMicrophoneEnabled ? 40 : 35, height: 50)
										Text("Mute")
									}
									.frame(width: 100, height: 100)
								})
								Spacer()
								Button(action: {
									menu = "numpad"
								}, label: {
									VStack{
										Image(systemName: "circle.grid.3x3")
											.resizable()
											.frame(width: 50, height: 50)
										Text("Keypad")
									}
									.frame(width: 100, height: 100)
								})
								Spacer()
								Button(action: {
									linphone.toggleSpeaker()
								}, label: {
									VStack{
										Image(systemName: linphone.isSpeakerEnabled ?  "speaker.fill" : "speaker")
											.resizable()
											.frame(width: 35, height: 50)
										Text("Speaker")
									}
									.frame(width: 100, height: 100)
								})
								Spacer()
							}
							HStack {
								Spacer()
								Button(action: {
									linphone.toggleHold()
								}, label: {
									VStack{
										Image(systemName: linphone.isCallPaused ? "play.fill" : "pause")
											.resizable()
											.frame(width: linphone.isCallPaused ? 50 : 25, height: 50)
										Text(linphone.isCallPaused ? "Resume" : "Hold")
									}
									.frame(width: 100, height: 100)
								})
								Spacer()
								Button(action: {
									//TODO figure out why conference bugs the hell out
//									menu = "conference"
								}, label: {
									VStack{
										Image(systemName: "person.badge.plus")
											.resizable()
											.frame(width: 50, height: 50)
										Text("Conference")
									}
									.frame(width: 100, height: 100)
								})
								Spacer()
								Button(action: {
									menu = "transfer"
								}, label: {
									VStack{
										Image(systemName: "phone.arrow.right")
											.resizable()
											.frame(width: 50, height: 50)
										Text("Transfer")
									}
									.frame(width: 100, height: 100)
								})
								Spacer()
							}
						}
						Group{
							Spacer()
							Spacer()
							Spacer()
						}
						Button(action: {
							linphone.hangUp()
						}, label: {
							VStack{
								Image(systemName: "phone.down.fill")
									.resizable()
									.frame(width: 100, height: 50)
									.foregroundColor(.red)
								Text("Hang Up")
							}
							.frame(width: 100, height: 100)
						})
					}
				}.foregroundColor(.white)
			}
			// MARK: DialPad Menu
		case "numpad" :
			ZStack {
				Color("ANBlue")
					.ignoresSafeArea(edges: .all)
				VStack{
					Text(PartialFormatter().formatPartial(linphone.callDestination))
						.font(.title)
					Text(timeStamp)
						.onReceive(timer) { input in
							timeStamp = linphone.getTimeOnCall()
						}
					Spacer()
					Group {
						HStack {
							Spacer()
							numpadButton(number: "1", t9chars: "")
							Spacer()
							numpadButton(number: "2", t9chars: "ABC")
							Spacer()
							numpadButton(number: "3", t9chars: "DEF")
							Spacer()
						}
						Spacer()
						HStack {
							Spacer()
							numpadButton(number: "4", t9chars: "GHI")
							Spacer()
							numpadButton(number: "5", t9chars: "JKI")
							Spacer()
							numpadButton(number: "6", t9chars: "MNO")
							Spacer()
						}
						Spacer()
						HStack {
							Spacer()
							numpadButton(number: "7", t9chars: "PQRS")
							Spacer()
							numpadButton(number: "8", t9chars: "TUV")
							Spacer()
							numpadButton(number: "9", t9chars: "WXYZ")
							Spacer()
						}

						Spacer()
						HStack {
							Spacer()
							numpadButton(number: "*", t9chars: nil)
							Spacer()
							numpadButton(number: "0", t9chars: "+")
							Spacer()
							numpadButton(number: "#", t9chars: nil)
							Spacer()
						}
						Spacer()
					}
					
					HStack {
						Spacer()
						Button(action: {
							menu = "main"
						}, label: {
							VStack{
								Image(systemName: "arrowshape.turn.up.backward.fill")
									.resizable()
									.frame(width: 50, height: 50)
								Text("Hide")
							}
							.frame(width: 100, height: 100)
						})
						Spacer()
						Button(action: {
							linphone.hangUp()
						}, label: {
							VStack{
								Image(systemName: "phone.down.fill")
									.resizable()
									.frame(width: 100, height: 50)
									.foregroundColor(.red)
								Text("Hang Up")
							}
							.frame(width: 100, height: 100)
						})
						Spacer()
						VStack {
							Text("")
								.frame(width: 100, height: 100)
						}
						Spacer()
					}
				}
				.foregroundColor(.white)
			}
			// MARK: Transfer Menu
		case "transfer" :
			ZStack {
				Color("ANBlue")
					.ignoresSafeArea(edges: .all)
				VStack{
					Text(PartialFormatter().formatPartial(linphone.callDestination))
						.font(.title)
					Text(timeStamp)
						.onReceive(timer) { input in
							timeStamp = linphone.getTimeOnCall()
						}
					Spacer()
					HStack{
						Image(systemName: "arrow.up.right")
						Text(displayData)
					}
					Group {
						HStack {
							Spacer()
							transferButton(number: "1", t9chars: "")
							Spacer()
							transferButton(number: "2", t9chars: "ABC")
							Spacer()
							transferButton(number: "3", t9chars: "DEF")
							Spacer()
						}
						Spacer()
						HStack {
							Spacer()
							transferButton(number: "4", t9chars: "GHI")
							Spacer()
							transferButton(number: "5", t9chars: "JKI")
							Spacer()
							transferButton(number: "6", t9chars: "MNO")
							Spacer()
						}
						Spacer()
						HStack {
							Spacer()
							transferButton(number: "7", t9chars: "PQRS")
							Spacer()
							transferButton(number: "8", t9chars: "TUV")
							Spacer()
							transferButton(number: "9", t9chars: "WXYZ")
							Spacer()
						}
						
						Spacer()
						HStack {
							Spacer()
							transferButton(number: "*", t9chars: nil)
							Spacer()
							transferButton(number: "0", t9chars: "+")
							Spacer()
							transferButton(number: "#", t9chars: nil)
							Spacer()
						}
						Spacer()
					}
					HStack {
						Spacer()
						Button(action: {
							displayData = ""
							menu = "main"
						}, label: {
							VStack{
								Image(systemName: "arrowshape.turn.up.backward.fill")
									.resizable()
									.frame(width: 50, height: 50)
								Text("Back")
							}
							.frame(width: 100, height: 100)
						})
						Spacer()
						Button(action: {
							linphone.hangUp()
						}, label: {
							VStack{
								Image(systemName: "phone.down.fill")
									.resizable()
									.frame(width: 100, height: 50)
									.foregroundColor(.red)
								Text("Hang Up")
							}
							.frame(width: 100, height: 100)
						})
						Spacer()
						Button(action: {
							linphone.transferCall(destination: displayData)
						}, label: {
							VStack{
								Image(systemName: "phone.fill.arrow.right")
									.resizable()
									.frame(width: 40, height: 40)
								Text("Transfer")
								Text("call")
							}
							.frame(width: 100, height: 100)
						})
						Spacer()
					}
				}
				.foregroundColor(.white)
			}
			// MARK: Conference Menu
		case "conference" :
			ZStack {
				Color("ANBlue")
					.ignoresSafeArea(edges: .all)
				VStack{
					Text(PartialFormatter().formatPartial(linphone.callDestination))
						.font(.title)
					Text(timeStamp)
						.onReceive(timer) { input in
							timeStamp = linphone.getTimeOnCall()
						}
					Spacer()
					HStack{
						Image(systemName: "person.3.fill")
						Text(displayData)
					}
					Group {
						HStack {
							Spacer()
							conferenceButton(number: "1", t9chars: "")
							Spacer()
							conferenceButton(number: "2", t9chars: "ABC")
							Spacer()
							conferenceButton(number: "3", t9chars: "DEF")
							Spacer()
						}
						Spacer()
						HStack {
							Spacer()
							conferenceButton(number: "4", t9chars: "GHI")
							Spacer()
							conferenceButton(number: "5", t9chars: "JKI")
							Spacer()
							conferenceButton(number: "6", t9chars: "MNO")
							Spacer()
						}
						Spacer()
						HStack {
							Spacer()
							conferenceButton(number: "7", t9chars: "PQRS")
							Spacer()
							conferenceButton(number: "8", t9chars: "TUV")
							Spacer()
							conferenceButton(number: "9", t9chars: "WXYZ")
							Spacer()
						}
						Spacer()
						HStack {
							Spacer()
							conferenceButton(number: "*", t9chars: nil)
							Spacer()
							conferenceButton(number: "0", t9chars: "+")
							Spacer()
							conferenceButton(number: "#", t9chars: nil)
							Spacer()
						}
						Spacer()
					}
					HStack {
						Spacer()
						Button(action: {
							displayData = ""
							menu = "main"
						}, label: {
							VStack{
								Image(systemName: "arrowshape.turn.up.backward.fill")
									.resizable()
									.frame(width: 50, height: 50)
								Text("Hide")
							}
							.frame(width: 100, height: 100)
						})
						Spacer()
						Button(action: {
							linphone.hangUp()
						}, label: {
							VStack{
								Image(systemName: "phone.down.fill")
									.resizable()
									.frame(width: 100, height: 50)
									.foregroundColor(.red)
								Text("Hang Up")
							}
							.frame(width: 100, height: 100)
						})
						Button(action: {
							linphone.conferenceDial(destination: displayData)
							menu = "main"
						}, label: {
							VStack{
								Image(systemName: "person.fill.badge.plus")
									.resizable()
									.frame(width: 30, height: 30)
								Text("Add to")
								Text("call")
							}
							.frame(width: 100, height: 100)
						})
						Spacer()
					}
				}
				.foregroundColor(.white)
			}
		default :
			Text("Error!")
				.onAppear(perform: {
					menu = "main"
					NSLog("Menu was set to a wrong value, setting it to main")
				}
			)
		}
	}
	func numpadButton(number: String, t9chars: String?) -> some View {
		Button(action: {
			linphone.dialToneInCall(tone: number.utf8CString[0])
		}, label: {
			VStack{
				Text(number)
					.font(.largeTitle)
				if t9chars != nil {
					Text(t9chars!)
				}
			}
			.frame(width: 80, height: 80)
		})
	}
	func conferenceButton(number: String, t9chars: String?) -> some View {
		Button(action: {
			linphone.dialTone(tone: number.utf8CString[0])
			displayData += number
		}, label: {
			VStack{
				Text(number)
					.font(.largeTitle)
				if t9chars != nil {
					Text(t9chars!)
				}
			}
			.frame(width: 80, height: 80)
		})
	}
	func transferButton(number: String, t9chars: String?) -> some View {
		Button(action: {
			linphone.dialTone(tone: number.utf8CString[0])
			displayData += number
		}, label: {
			VStack{
				Text(number)
					.font(.largeTitle)
				if t9chars != nil {
					Text(t9chars!)
				}
			}
			.frame(width: 80, height: 80)
		})
	}
}

struct CallMenu_Previews: PreviewProvider {
	static var previews: some View {
		let _ = getVersion()
		Group{
			CallMenu()
				.previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
				.previewDisplayName("iPhone 13 mini")
			CallMenu()
				.previewDevice(PreviewDevice(rawValue: "iPhone 13 mini"))
				.previewDisplayName("iPhone 13 mini")
				.preferredColorScheme(.dark)
			CallMenu()
				.previewDevice(PreviewDevice(rawValue: "iPhone SE (2nd generation)"))
				.previewDisplayName("iPhone SE")
			
			CallMenu()
				.previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
				.previewDisplayName("iPhone 13 Pro Max")
		}
	}
}
