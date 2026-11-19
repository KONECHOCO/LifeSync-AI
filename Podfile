platform :ios, '17.0'

project 'LifeSyncAI.xcodeproj'

target 'LifeSyncAI' do
  use_frameworks!

  # AdMob (stesse versioni delle altre app Ikonet: OmniTransit, FuelSaver)
  pod 'Google-Mobile-Ads-SDK', '13.6.0'
  pod 'GoogleUserMessagingPlatform', '~> 3.1'
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '17.0'
    end
  end
end
