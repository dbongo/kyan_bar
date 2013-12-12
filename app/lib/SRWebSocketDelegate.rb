class SRWebSocketDelegate

  def self.webSocket(webSocket, didReceiveMessage:msg)
    jukebox = App.shared.delegate.jukebox
    jukebox.update!(msg.dataUsingEncoding(NSUTF8StringEncoding))
    jukebox.notifications.each do |message|
      App.shared.delegate.new_notification(message)
      unless message.class == ::KyanJukebox::Rating # dirty way to prevent generating notifications for every new rating!
        notification = NSUserNotification.alloc.init
        notification.title = message.heading
        notification.subtitle = message.subtitle
        notification.informativeText = message.description
        NSUserNotificationCenter.defaultUserNotificationCenter.scheduleNotification(notification)
      end
    end
  end

  def self.webSocketDidOpen(webSocket)
    App.shared.delegate.reconn_interval = 0.0
  end

  def self.webSocket(webSocket, didFailWithError:error)
    NSTimer.scheduledTimerWithTimeInterval(App.shared.delegate.reconn_interval,
      target:App.shared.delegate,
      selector:'reconnect_to_websocket_server',
      userInfo:nil,
      repeats: false
      )
  end

  def self.webSocket(webSocket, didCloseWithCode:code, reason:reason, wasClean:wasClean)
    # Bang!
  end
end