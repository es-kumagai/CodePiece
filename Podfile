source 'https://github.com/EZ-NET/PodSpecs.git'
source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

def pods

	pod 'Swim', :git => 'https://github.com/EZ-NET/ESSwim', :branch => 'master'
	pod 'Ocean', :git => 'https://github.com/EZ-NET/ESOcean.git', :branch => 'master'
	pod 'ESThread', :git => 'https://github.com/EZ-NET/ESThread.git', :branch => 'master'
	pod 'ESNotification', :git => 'https://github.com/EZ-NET/ESNotification.git', :branch => 'master'
	pod 'APIKit', '>= 1.1.2'
	pod 'Himotoki', '>= 1.5.0'
	pod 'ESGists', :git => 'https://github.com/EZ-NET/ESGists.git'
	pod 'p2.OAuth2'
	pod 'ReachabilitySwift', '~> 2.0'

end

target :CodePiece do

	platform :osx, '10.10'
	use_frameworks!

	pods
	pod 'KeychainAccess', :git => 'https://github.com/kishikawakatsumi/KeychainAccess.git', :branch => 'master'
	pod 'STTwitter', :git => 'https://github.com/EZ-NET/STTwitter.git', :branch => 'FixPostMediaUploadData'

end

target :ESTwitter do

	platform :osx, '10.10'
	use_frameworks!
	
	pod 'Himotoki', '>= 1.5.0'
	pod 'Swim', :git => 'https://github.com/EZ-NET/ESSwim', :branch => 'master'

end
