//
//  ContentView.swift
//  Shared
//
//  Created by piajesse on 10/19/21.
//

import SwiftUI
import linphonesw


struct theView: View {
	@ObservedObject var linphone : LinphoneAPI
	@State private var provisioningData : String
	@State private var agreement : Bool
	@State private var menu: String
	@State private var firstLaunch: Bool
	
	init() {
		linphone = LinphoneAPI()
		provisioningData = ""
		agreement = false
		menu = "dialpad"
		firstLaunch = false
	}
	var body: some View {
		if firstLaunch {
			NavigationView {
				ZStack {
					Color("ANBlue")
						.ignoresSafeArea(edges: .top)
					VStack {
						
					}
				}
			}
		} else {
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
								firstLaunch = LinphoneAPI().setupAccounts(provisioningData: provisioningData)
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
}

struct ContentView_Previews: PreviewProvider {
	static var previews: some View {
		if #available(iOS 15.0, *) {
			theView()
//				.colorScheme(.dark)
				.previewInterfaceOrientation(.portrait)
		} else {
			// Fallback on earlier versions
		}
	}
}

