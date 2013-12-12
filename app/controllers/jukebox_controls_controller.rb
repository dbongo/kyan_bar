class JukeboxControlsController < NSWindowController

  attr_reader :window

  def init
    super.tap do
      buildWindow
    end
  end

  def display new_delegate
    buildWindow
    customizeWindow
    setCurrentTrack
    @window.makeKeyAndOrderFront(new_delegate)
  end

  def artworkView
    @artworkView ||= NSImageView.alloc.init.tap do |artworkView|
      artworkView.translatesAutoresizingMaskIntoConstraints = false
      artworkView.setImage NSImage.alloc.initWithContentsOfFile("#{NSBundle.mainBundle.resourcePath}/missing_artwork.png")
    end
  end

  def new_artwork artworkView
    artworkView.setImage(artworkView)
  end

  def buttonsView
    @buttonsView ||= ButtonsView.alloc.init
  end

  def trackDetailsView
    @trackDetailsView ||= TrackDetailsView.alloc.init
  end

  def new_message message
    trackDetailsView.new_message message
  end

  def registerVote button
    VoteHandler.register(button.vote)
  end

  private

  def customizeWindow
    if @window.contentView.subviews.include?(artworkView)
      puts "Already customized window"
      return
    end

    views_dictionary = {
        "artworkView" => artworkView,
        "trackDetailsView" => trackDetailsView,
        "buttonsView" => buttonsView
    }

    views_dictionary.each do |key, view|
      @window.contentView.addSubview(view)
    end

    @window.contentView.backgroundColor = NSColor.yellowColor

    @window.contentView.translatesAutoresizingMaskIntoConstraints = false

    constraints = []
    constraints += NSLayoutConstraint.constraintsWithVisualFormat "H:|[artworkView(==75)][trackDetailsView]-[buttonsView]|",
                                                              options:NSLayoutFormatAlignAllCenterY,
                                                              metrics:nil,
                                                              views:views_dictionary
    constraints += NSLayoutConstraint.constraintsWithVisualFormat "V:|[artworkView(==75)]|",
                                                              options:NSLayoutFormatAlignAllCenterX,
                                                              metrics:nil,
                                                              views:views_dictionary
    constraints += NSLayoutConstraint.constraintsWithVisualFormat "V:|[trackDetailsView]|",
                                                              options:NSLayoutFormatAlignAllCenterX,
                                                              metrics:nil,
                                                              views:views_dictionary
    constraints += NSLayoutConstraint.constraintsWithVisualFormat "V:|[buttonsView]|",
                                                              options:NSLayoutFormatAlignAllCenterX,
                                                              metrics:nil,
                                                              views:views_dictionary
    @window.contentView.addConstraints constraints
  end

  def buildWindow
    return if @windowra
    @window = NSWindow.alloc.initWithContentRect([[240, 180], [290, 80]],
      styleMask: NSTitledWindowMask|NSClosableWindowMask|NSMiniaturizableWindowMask|NSResizableWindowMask,
      backing: NSBackingStoreBuffered,
      defer: false
    )
    @window.delegate = self
    @window.title = "Jukebox"
    @window.orderFrontRegardless
  end

  def setCurrentTrack
    new_message App.shared.delegate.current_track
    new_message App.shared.delegate.current_rating
  end

end