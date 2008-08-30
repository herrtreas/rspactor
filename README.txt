This is a fork of the original RSpactor that adds support for opening files in Netbeans.

There is an extra preference for a Netbeans path, which can be blank in which case
TextMate will be used as usual. If it's not blank, Netbeans is used.

Two caveats:

1. I've never done any Cocoa before so this may be buggy. Seems to work fine for me though.
2. Due to a bug in Netbeans (http://www.netbeans.org/issues/show_bug.cgi?id=113903),
the Netbeans window freezes after opening a file in it from the command line.
But one just has to resize the window or hit command+shift+return to make it full
screen to "unfreeze" it. It's a pain but it's still quicker than opening the file
manually and scrolling down to the relevant line.
