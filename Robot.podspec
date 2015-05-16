Pod::Spec.new do |s|
  s.name         = "Robot"
  s.version      = "0.1.0"
  s.summary      = "An experimental reliable, fast UIKit test driver"

  s.description  = <<-DESC
			An integration test library on UIKit. Easily emulate high-level user interaction through UIKit.

			Unlike KIF, this does not aim to perfectly emulate how users interact with the system. 
			Instead, trying to replicate the same behavior while minimizing the overhead of 
			time-based operations. A perfect example is disabling animations to speed up running of tests.

			Also unlike KIF, Robot does not aim to be a full integration testing solution. Rather, it 
			relies on other testing frameworks to do assertion and running. Besides XCTest, there are 
			some popular BDD frameworks:

				*Cedar
				*Specta / Expecta
				*Kiwi
                   DESC

  s.homepage              = "https://github.com/jeffh/Robot"
  s.license               = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author                = { "Jeff Hui" => "jeff@jeffhui.net" }
  s.platform              = :ios
  s.ios.deployment_target = "8.0"
  s.source                = { :git => "https://github.com/jeffh/robot.git", :tag => "v#{s.version}" }
  s.source_files          = "Robot", "Robot/**/*.{h,m}"
  s.public_header_files   = 'Robot/Public/**/*.h'
  s.requires_arc          = true
  s.frameworks            = 'IOKit'
end
