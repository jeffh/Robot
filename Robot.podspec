#  Be sure to run `pod spec lint Robot.podspec' to ensure this is a

Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  s.name         = "Robot"
  s.version      = "0.0.1"
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

  s.homepage     = "https://github.com/jeffh/Robot"
  s.author             = { "Jeff H" => "jeff@jeffhui.net" }
  s.platform     = :ios
  s.ios.deployment_target = "7.1"
  s.source       = { :git => "https://github.com/jeffh/robot.git", :commit => "3efdcd47a156260abf920dcc24669e6cb2b989e8" }
  s.source_files  = "Robot", "Robot/**/*.{h,m}"

end
