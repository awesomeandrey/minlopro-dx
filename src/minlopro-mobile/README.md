# Salesforce Mobile Experience Summary

## Salesforce Mobile Experience Overview

Salesforce delivers its mobile experience primarily through the dedicated [Salesforce Mobile App](https://help.salesforce.com/s/articleView?id=xcloud.salesforce_app.htm&type=5),
providing access to Salesforce data, standard and custom objects, workflows, push notifications,
and custom functionality on supported iOS and Android devices. On supported iPad devices, users can also access
Salesforce through Lightning Experience in Safari.

> **Note on Obsolete Mobile Web Access:**  
> Accessing a Salesforce organization via a standard mobile web browser is an obsolete and retired approach.
> As detailed in Salesforce Help article [000380219](https://help.salesforce.com/s/articleView?id=000380219&type=1),
> Salesforce retired the legacy mobile browser experience starting in the **Summer ’20 release**.
> Users must install the official downloadable app via the [Apple App Store](https://apps.apple.com/us/app/salesforce/id404249815)
> or [Google Play Store](https://play.google.com/store/apps/details?id=com.salesforce.chatter&hl=en_IE), or use Safari
> on supported iPads.

---

## Options to Debug Salesforce Mobile Experience

### Option 1: Virtual Device with the Salesforce App

Run the Salesforce mobile application on a virtual Android or iOS device using Android Studio or Xcode emulators/simulators.
The setup follows the official Salesforce [Mobile Previews guide](https://developer.salesforce.com/docs/platform/mobile-offline/guide/dx-mobile-previews-salesforce-app.html),
with setup walkthroughs available in this [video guide](https://www.youtube.com/watch?v=3Kd5JMQBgI8).

Preview:
![salesforce-mobile-app-android-emulator.png](../../assets/demo/salesforce-mobile-app/salesforce-mobile-app-android-emulator.png)

### Option 2: BYOD — Bring Your Own Device

Test the Salesforce mobile experience directly on a physical personal or approved mobile device. This approach leverages
existing authentication and passkey configurations already present on the device. Users on macOS and iOS can also
utilize iPhone Mirroring to interact with and display the mobile screen directly on their computer ([video reference](https://www.youtube.com/watch?v=f3REBdDPd58)).
