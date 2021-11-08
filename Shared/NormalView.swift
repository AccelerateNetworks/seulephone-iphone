//
//  NormalView.swift
//  accelnet
//
//  Created by piajesse on 10/20/21.
//

import SwiftUI
import linphonesw

struct NormalView: View {
	@State private var menu: String = "dailpad"
	@State private var status: String = "Loading Status...  ⚪️"
	@State var dialedNumber: String = ""
	
	var body: some View {
		
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
											if LinphoneAPI().getSetupStatus() {
												ForEach(LinphoneAPI().getAccounts(), id: \.self) { account in // F*** you apple, `id: \.self` makes no sense, and took me like 4 days to figure out
													NavigationLink(destination: ZStack {
														Color("ANBlue")
															.ignoresSafeArea(edges: .top)
														VStack {
															Text(account)
																.navigationBarTitleDisplayMode(.inline)
														}
													})
													{
														HStack{
															Text(account + " dets")
																.padding(16)
															Spacer()
														}
													}
												}
											} else {
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
							HStack(){
								Spacer()
								Text("")
							}
							Spacer()
						}
						// MARK: Contacts Screen
					case "contacts" :
						VStack {
							HStack(){
								Spacer()
								Text("")
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
										//TODO dial out
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

struct NormalView_Previews: PreviewProvider {
	static var previews: some View {
		if #available(iOS 15.0, *) {
			NormalView()
			//				.colorScheme(.dark)
				.previewInterfaceOrientation(.portrait)
		} else {
			NormalView()
		}
	}
}

