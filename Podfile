source "https://gitlab.linphone.org/BC/public/podspec.git"
source "https://github.com/CocoaPods/Specs.git"

def basic_pods
	if ENV['PODFILE_PATH'].nil?
		pod 'linphone-sdk', '~> 5.0.0'
		else
		pod 'linphone-sdk', :path => ENV['PODFILE_PATH']  # local sdk
	end	
end

target 'accelnet (iOS)' do
  platform :ios, '11.0'
  pod 'PhoneNumberKit', '~> 3.3'
  pod 'Alamofire', '~> 5.4'
  use_frameworks!
  basic_pods
end

#target 'accelnet (macOS)' do
#  platform :osx, '11.0'
#  use_frameworks!
#  basic_pods
#end
