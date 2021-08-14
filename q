[33mcommit 3f43a8b9a34586fce6b3ab6dfcc1fc775998617e[m[33m ([m[1;31morigin/gh/pbelevich/149/base[m[33m)[m
Author: Hanton Yang <hantonyang@fb.com>
Date:   Fri Aug 13 16:20:22 2021 -0700

    [iOS] Add `LibTorch-Lite-Nightly` pod (#63239)
    
    Summary:
    D30090760 (https://github.com/pytorch/pytorch/commit/e182b459d94fe77c1d9f623c94fc2621c8cc55de) was reverted by D30303292 because of a lint issue in `LibTorch-Lite-Nightly.podspec.template`. Resubmit the diff after fixing the issue.
    
    Pull Request resolved: https://github.com/pytorch/pytorch/pull/63239
    
    Test Plan: Imported from OSS
    
    Reviewed By: xta0
    
    Differential Revision: D30315690
    
    Pulled By: hanton
    
    fbshipit-source-id: f0fa719ffc3b8181ab28c123584ae5c1da8992c0

[1mdiff --git a/.circleci/scripts/binary_ios_test.sh b/.circleci/scripts/binary_ios_test.sh[m
[1mindex 7038b89390..5280b62a4e 100644[m
[1m--- a/.circleci/scripts/binary_ios_test.sh[m
[1m+++ b/.circleci/scripts/binary_ios_test.sh[m
[36m@@ -26,4 +26,4 @@[m [mif ! [ -x "$(command -v xcodebuild)" ]; then[m
     exit 1[m
 fi[m
 PROFILE=PyTorch_CI_2021[m
[31m-ruby ${PROJ_ROOT}/scripts/xcode_build.rb -i ${PROJ_ROOT}/build_ios/install -x ${PROJ_ROOT}/ios/TestApp/TestApp.xcodeproj -p ${IOS_PLATFORM} -c ${PROFILE} -t ${IOS_DEV_TEAM_ID} -f Accelerate,MetalPerformanceShaders[m
[32m+[m[32mruby ${PROJ_ROOT}/scripts/xcode_build.rb -i ${PROJ_ROOT}/build_ios/install -x ${PROJ_ROOT}/ios/TestApp/TestApp.xcodeproj -p ${IOS_PLATFORM} -c ${PROFILE} -t ${IOS_DEV_TEAM_ID} -f Accelerate,MetalPerformanceShaders,CoreML[m
[1mdiff --git a/.circleci/scripts/binary_ios_upload.sh b/.circleci/scripts/binary_ios_upload.sh[m
[1mindex c4d4475064..b0b0fe146b 100644[m
[1m--- a/.circleci/scripts/binary_ios_upload.sh[m
[1m+++ b/.circleci/scripts/binary_ios_upload.sh[m
[36m@@ -28,12 +28,13 @@[m [mcp ${PROJ_ROOT}/ios/LibTorch-Lite.h ${ZIP_DIR}/src/[m
 cp ${PROJ_ROOT}/LICENSE ${ZIP_DIR}/[m
 # zip the library[m
 export DATE="$(date -u +%Y%m%d)"[m
[31m-# libtorch_lite_ios_nightly_1.10.0dev20210810.zip[m
[31m-ZIPFILE="libtorch_lite_ios_nightly_1.10.0.dev$DATE.zip"[m
[32m+[m[32mexport IOS_NIGHTLY_BUILD_VERSION="1.10.0.${DATE}"[m
[32m+[m[32m# libtorch_lite_ios_nightly_1.10.0.20210810.zip[m
[32m+[m[32mZIPFILE="libtorch_lite_ios_nightly_${IOS_NIGHTLY_BUILD_VERSION}.zip"[m
 cd ${ZIP_DIR}[m
 #for testing[m
 touch version.txt[m
[31m-echo "$DATE" > version.txt[m
[32m+[m[32mecho "${IOS_NIGHTLY_BUILD_VERSION}" > version.txt[m
 zip -r ${ZIPFILE} install src version.txt LICENSE[m
 # upload to aws[m
 # Install conda then 'conda install' awscli[m
[36m@@ -50,3 +51,14 @@[m [mset +x[m
 # echo "AWS KEY: ${AWS_ACCESS_KEY_ID}"[m
 # echo "AWS SECRET: ${AWS_SECRET_ACCESS_KEY}"[m
 aws s3 cp ${ZIPFILE} s3://ossci-ios-build/ --acl public-read[m
[32m+[m
[32m+[m[32m# create a new LibTorch-Lite-Nightly.podspec from the template[m
[32m+[m[32mecho "cp ${PROJ_ROOT}/ios/LibTorch-Lite-Nightly.podspec.template ${PROJ_ROOT}/ios/LibTorch-Lite-Nightly.podspec"[m
[32m+[m[32mcp ${PROJ_ROOT}/ios/LibTorch-Lite-Nightly.podspec.template ${PROJ_ROOT}/ios/LibTorch-Lite-Nightly.podspec[m
[32m+[m
[32m+[m[32m# update pod version[m
[32m+[m[32msed -i '' -e "s/IOS_NIGHTLY_BUILD_VERSION/${IOS_NIGHTLY_BUILD_VERSION}/g" ${PROJ_ROOT}/ios/LibTorch-Lite-Nightly.podspec[m
[32m+[m[32mcat ${PROJ_ROOT}/ios/LibTorch-Lite-Nightly.podspec[m
[32m+[m
[32m+[m[32m# push the new LibTorch-Lite-Nightly.podspec to CocoaPods[m
[32m+[m[32mpod trunk push --verbose --allow-warnings --use-libraries --skip-import-validation ${PROJ_ROOT}/ios/LibTorch-Lite-Nightly.podspec[m
[1mdiff --git a/ios/LibTorch-Lite-Nightly.podspec.template b/ios/LibTorch-Lite-Nightly.podspec.template[m
[1mnew file mode 100644[m
[1mindex 0000000000..dc99c9ee70[m
[1m--- /dev/null[m
[1m+++ b/ios/LibTorch-Lite-Nightly.podspec.template[m
[36m@@ -0,0 +1,37 @@[m
[32m+[m[32mPod::Spec.new do |s|[m
[32m+[m[32m    s.name             = 'LibTorch-Lite-Nightly'[m
[32m+[m[32m    s.version          = 'IOS_NIGHTLY_BUILD_VERSION'[m
[32m+[m[32m    s.authors          = 'PyTorch Team'[m
[32m+[m[32m    s.license          = { :type => 'BSD' }[m
[32m+[m[32m    s.homepage         = 'https://github.com/pytorch/pytorch'[m
[32m+[m[32m    s.source           = { :http => "https://ossci-ios-build.s3.amazonaws.com/libtorch_lite_ios_nightly_#{s.version}.zip" }[m
[32m+[m[32m    s.summary          = 'The nightly build version of PyTorch C++ library for iOS'[m
[32m+[m[32m    s.description      = <<-DESC[m
[32m+[m[32m        The nightly build version of PyTorch C++ library for iOS.[m
[32m+[m[32m    DESC[m
[32m+[m[32m    s.ios.deployment_target = '12.0'[m
[32m+[m[32m    s.default_subspec = 'Core'[m
[32m+[m[32m    s.subspec 'Core' do |ss|[m
[32m+[m[32m        ss.dependency 'LibTorch-Lite-Nightly/Torch'[m
[32m+[m[32m        ss.source_files = 'src/*.{h,cpp,c,cc}'[m
[32m+[m[32m        ss.public_header_files = ['src/LibTorch-Lite.h'][m
[32m+[m[32m    end[m
[32m+[m[32m    s.subspec 'Torch' do |ss|[m
[32m+[m[32m        ss.header_mappings_dir = 'install/include/'[m
[32m+[m[32m        ss.preserve_paths = 'install/include/**/*.{h,cpp,cc,c}'[m
[32m+[m[32m        ss.vendored_libraries = 'install/lib/*.a'[m
[32m+[m[32m        ss.libraries = ['c++', 'stdc++'][m
[32m+[m[32m    end[m
[32m+[m[32m    s.user_target_xcconfig = {[m
[32m+[m[32m        'HEADER_SEARCH_PATHS' => '$(inherited) "$(PODS_ROOT)/LibTorch-Lite-Nightly/install/include/"',[m
[32m+[m[32m        'OTHER_LDFLAGS' => '-force_load "$(PODS_ROOT)/LibTorch-Lite-Nightly/install/lib/libtorch.a" -force_load "$(PODS_ROOT)/LibTorch-Lite-Nightly/install/lib/libtorch_cpu.a"',[m
[32m+[m[32m        'CLANG_CXX_LANGUAGE_STANDARD' => 'c++14',[m
[32m+[m[32m        'CLANG_CXX_LIBRARY' => 'libc++'[m
[32m+[m[32m    }[m
[32m+[m[32m    s.pod_target_xcconfig = {[m
[32m+[m[32m        'HEADER_SEARCH_PATHS' => '$(inherited) "$(PODS_ROOT)/LibTorch-Lite-Nightly/install/include/"',[m
[32m+[m[32m        'VALID_ARCHS' => 'x86_64 arm64'[m
[32m+[m[32m    }[m
[32m+[m[32m    s.library = ['c++', 'stdc++'][m
[32m+[m[32m    s.frameworks = 'Accelerate', 'MetalPerformanceShaders', 'CoreML'[m
[32m+[m[32mend[m
