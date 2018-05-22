app_id=${1:-`whoami`.opentube}
echo Using APPID of $app_id, you can customize using ./setup.sh org.foo.myapp

echo CUSTOM_BUNDLE_ID=$app_id > OpenTube/Application/Config/local.xcconfig
echo "Please edit penTube/Application/Config/local.xcconfig to add your DEVELOPMENT_TEAM id (or else you will need to set this in Xcode)"
echo "  It is found here: https://developer.apple.com/account/#/membership"
echo "// DEVELOPMENT_TEAM=" >> OpenTube/Application/Config/local.xcconfig
