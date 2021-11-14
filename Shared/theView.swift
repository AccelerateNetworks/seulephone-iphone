//
//  ContentView.swift
//  Shared
//
//  Created by piajesse on 10/19/21.
//

import SwiftUI

struct theView: View {
	@ObservedObject var linphone : LinphoneAPI
	@State private var provisioningData : String
	@State private var agreement : Bool
	@State private var menu: String
	@State var firstLaunch: Bool
	@State private var status: String = "Status Reporting coming Soon™  ⚪️"
	@State var dialedNumber: String = ""
	@State var provisioningURL: String
	@State var jsonConfig: JSONConfig
	
	init(linphoneObject: LinphoneAPI) {
		linphone = linphoneObject
		provisioningData = ""
		agreement = false
		menu = "dialpad"
		provisioningURL =	UserDefaults.standard.string(forKey: "ProvisioningURL") ?? "nil"
		do {
			let jsonString = UserDefaults.standard.string(forKey: "JSONString") ?? "nil"
			jsonConfig = try JSONDecoder().decode(JSONConfig.self, from: (jsonString.data(using: .utf8)!))
			firstLaunch = false
		} catch {
			jsonConfig = JSONConfig(accounts: [JSONConfig.AccountDetails(tenant: "", username: "", password: "")])
			firstLaunch = true
		}
	}
	var body: some View {
		if !firstLaunch {
			if linphone.isCallRunning {
				Text("")
			} else {
				NavigationView {
					ZStack {
						Color("ANBlue")
							.ignoresSafeArea(edges: .top)
							.ignoresSafeArea(edges: .bottom)
						VStack {
							HStack{
								Spacer()
							}
							Spacer()
						}
						.toolbar {
							ToolbarItemGroup(placement: .bottomBar) {
								Spacer()
								Button(action: {
									menu = "history"
								}, label: {
									if menu == "history" {
										Image(systemName: "clock.fill")
									} else {
										Image(systemName: "clock")
									}
								});
								Spacer()
								Button(action: {
									menu = "contacts"
								}, label: {
									if menu == "contacts" {
										Image(systemName: "person.fill")
									} else {
										Image(systemName: "person")
									}
								})
								Spacer()
								Button(action: {
									menu = "dialpad"
								}, label: {
									if menu == "dialpad" {
										Image(systemName: "circle.grid.3x3.fill")
									} else {
										Image(systemName: "circle.grid.3x3")
									}
								})
								Spacer()
								//							Button(action: {
								//							}, label: {
								//								Image(systemName: "text.bubble")
								//							})
								//							Spacer()
							}
						}
						.toolbar {
							ToolbarItem(placement: .principal) {
								HStack(spacing: 0) {
									Button(action: {
										if menu == "settings" {
											menu = "dialpad"
										} else {
											menu = "settings"
										}
									}, label: {
										if menu == "settings" {
											Image(systemName: "gearshape.fill")
										} else {
											Image(systemName: "gearshape")
										}
									})
									Spacer()
									Text(status)
										.font(.headline)
										.foregroundColor(.white)
								}
							}
						}
						Group {
							switch(menu) {
								// MARK: Settings Screen
							case "settings" :
								Group {
									VStack {
										VStack {
											Text("Settings")
												.font(.largeTitle)
												.padding()
											Group {
												List {
													HStack {
														Spacer()
														Text("Accounts")
															.font(.title2)
															.bold()
															.padding()
														Spacer()
													}
													var wasThereAccounts: Bool = false
													ForEach(linphone.getAccounts(), id: \.self) { account in // F*** you apple, `id: \.self` makes no sense, and took me like 4 days to figure out
														NavigationLink(destination: ZStack {
															Color("ANBlue")
																.ignoresSafeArea(edges: .top)
															VStack {
																Text("test")
																	.navigationBarTitleDisplayMode(.inline)
															}
														})
														{
															HStack{
																Text(account + " dets")
																	.padding(16)
																Spacer()
															}
															.onAppear() {
																wasThereAccounts = true
															}
														}
													}
													if !wasThereAccounts {
														HStack {
															Spacer()
															Text("no accounts...")
															Spacer()
														}
													}
													
													Button(action: {
														
													}, label: {
														HStack {
															Spacer()
															Text("Resetup")
															Spacer()
														}
													})
												}
											}
											NavigationLink(destination: {
												
											}, label: {
												
											})
										}
									}
								}
								// MARK: History Screen
							case "history" :
								VStack {
									Spacer()
									HStack(){
										Spacer()
										VStack{
											Text("History feature")
											Text("coming Soon™")
										}
										Spacer()
									}
									Spacer()
								}
								// MARK: Contacts Screen
							case "contacts" :
								VStack {
									Spacer()
									HStack(){
										Spacer()
										VStack{
											Text("Contacts feature")
											Text("coming Soon™")
										}
										Spacer()
									}
									Spacer()
								}
								// MARK: Dialpad Screen
							case "dialpad" :
								VStack{
									HStack{
										if dialedNumber == "" {
											// This is going to be for a paste button
											//								Button(action: {
											//									dialedNumber =
											//								}, label: {
											//									Image(systemName: "arrow.right.doc.on.clipboard")
											//								})
											Text("<425-499-7999>")
												.foregroundColor(.white)
										} else {
											Text(dialedNumber)
												.foregroundColor(.defaultForeground)
											
										}
										Spacer()
										Button(action: {
											dialedNumber = String(dialedNumber.dropLast())
										}, label: {
											Image(systemName: "delete.left")
										})
									}
									.padding()
									.background(Color("ANOrange"))
									Group {
										Spacer()
										HStack {
											Spacer()
											Button(action: {
												//play button press sound?
												dialedNumber = dialedNumber + "1"
											}, label: {
												VStack{
													Text("1")
														.font(.largeTitle)
													Image(systemName: "recordingtape")
												}
												.frame(width: 80, height: 80)
											})
											Spacer()
											dialPadButton(number: "2", t9chars: "ABC")
											Spacer()
											dialPadButton(number: "3", t9chars: "DEF")
											Spacer()
										}
										Spacer()
										HStack {
											Spacer()
											dialPadButton(number: "4", t9chars: "GHI")
											Spacer()
											dialPadButton(number: "5", t9chars: "JKL")
											Spacer()
											dialPadButton(number: "6", t9chars: "MNO")
											Spacer()
										}
										Spacer()
										HStack {
											Spacer()
											dialPadButton(number: "7", t9chars: "PQRS")
											Spacer()
											dialPadButton(number: "8", t9chars: "TUV")
											Spacer()
											dialPadButton(number: "9", t9chars: "WXYZ")
											Spacer()
										}
										Spacer()
										HStack {
											Spacer()
											Button(action: {
												//play button press sound?
												dialedNumber = dialedNumber + "*"
											}, label: {
												VStack{
													Image(systemName: "staroflife.fill")
												}
												.frame(width: 80, height: 80)
											})
											Spacer()
											dialPadButton(number: "0", t9chars: "+")
											Spacer()
											dialPadButton(number: "#", t9chars: nil)
											Spacer()
										}
									}.foregroundColor(Color("ANBlue"))
									Spacer()
									
									Group{
										HStack{
											Spacer()
												.frame(width: 8)
											Button(action: {
												linphone.callNumber(numberToDial: dialedNumber)
											}, label: {
												HStack{
													Spacer()
													Image(systemName: "phone.fill")
														.resizable()
														.frame(width: 40, height: 40)
														.padding(8)
													Spacer()
												}
												.background(Color.green)
											}).cornerRadius(20)
											Spacer()
												.frame(width: 8)
										}
									}
									Spacer()
										.frame(height: 8)
									
								}
								// MARK: Messages Screen
							case "messages" :
								Text("Messages aren't setup yet")
									.onAppear(perform: {
										menu = "dialpad"
										NSLog("Menu was set to messages which has not been setup yet, setting it to dialpad")
									})
							default :
								Text("Error!")
									.onAppear(perform: {
										menu = "dialpad"
										NSLog("Menu was set to a wrong value, setting it to dialpad")
									})
							}
						}
						.background(Color.defaultBackground)
						.navigationBarTitleDisplayMode(.inline)
					}
				}
			}
		} else {
			// MARK: Welcome Screen
			NavigationView {
				ZStack {
					Color("ANBlue")
						.ignoresSafeArea(edges: .top)
					VStack {
						ScrollView{
							Text("Welcome to the Accelerate Networks app, check your email for details on setting up this device, or enter the provisioning info below")
								.multilineTextAlignment(.center)
								.padding()
							Spacer().frame(height: 50)
							Text("Provision URL")
							TextField("https://domain.to.config", text: $provisioningData)
								.textFieldStyle(RoundedBorderTextFieldStyle())
								.keyboardType(.URL).autocapitalization(.none)
								.disableAutocorrection(.none)
								.padding()
							Button(action: {
								firstLaunch = !linphone.setupAccounts(provisioningData: provisioningData)
							}, label: {
								Text("Apply").padding()
									.background(RoundedRectangle(cornerRadius: 10)
									.stroke(lineWidth: 2))
									.foregroundColor(Color("ANBlue"))
							})
							Spacer().frame(height: 10)
							Button(action: { //Need QR code reader here
							}, label: {
								Text("QR Reader")
									.padding()
									.background(RoundedRectangle(cornerRadius: 10)
									.stroke(lineWidth: 2))
									.foregroundColor(Color("ANBlue"))
							})
						}
						Spacer()
						NavigationLink(destination: ZStack {
							Color("ANBlue")
								.ignoresSafeArea(edges: .top)
							VStack {
								
								Group {
									Spacer()
									Text("If you find any bugs or would like to request a feature, please tell us via email at feedback@acceleratenetworks.com")
										.accentColor(.blue)
										.multilineTextAlignment(.center)
										.padding()
										.frame(width: 400)
									Text("or")
									Button(action: {
										
									}, label: {
										Text("Send Logs")
											.padding()
											.foregroundColor(.blue)
											.background(RoundedRectangle(cornerRadius: 10)
																		.stroke(lineWidth: 2))
									})
									Spacer().frame(height: 64)
									Text("©2021 Accelerate Networks v" + getVersion())
									Spacer().frame(width: 10000, height: 20)
									Text("This app uses LinphoneSDK v" + LinphoneAPI().getVersion())
									Spacer().frame(height: 200)
								}
								.navigationBarTitleDisplayMode(.inline)
								.toolbar {
									ToolbarItem(placement: .principal) {
										HStack {
											Text("About")
												.font(.largeTitle)
												.foregroundColor(.white)
										}
									}
								}

								
							}.background(Color.defaultBackground)
						})
						{
							Text("About")
						}.foregroundColor(Color.defaultForeground)
						Spacer().frame(height: 20)
					}
						.background(Color.defaultBackground)
						.navigationBarTitleDisplayMode(.inline)
						.toolbar {
							ToolbarItem(placement: .principal) {
								HStack {
									Text("Welcome")
										.font(.largeTitle)
										.foregroundColor(.white)
								}
							}
						}
				}
			}
		}
	}
	func dialPadButton(number: String, t9chars: String?) -> some View {
		Button(action: {
			//play button press sound?
			dialedNumber = dialedNumber + number
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

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		if #available(iOS 15.0, *) {
			theView(linphoneObject: LinphoneAPI())
//				.colorScheme(.dark)
				.previewInterfaceOrientation(.portrait)
		} else {
			// Fallback on earlier versions
		}
	}
}
