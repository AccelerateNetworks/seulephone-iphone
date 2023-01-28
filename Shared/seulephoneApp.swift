//
//  seulephoneApp.swift
//  Shared
//
//  Created by piajesse on 10/19/21.
//

import SwiftUI

public var linphone: LinphoneAPI = LinphoneAPI()

@main
struct seulephoneApp: App {
	init() {
		let provisioingURL: String = UserDefaults.standard.string(forKey: "ProvisioningURL") ?? "nil"
		let jsonString: String = UserDefaults.standard.string(forKey: "JSONString") ?? "nil"
		if provisioingURL != "nil" {
			if provisioingURL == "manual" {
				let _ = linphone.setupAccounts(provisioningData: jsonString)
			} else {
				let _ = linphone.setupAccounts(provisioningData: provisioingURL)
			}
		}
	}
	var body: some Scene {
		WindowGroup {
			TheView()
		}
	}
}
// Returns the version of the app
public func getVersion() -> String {
	return Bundle.main.releaseVersionNumberPretty
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

extension Bundle {
	var releaseVersionNumber: String? {
		return infoDictionary?["CFBundleShortVersionString"] as? String
	}
	var buildVersionNumber: String? {
		return infoDictionary?["CFBundleVersion"] as? String
	}
	var releaseVersionNumberPretty: String {
		return "v\(releaseVersionNumber ?? "1.0.0")"
	}
}

struct DeviceRotationViewModifier: ViewModifier {
	let action: (UIDeviceOrientation) -> Void
	
	func body(content: Content) -> some View {
		content
			.onAppear()
			.onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
				action(UIDevice.current.orientation)
			}
	}
}

extension View {
	func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
		self.modifier(DeviceRotationViewModifier(action: action))
	}
}
