//
//  NormalView.swift
//  accelnet
//
//  Created by piajesse on 10/20/21.
//

import SwiftUI
import linphonesw

struct NormalView: View {
	@State private var menu: String = "settings"
	@State private var status: String = "Loading Status...  ⚪️"
	@State var dialedNumber: String = ""
	
	var body: some View {
		switch(menu) {
		// MARK: Settings Screen
		case "settings" :
			NavigationView {
				ZStack {
					Color("ANBlue")
						.ignoresSafeArea(edges: .top)
						.ignoresSafeArea(edges: .bottom)
					Group {
						VStack {
							VStack {
								Text("Accounts")
									.font(.title)
									.padding()
								if LinphoneAPI().getSetupStatus() {
									Group {
										List {
											ForEach(LinphoneAPI().getAccounts()) { account in
												NavigationLink(destination: ZStack {
													Color("ANBlue")
														.ignoresSafeArea(edges: .top)
													VStack {
														Text("")
															.navigationBarTitleDisplayMode(.inline)
													}
												})
												{
													HStack{
														Text("Account" + "dets")
															.padding(16)
														Spacer()
													}
												}
											}
										}
									}
								}
								NavigationLink(destination: {
									
								}, label: {
									
								})
							}
							.foregroundColor(.defaultForeground)
							.background(Color.defaultBackground)
							.cornerRadius(20)
							.padding(8)
							Spacer()
						}
					}
					.toolbar {
						ToolbarItem(placement: .principal) {
							HStack(spacing: 0) {
								Button(action: {
									
								}, label: {
									Image(systemName: "gearshape.fill")
								})
								Spacer()
								Text(status)
									.font(.headline)
									.foregroundColor(.white)
							}
						}
					}
					.navigationBarTitleDisplayMode(.inline)
				}
			}
		// MARK: History Screen
		case "history" :
			NavigationView {
				ZStack {
					Color("ANBlue")
						.ignoresSafeArea(edges: .top)
						.ignoresSafeArea(edges: .bottom)
					VStack {
						HStack(){
							Spacer()
							Text("")
						}
						Spacer()
					}
					.background(Color.defaultBackground)
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItemGroup(placement: .bottomBar) {
							Spacer()
							Button(action: {
							}, label: {
								Image(systemName: "clock.fill")
							});
							Spacer()
							Button(action: {
							}, label: {
								Image(systemName: "person")
							})
							Spacer()
							Button(action: {
								menu = "dialpad"
							}, label: {
								Image(systemName: "circle.grid.3x3")
							})
							Spacer()
							//							Button(action: {
							//							}, label: {
							//								Image(systemName: "text.bubble")
							//							})
							//							Spacer()
							//							Button(action: {
							//							}, label: {
							//								Image(systemName: "gearshape")
							//							})
							//							Spacer()
						}
					}
					.toolbar {
						ToolbarItem(placement: .principal) {
							HStack {
								Text(status)
									.font(.headline)
									.foregroundColor(.white)
								Spacer()
							}
						}
					}
				}
			}
		// MARK: Contacts Screen
		case "contacts" :
			NavigationView {
				ZStack {
					Color("ANBlue")
						.ignoresSafeArea(edges: .top)
						.ignoresSafeArea(edges: .bottom)
					VStack {Spacer()
					}
					.background(Color.defaultBackground)
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItemGroup(placement: .bottomBar) {
							Spacer()
							Button(action: {
							}, label: {
								Image(systemName: "clock")
							});
							Spacer()
							Button(action: {
							}, label: {
								Image(systemName: "person")
							})
							Spacer()
							Button(action: {
							}, label: {
								Image(systemName: "circle.grid.3x3.fill")
							})
							Spacer()
							//							Button(action: {
							//							}, label: {
							//								Image(systemName: "text.bubble")
							//							})
							//							Spacer()
							//							Button(action: {
							//							}, label: {
							//								Image(systemName: "gearshape")
							//							})
							//							Spacer()
						}
					}
					.toolbar {
						ToolbarItem(placement: .principal) {
							HStack {
								Text(status)
									.font(.headline)
									.foregroundColor(.white)
								Spacer()
							}
						}
					}
				}
			}
		// MARK: Dialpad Screen
		case "dialpad" :
			NavigationView {
				ZStack {
					Color("ANBlue")
						.ignoresSafeArea(edges: .top)
						.ignoresSafeArea(edges: .bottom)
					VStack() {
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
								Button(action: {
									//play button press sound?
									dialedNumber = dialedNumber + "2"
								}, label: {
									VStack{
										Text("2")
											.font(.largeTitle)
										Text("ABC")
									}
									.frame(width: 80, height: 80)
										
								})
								Spacer()
								Button(action: {
									//play button press sound?
									dialedNumber = dialedNumber + "3"
								}, label: {
									VStack{
										Text("3")
											.font(.largeTitle)
										Text("DEF")
									}
									.frame(width: 80, height: 80)
								})
								Spacer()
							}
							Spacer()
							HStack {
								Spacer()
								Button(action: {
									//play button press sound?
									dialedNumber = dialedNumber + "4"
								}, label: {
									VStack{
										Text("4")
											.font(.largeTitle)
										Text("GHI")
									}
									.frame(width: 80, height: 80)
								})
								Spacer()
								Button(action: {
									//play button press sound?
									dialedNumber = dialedNumber + "5"
								}, label: {
									VStack{
										Text("5")
											.font(.largeTitle)
										Text("JKL")
									}
									.frame(width: 80, height: 80)
								})
								Spacer()
								Button(action: {
									//play button press sound?
									dialedNumber = dialedNumber + "6"
								}, label: {
									VStack{
										Text("6")
											.font(.largeTitle)
										Text("MNO")
									}
									.frame(width: 80, height: 80)
								})
								Spacer()
							}
							Spacer()
							HStack {
								Spacer()
								Button(action: {
									//play button press sound?
									dialedNumber = dialedNumber + "7"
								}, label: {
									VStack{
										Text("7")
											.font(.largeTitle)
										Text("PQRS")
									}
									.frame(width: 80, height: 80)
								})
								Spacer()
								Button(action: {
									//play button press sound?
									dialedNumber = dialedNumber + "8"
								}, label: {
									VStack{
										Text("8")
											.font(.largeTitle)
										Text("TUV")
									}
									.frame(width: 80, height: 80)
								})
								Spacer()
								Button(action: {
									//play button press sound?
									dialedNumber = dialedNumber + "9"
								}, label: {
									VStack{
										Text("9")
											.font(.largeTitle)
										Text("WXYZ")
									}
									.frame(width: 80, height: 80)
								})
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
								Button(action: {
									//play button press sound?
									dialedNumber = dialedNumber + "0"
								}, label: {
									VStack{
										Text("0")
											.font(.largeTitle)
										Text("+")
									}
									.frame(width: 80, height: 80)
								})
								Spacer()
								Button(action: {
									//play button press sound?
									dialedNumber = dialedNumber + "#"
								}, label: {
									VStack{
										Text("#")
											.font(.largeTitle)
									}
									.frame(width: 80, height: 80)
								})
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
					.background(Color.defaultBackground)
					.navigationBarTitleDisplayMode(.inline)
					.toolbar {
						ToolbarItemGroup(placement: .bottomBar) {
							Spacer()
							Button(action: {
								menu = "history"
							}, label: {
								Image(systemName: "clock")
							});
							Spacer()
							Button(action: {
							}, label: {
								Image(systemName: "person")
							})
							Spacer()
							Button(action: {
							}, label: {
								Image(systemName: "circle.grid.3x3.fill")
							})
							Spacer()
							//							Button(action: {
							//							}, label: {
							//								Image(systemName: "text.bubble")
							//							})
							//							Spacer()
							//							Button(action: {
							//							}, label: {
							//								Image(systemName: "gearshape")
							//							})
							//							Spacer()
						}
					}
					.toolbar {
						ToolbarItem(placement: .principal) {
							HStack(spacing: 0) {
								Button(action: {
									
								}, label: {
									Image(systemName: "gearshape")
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
		// MARK: Messages Screen
		case "messages" :
			NavigationView {
				
			}
		default :
			Text("Error!")
				.onAppear(perform: {
					menu = "dialpad"
					NSLog("Menu was set to a wrong value, setting it to dialpad")
				})
		}
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


