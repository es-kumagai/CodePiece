source 'https://github.com/EZ-NET/PodSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'CodePiece.xcworkspace'
xcodeproj 'CodePiece.xcodeproj'
xcodeproj '../../Libraries/ESGist/ESGist.xcodeproj'

platform :osx, '10.10'
use_frameworks!

pod 'Ocean', '~> 1.3.13'
pod 'APIKit', :git => 'https://github.com/ishkawa/APIKit.git', :branch => 'master'
pod 'Himotoki', :git => 'https://github.com/ikesyo/Himotoki.git', :branch => 'swift2'

target :CodePiece do

	xcodeproj 'CodePiece.xcodeproj'
	platform :osx, '10.10'
	use_frameworks!
	
	pod 'KeychainAccess', :git => 'https://github.com/kishikawakatsumi/KeychainAccess.git', :branch => 'swift-2.0'
	pod 'STTwitter'
end
