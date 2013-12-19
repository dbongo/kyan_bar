class AppDelegate

  def build_menu
    @menu = NSMenu.new
    @menu.delegate = self
    @menu.initWithTitle App.name

    links.each_with_index do |data, i|
      m = NSMenuItem.new
      m.title = data.first
      m.tag = i
      m.setImage( NSImage.imageNamed(data.first.downcase) )
      m.action = 'open_link:'
      @menu.addItem m
    end

    build_submenu

    @menu
  end

  def menuNeedsUpdate(menu)
    np_index = menu.indexOfItemWithTag(MENU_NOWPLAYING)

    if np_index >= 0
      if !jukebox_available?
        menu.removeItemAtIndex(np_index)
        menu.removeItemAtIndex(np_index)
        menu.removeItemAtIndex(np_index)
        menu.removeItemAtIndex(np_index)
      end
    else
      if jukebox_available?
        build_now_playing
      end
    end
  end

  private

  def build_submenu
    sub_menu = NSMenu.new
    mi = NSMenuItem.new
    mi.title = 'Preferences...'
    mi.action = 'build_preferences:'
    mi.setKeyEquivalent(",")
    mi.setKeyEquivalentModifierMask(NSCommandKeyMask)
    sub_menu.addItem mi

    mi = NSMenuItem.new
    mi.title = 'Check for updates...'
    mi.action = 'checkForUpdates:'
    mi.target = SUUpdater.new
    sub_menu.addItem mi

    add_seperator_for(sub_menu)

    mi = NSMenuItem.new
    mi.title = 'About KyanBar'
    mi.action = 'orderFrontStandardAboutPanel:'
    sub_menu.addItem mi

    add_seperator_for(sub_menu)

    mi = NSMenuItem.new
    mi.title = 'Quit'
    mi.action = 'terminate:'
    mi.setKeyEquivalent("q")
    mi.setKeyEquivalentModifierMask(NSCommandKeyMask)
    sub_menu.addItem mi

    add_seperator_for(@menu)

    mi = NSMenuItem.new
    mi.title = 'Settings'
    mi.setSubmenu(sub_menu)
    @menu.addItem mi
  end

  def build_now_playing
    @jukebox_menu ||= NowplayingController.new
    @jukebox_menu.view.refresh(jukebox)

    jbmi = NSMenuItem.new
    jbmi.tag = MENU_NOWPLAYING
    jbmi.view = @jukebox_menu.view
    @menu.insertItem(jbmi, atIndex:0)

    @menu.insertItem(NSMenuItem.separatorItem, atIndex:1)

    jrmi = NSMenuItem.new
    jrmi.title = 'Launch Remote...'
    jrmi.action = 'build_jukebox_controls:'
    jrmi.setKeyEquivalent("0")
    jrmi.setKeyEquivalentModifierMask(NSCommandKeyMask)
    @menu.insertItem(jrmi, atIndex:2)

    @menu.insertItem(NSMenuItem.separatorItem, atIndex:3)
  end

  def open_link(sender)
    url = NSURL.URLWithString( url_for_index(sender.tag) )
    NSWorkspace.sharedWorkspace.openURL(url)
  end

  def add_seperator_for(menu)
    menu.addItem NSMenuItem.separatorItem
  end

  def links
    [
      ["Timesheet"      , "https://gapps.harvestapp.com/gapp_company?domain=kyanmedia.com"],
      ["Pivotal"        , "https://www.pivotaltracker.com/google_domain_openid/redirect_for_auth?domain=kyanmedia.com"],
      ["Support"        , "https://kyan.sirportly.com"],
      ["Holiday"        , "https://appogee-leave.appspot.com/login?domain=kyanmedia.com"],
      ["Campfire"       , "https://kyanmedia.campfirenow.com"]
    ]
  end

  def url_for_index(i)
    links[i].last
  end
end
