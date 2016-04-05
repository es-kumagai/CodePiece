source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/EZ-NET/PodSpecs.git'

use_frameworks!

def pods

	pod 'Swim'
	pod 'Ocean'
	pod 'ESThread'
	pod 'ESNotification'
	pod 'APIKit', '>= 1.1.2'
	pod 'Himotoki', '>= 1.5.0'
	pod 'ESGists'
	pod 'p2.OAuth2'
	pod 'ReachabilitySwift', '>= 2.0'

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
	pod 'Swim'

end
