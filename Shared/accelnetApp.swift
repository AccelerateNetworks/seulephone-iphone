//
//  accelnetApp.swift
//  Shared
//
//  Created by piajesse on 10/19/21.
//

import SwiftUI

var version: String = "0.1"
public var linphone: LinphoneAPI = LinphoneAPI()

@main
struct accelnetApp: App {
	var body: some Scene {
		WindowGroup {
			let provisioingURL: String = UserDefaults.standard.string(forKey: "ProvisioningURL") ?? "nil"
			let jsonString: String = UserDefaults.standard.string(forKey: "JSONString") ?? "nil"
			if provisioingURL != "nil" {
				if provisioingURL == "manual" {
					let _ = linphone.setupAccounts(provisioningData: jsonString)
				} else {
					let _ = linphone.setupAccounts(provisioningData: provisioingURL)
				}
			}
			TheView()
		}
	}
}
// Returns an array with [(Version of the app), (Version of the SDK)]
public func getVersion() -> String {
	return version
}
extension UIColor {
	convenience init(light: UIColor, dark: UIColor) {
		self.init { traitCollection in
			switch traitCollection.userInterfaceStyle {
			case .light, .unspecified:
				return light
			case .dark:
				return dark
			@unknown default:
				return light
			}
		}
	}
}

// Returns the LinphoneSDK api Interface
public func getLinphoneAPI() -> LinphoneAPI {
	return linphone
}
extension Color {
	init(light: Color, dark: Color) {
		self.init(UIColor(light: UIColor(light), dark: UIColor(dark)))
	}
	static let defaultBackground = Color(light: .white, dark: .black)
	static let defaultForeground = Color(light: .black, dark: .white)
}

extension String {
	var isValidURL: Bool {
		let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
		if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
			// it is a link, if the match covers the whole string
			return match.range.length == self.utf16.count
		} else {
			return false
		}
	}
}
// From https://stackoverflow.com/questions/56505528/swiftui-update-navigation-bar-title-color
struct NavigationConfigurator: UIViewControllerRepresentable {
	var configure: (UINavigationController) -> Void = { _ in }
	
	func makeUIViewController(context: UIViewControllerRepresentableContext<NavigationConfigurator>) -> UIViewController {
		UIViewController()
	}
	func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<NavigationConfigurator>) {
		if let nc = uiViewController.navigationController {
			self.configure(nc)
		}
	}
	
}
