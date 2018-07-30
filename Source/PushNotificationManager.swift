//
//  PushNotificationClass.swift
//  SamplePush
//
//  Created by Ketaki Damale on 18/04/18.
//  Copyright © 2018 Ketaki Damale. All rights reserved.
//

import UIKit
import UserNotifications

//MARK: Category
enum category {
  case text
  case attachment
  case action
}


//MARK: Push Notification Manager
class PushManager:NSObject
{
    //:Class Variable Declaration:
    public var token: String? = nil
    public var isGranted: Bool = false
    static let shared = PushManager()
    private var registerObject: Register!
    private var receiveObject: [Receive?] = []
    private var appDelegate = UIApplication.shared.delegate as! AppDelegate
    private var notificationCenter: UNUserNotificationCenter = UNUserNotificationCenter.current()

    private override init() {
      notificationCenter.delegate = appDelegate
    }
    //:Typlealias
    typealias Register = (_ isgranted: Bool,_ token: String?, _ error: Error?) -> Void
    typealias Receive  = ([AnyHashable : Any]) -> Void
    
    ///Used to instantiate the PUSH Notification object.This method is a public method and accepts single parameter of type [UIApplication](https://developer.apple.com/documentation/uikit/uiapplication) Your singleton app object. This method is used to register push notification.for version greater than 10.0 it uses [UNUserNotificationCenter](https://developer.apple.com/documentation/usernotifications/unusernotificationcenter).
    ///
    ///It is recomanded to use it in appDeleagte inside [didFinishLaunchingWithOptions](https://developer.apple.com/documentation/uikit/uiapplicationdelegate/1622921-application). The clouser returns user permission,Device token and Error.
    ///- parameter application: Singlton app object.This object is required to register the Push notification object for app.
    /// - parameter block : The **Register** type block is a clouser having three paramters **isgranted**,**token** and **error** with data type **Bool**,**String** and **Error** respectively.
  public func set(_Application application: UIApplication,option:UNAuthorizationOptions?, block:@escaping Register){
      self.requestAuthorization(option: option) { (sucess, error) in
          guard error == nil else
          {
            //:Delgate call:
            DispatchQueue.main.async
              {
                block(false,nil,error)
            }
            return
          }
        self.isGranted = sucess!
        if sucess!
          {
            //:Application register for Push Notification:
            DispatchQueue.main.async
              {
                application.registerForRemoteNotifications()
                self.registerObject = block
              }
          }
          else
          {
            //:Delgate call:
            DispatchQueue.main.async
              {
                block(false,nil,nil)
            }
            return
          }
        }
    }

  private func requestAuthorization(option:UNAuthorizationOptions?,completionHandler: @escaping (_ success: Bool?,_ error:Error?) -> ()) {
    // Request Authorization
    notificationCenter.requestAuthorization(options: option!) { (success, error) in
      if let error = error {
        completionHandler(nil,error)
      }
      completionHandler(success,nil)
    }
  }
  
    ///This method is defined to handle the notification.It is a public method and can be used with **PushManager** singlton object.This method returns the clouser when [didReceiveRemoteNotification](https://developer.apple.com/documentation/watchkit/wkextensiondelegate/1628170-didreceiveremotenotification) is called.
    ///
    ///If the app is running, the app calls this method to process incoming remote notifications.
    /// - parameter completion : The **Receive** type block is a clouser having single paramter.This returns the notification data sent from server.
    public func getNotification(_ completion:@escaping Receive){
        self.receiveObject.append(completion)
    }
  
  public func schedule(_event : String, body: String,interval: TimeInterval, isRepeat:Bool?){
      let content = UNMutableNotificationContent()
      content.title = _event
      content.body = body
      content.categoryIdentifier = "CALLINNOTIFICATION"
      let trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: interval, repeats: isRepeat!)
      let identifier = "id_"+_event
      let request = UNNotificationRequest.init(identifier: identifier, content: content, trigger: trigger)
      let center = UNUserNotificationCenter.current()
      center.add(request) { (error) in
    }
  }
}
extension PushManager
{
    fileprivate func ApplicationDidRegisterWithdeviceToken(_ application:UIApplication,deviceToken:Data)
    {
        token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
         self.registerObject(true,token!,nil)
    }
    fileprivate func ApplicationdidFailedForRemoteNotification(_ application: UIApplication, error: Error)
    {
        self.registerObject(false,nil,error)
    }
    fileprivate func ApplicationReceivedRemoteNotification(_ application: UIApplication?,data: [AnyHashable : Any])
    {
        for ref  in self.receiveObject {
            ref!(data)
        }
    }
}
//MARK: AppDelegate Extension
extension AppDelegate:UNUserNotificationCenterDelegate
{
    //Degelate call
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)
    {
        PushManager.shared.ApplicationDidRegisterWithdeviceToken(application, deviceToken: deviceToken)
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error)
    {
        PushManager.shared.ApplicationdidFailedForRemoteNotification(application, error: error)
    }
    func application(_ application: UIApplication, didReceiveRemoteNotification data: [AnyHashable : Any])
    {
        PushManager.shared.ApplicationReceivedRemoteNotification(application,data: data)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void)
    {
        PushManager.shared.ApplicationReceivedRemoteNotification(nil,data: notification.request.content.userInfo)
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void)
    {
        PushManager.shared.ApplicationReceivedRemoteNotification(nil,data: response.notification.request.content.userInfo)
    }
}


