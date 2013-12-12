class AppDelegate

  attr_accessor :reconn_interval, :jukebox, :current_track, :current_rating

  attr_reader :jukeboxControls

  def applicationDidFinishLaunching(notification)
    build_jukebox
    build_status
    handle_notifications

    @reconn_interval = 0.0
    connect_to_websocket_server
  end

  def build_status
    @status_bar_image = NSImage.imageNamed("k_logo_col_18x18")
    @status_bar_image_alt = NSImage.imageNamed("k_logo_bw_18x18")

    status_bar = NSStatusBar.systemStatusBar
    bar = status_bar.statusItemWithLength(NSVariableStatusItemLength)
    bar.retain
    bar.setImage(@status_bar_image)
    bar.setAlternateImage(@status_bar_image_alt)
    bar.setHighlightMode(true)
    @menu = setupMenu
    bar.setMenu(@menu)
  end

  def build_preferences(sender)
    @preferences ||= PreferencesController.alloc.init
    @preferences.window.makeKeyAndOrderFront(self)
    App.shared.activateIgnoringOtherApps(true)
  end

  def launch_jukebox_controls sender
    @jukeboxControls ||= JukeboxControlsController.alloc.init
    @jukeboxControls.display(self)
    App.shared.activateIgnoringOtherApps(true)
  end

  def close_jukebox_controls
    @jukeboxControls = nil
  end

  def build_jukebox
    @jukebox ||= KyanJukebox::Notify.new([:track, :playlist, :rating])
    @jukebox.notify_only << :rating # we want rating messages to come through
    @jukebox.json_parser = BW::JSON
  end

  def connect_to_websocket_server
    url = NSURL.URLWithString(WEBSOCKET_URL)
    @websocket = SRWebSocket.new
    @websocket.initWithURL(url)
    @websocket.delegate = SRWebSocketDelegate
    @websocket.open
  end

  def reconnect_to_websocket_server
    self.reconn_interval = reconn_interval >= 0.1 ? reconn_interval * 2 : 0.1
    self.reconn_interval = [60.0, reconn_interval].min

    connect_to_websocket_server
  end

  def handle_notifications
    NSUserNotificationCenter.defaultUserNotificationCenter.setDelegate(self)
  end

  def userNotificationCenter(center, shouldPresentNotification:notification)
    true
  end

  def new_notification message
    case message
    when ::KyanJukebox::Track
      self.current_track = message
    when ::KyanJukebox::Rating
      self.current_rating = message
    end
    return unless jukeboxControls
    jukeboxControls.new_message(message)
  end
end