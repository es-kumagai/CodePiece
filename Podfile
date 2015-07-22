source 'ssh://git@rc.sv.ez-net.ne.jp:2246/tomohiro/espods.git'
source 'https://github.com/CocoaPods/Specs.git'

workspace 'CodePiece.xcworkspace'
xcodeproj 'CodePiece.xcodeproj'
xcodeproj '../../Libraries/ESGist/ESGist.xcodeproj'

use_frameworks!

pod 'Ocean', '~> 1.3.9'
pod 'APIKit', :git => 'https://github.com/ishkawa/APIKit.git', :branch => 'master'
pod 'Himotoki', :git => 'https://github.com/ikesyo/Himotoki.git', :branch => 'swift2'

target :CodePiece do

	xcodeproj 'CodePiece.xcodeproj'
	platform :osx, '10.10'
	use_frameworks!

	pod 'KeychainAccess', :git => 'https://github.com/kishikawakatsumi/KeychainAccess.git', :branch => 'swift-2.0'
	pod 'STTwitter'

end

#target :ESGist_iOS do
#	
#	xcodeproj '../../Libraries/ESGist/ESGist.xcodeproj'
#	platform :ios, '9.0'
#	use_frameworks!
#	
##	pod 'Ocean', '~> 1.3.9'
##	pod 'APIKit', :git => APIKitGit, :branch => APIKitBranch
##	pod 'Himotoki', :git => HimotokiGit, :branch => HimotokiBranch
#
#end
#
#target :ESGist_OSX do
#	
#	xcodeproj '../../Libraries/ESGist/ESGist.xcodeproj'
#	platform :osx, '10.10'
#	use_frameworks!
#	
##	pod 'Ocean', '~> 1.3.9'
##	pod 'APIKit', :git => APIKitGit, :branch => APIKitBranch
##	pod 'Himotoki', :git => HimotokiGit, :branch => HimotokiBranch
#
#end
#
#target :ESGist_iOSTests do
#	
#	xcodeproj '../../Libraries/ESGist/ESGist.xcodeproj'
#	platform :ios, '9.0'
#	use_frameworks!
#	
##	pod 'Ocean', '~> 1.3.9'
##	pod 'APIKit', :git => APIKitGit, :branch => APIKitBranch
##	pod 'Himotoki', :git => HimotokiGit, :branch => HimotokiBranch
#
#end
#
#target :ESGist_OSXTests do
#	
#	xcodeproj '../../Libraries/ESGist/ESGist.xcodeproj'
#	platform :osx, '10.10'
#	use_frameworks!
#	
##	pod 'Ocean', '~> 1.3.9'
##	pod 'APIKit', :git => APIKitGit, :branch => APIKitBranch
##	pod 'Himotoki', :git => HimotokiGit, :branch => HimotokiBranch
#
#end
#
#
#target :ESGistTestApp do
#	
#	xcodeproj '../../Libraries/ESGist/ESGist.xcodeproj'
#	platform :ios, '9.0'
#	use_frameworks!
#	
#end
