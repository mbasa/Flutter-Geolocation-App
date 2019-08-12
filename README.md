# Flutter Geolocation App

A Flutter application with GeoLocation and MapView. This sample 
application was created to test the GPS accuracy of hand held device
while in a bus. 

### Android Permission Setup

Add the following to android/app/src/AndroidManifest.xml

    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    
### IOS Permission Setup

Add the following to ios/Runner/Info.plist

    <key>NSLocationWhenInUseUsageDescription</key>
    </key>NSLocationAlwaysUsageDescription</key>

### To Run in XCode for iPad installation

    Double click on ios/Runner.xcworkspace
