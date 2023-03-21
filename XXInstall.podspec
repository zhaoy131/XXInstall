#
#  Be sure to run `pod spec lint XXInstall.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
#
#  These will help people to find your library, and whilst it
#  can feel like a chore to fill in it's definitely to your advantage. The
#  summary should be tweet-length, and the description more in depth.
#

spec.name         = "XXInstall"
spec.version      = "0.0.1"
spec.summary      = "统计SDK"

spec.description  = "该SDK作为统计渠道使用"

spec.homepage     = "https://github.com/zhaoy131/XXInstall"

spec.license      = "MIT"

spec.author             = { "zhaoyu" => "zdy_ios@163.com" }

spec.source       = { :git => "https://github.com/zhaoy131/XXInstall.git", :tag => "#{spec.version}" }

spec.ios.deployment_target = "9.0"

spec.ios.vendored_frameworks = 'XXInstall/XXInstall.framework'
spec.pod_target_xcconfig = {
'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
}
spec.user_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64'
}

# spec.source_files  = "XXInstall/"
# spec.exclude_files = "Classes/Exclude"

# spec.public_header_files = "Classes/**/*.h"

# spec.resource  = "icon.png"
# spec.resources = "Resources/*.png"

# spec.preserve_paths = "FilesToSave", "MoreFilesToSave"

spec.requires_arc = true

spec.dependency 'Starscream', '~> 4.0.4'

end
