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
    @buttonsView ||= NSView.alloc.init.tap do |buttonsView|
      views_dictionary = {
          "upVoteButton" => upVoteButton,
          "downVoteButton" => downVoteButton
      }
      views_dictionary.each do |key, view|
        buttonsView.addSubview(view)
      end
      buttonsView.translatesAutoresizingMaskIntoConstraints = false
      constraints = []
      constraints += NSLayoutConstraint.constraintsWithVisualFormat "H:|[upVoteButton(==30)]|",
                                                                options:NSLayoutFormatAlignAllCenterY,
                                                                metrics:nil,
                                                                views:views_dictionary
      constraints += NSLayoutConstraint.constraintsWithVisualFormat "H:|[downVoteButton(==30)]|",
                                                                options:NSLayoutFormatAlignAllCenterY,
                                                                metrics:nil,
                                                                views:views_dictionary

      constraints += NSLayoutConstraint.constraintsWithVisualFormat "V:|[upVoteButton(==30)]-[downVoteButton(==30)]",
                                                              options:NSLayoutFormatAlignAllCenterX,
                                                              metrics:nil,
                                                              views:views_dictionary
      buttonsView.addConstraints constraints
    end
  end

  def upVoteButton
    @upVoteButton ||= NSButton.alloc.init.tap do |button|
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle "+"
      button.setAction "sendVote:"
    end
  end

  def downVoteButton
    @downVoteButton ||= NSButton.alloc.init.tap do |button|
      button.translatesAutoresizingMaskIntoConstraints = false
      button.setTitle "-"
      button.setAction "sendVote:"
    end
  end

  def sendVote button
    puts button
    vote = button == upVoteButton
    user = "paul"
    raise "NO PASSWORD"
    password = "..."
    url = "http://jukebox.local/external?vote[aye]=#{vote}&login[user]=#{user}&login[password]=#{password}"
    BW::HTTP.get(url) do |response|
      #puts response.body.to_str
    end
  end

  def trackDetailsView
    @trackDetailsView ||= NSView.alloc.init.tap do |trackDetailsView|
      views_dictionary = {
          "artistTitleView" => artistTitleView,
          "albumView" => albumView,
          "positiveRatingsView" => positiveRatingsView,
          "negativeRatingsView" => negativeRatingsView
      }
      views_dictionary.each do |key, view|
        trackDetailsView.addSubview(view)
      end
      trackDetailsView.translatesAutoresizingMaskIntoConstraints = false
      constraints = []
      constraints += NSLayoutConstraint.constraintsWithVisualFormat("H:|[artistTitleView(>=170)]|",
                                                                options:NSLayoutFormatAlignAllCenterY,
                                                                metrics:nil,
                                                                views:views_dictionary)
      constraints += NSLayoutConstraint.constraintsWithVisualFormat "H:|[albumView]|",
                                                                options:NSLayoutFormatAlignAllCenterY,
                                                                metrics:nil,
                                                                views:views_dictionary
      constraints += NSLayoutConstraint.constraintsWithVisualFormat "H:|[positiveRatingsView]|",
                                                                options:NSLayoutFormatAlignAllCenterY,
                                                                metrics:nil,
                                                                views:views_dictionary
      constraints += NSLayoutConstraint.constraintsWithVisualFormat "H:|[negativeRatingsView]|",
                                                                options:NSLayoutFormatAlignAllCenterY,
                                                                metrics:nil,
                                                                views:views_dictionary
      constraints += NSLayoutConstraint.constraintsWithVisualFormat "V:|[artistTitleView][albumView]-[positiveRatingsView][negativeRatingsView]|",
                                                                options:NSLayoutFormatAlignAllCenterX,
                                                                metrics:nil,
                                                                views:views_dictionary
      trackDetailsView.addConstraints constraints
    end
  end

  def artistTitleView
    @artistTitleView ||= NSTextField.alloc.init.tap do |label|
      label.translatesAutoresizingMaskIntoConstraints = false
      label.editable = false
      label.selectable  = false
      label.drawsBackground = true
      label.textColor = NSColor.blackColor
      label.bordered  = false
      label.alignment = NSLeftTextAlignment
      label.backgroundColor = NSColor.clearColor
    end
  end

  def albumView
    @albumView ||= NSTextField.alloc.init.tap do |label|
      label.translatesAutoresizingMaskIntoConstraints = false
      label.editable = false
      label.selectable  = false
      label.drawsBackground = true
      label.textColor = NSColor.grayColor
      label.bordered  = false
      label.alignment = NSLeftTextAlignment
      label.backgroundColor = NSColor.clearColor
    end
  end

  def negativeRatingsView
    @negativeRatingsView ||= NSTextField.alloc.init.tap do |label|
      label.translatesAutoresizingMaskIntoConstraints = false
      label.editable = false
      label.selectable  = false
      label.drawsBackground = true
      label.textColor = NSColor.blackColor
      label.bordered  = false
      label.alignment = NSLeftTextAlignment
      label.backgroundColor = NSColor.clearColor
    end
  end

  def positiveRatingsView
    @positiveRatingsView ||= NSTextField.alloc.init.tap do |label|
      label.translatesAutoresizingMaskIntoConstraints = false
      label.editable = false
      label.selectable  = false
      label.drawsBackground = true
      label.textColor = NSColor.blackColor
      label.bordered  = false
      label.alignment = NSLeftTextAlignment
      label.backgroundColor = NSColor.clearColor
    end
  end

  def new_message message
    puts "new_message: #{message}"
    case message
    when ::KyanJukebox::Track
      puts "New Track"
      artistTitleView.stringValue = "#{message.artist} '#{message.title}'"
      albumView.stringValue = message.album
    when ::KyanJukebox::Rating
      positiveRatingsView.stringValue = "+ #{message.positive_ratings.join(", ")}"
      negativeRatingsView.stringValue = "- #{message.negative_ratings.join(", ")}"
    end
  end

  private

  def customizeWindow
    if @window.contentView.subviews.include?(artistTitleView)
      puts "Already customized window"
      return
    end
    puts "customizeWindow"

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
    puts "setCurrentTrack"
    new_message App.shared.delegate.current_track
    new_message App.shared.delegate.current_rating
  end

end