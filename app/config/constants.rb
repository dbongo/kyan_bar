WEBSOCKET_HOST = 'jukebox.local'
WEBSOCKET_URL = "ws://#{WEBSOCKET_HOST}:8081"
VOTE_URL = "http://#{WEBSOCKET_HOST}/external?"

DEFAULT_MENU_WIDTH=250.0

TRACK_TITLE=1
TRACK_ARTIST=2
TRACK_ARTWORK_URL=3
TRACK_ALBUM=4

VOTE_VIEW_H=19
VOTE_VIEW_W=21

U_VOTE_BUTTON=32
D_VOTE_BUTTON=33

MENU_NOWPLAYING=111
MENU_CONSOLE_BUTT=222

JB_MESSAGE_RECEIVED="JukeboxMessageReceived"
JB_UPDATED="JukeboxUpdated"
JB_DO_VOTE="JukeboxDoVote"