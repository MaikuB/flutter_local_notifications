#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint flutter_local_notifications.podspec' to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'flutter_local_notifications'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for displaying local notifications.'
  s.description      = <<-DESC
Flutter plugin for displaying local notifications.
                       DESC
  s.homepage         = 'https://github.com/MaikuB/flutter_local_notifications/tree/master/flutter_local_notifications'
  s.license          = { :type => 'BSD', :file => '../LICENSE' }
  s.author           = { 'Michael Bui' => 'borromini_eeckhout@simplelogin.com' }
  s.source           = { :path => '.' }
  s.source_files = 'flutter_local_notifications/Sources/flutter_local_notifications/**/*.swift'
  s.dependency 'FlutterMacOS'

  s.platform = :osx, '10.14'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.resource_bundles = {'flutter_local_notifications_privacy' => ['flutter_local_notifications/Sources/flutter_local_notifications/PrivacyInfo.xcprivacy']}
  s.swift_version = '5.0'
end
