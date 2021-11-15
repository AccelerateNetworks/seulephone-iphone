//
//  CallMenu.swift
//  testbed
//
//  Created by piajesse on 11/12/21.
//

import SwiftUI

struct CallMenu: View {
	@State var menu: String
	var dialedNumbers: String = ""
	var speaker: String = "speaker"
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
					Text("4254997999")
						.font(.title)
					Text(getLinphoneAPI().getTimeOnCall())
					Spacer()
					Group {
						Text(dialedNumbers)
						Spacer()
						Group{
							Spacer()
							HStack{
								Spacer()
								Button(action: {
								}, label: {
									VStack{
										Image(systemName: "mic.fill")
											.resizable()
											.frame(width: 35, height: 50)
										Text("Mute")
									}
									.frame(width: 100, height: 100)
								})
								Spacer()
								Button(action: {
								}, label: {
									VStack{
										Image(systemName: "circle.grid.3x3.fill")
											.resizable()
											.frame(width: 50, height: 50)
										Text("Keypad")
									}
									.frame(width: 100, height: 100)
								})
								Spacer()
								Button(action: {
								}, label: {
									VStack{
										Image(systemName: "speaker")
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
								}, label: {
									VStack{
										Image(systemName: "pause")
											.resizable()
											.frame(width: 25, height: 50)
										Text("Hold")
									}
									.frame(width: 100, height: 100)
								})
								Spacer()
								Button(action: {
								}, label: {
									VStack{
										Image(systemName: "plus")
											.resizable()
											.frame(width: 50, height: 50)
										Text("Conference")
									}
									.frame(width: 100, height: 100)
								})
								
								Spacer()
								Button(action: {
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
		default :
			Text("Error!")
				.onAppear(perform: {
					menu = "dialpad"
					NSLog("Menu was set to a wrong value, setting it to dialpad")
				})
		}
	}
	func dialPadButton(number: String, t9chars: String?) -> some View {
		Button(action: {
		}, label: {
			VStack{
				Text(number)
					.font(.largeTitle)
				if t9chars != nil {
					Text(t9chars!)
				}
			}
			.frame(width: 100, height: 100)
		})
	}
}


struct CallMenu_Previews: PreviewProvider {
	static var previews: some View {
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
