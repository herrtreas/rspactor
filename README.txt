NetBeans support by Richard Poirier

Note:
Due to a bug in Netbeans (http://www.netbeans.org/issues/show_bug.cgi?id=113903),
the Netbeans window freezes after opening a file in it from the command line.
But one just has to resize the window or hit command+shift+return to make it full
screen to "unfreeze" it. It's a pain but it's still quicker than opening the file
manually and scrolling down to the relevant line.

== Building instructions

$ git clone git://github.com/rubyphunk/rspactor.git
$ cd rspactor
$ rake package

If you get "ld: framework not found Ruby" on Leopard:

$ cd /Developer/SDKs/MacOSX10.5.sdk/System/Library/Frameworks/Ruby.framework/Versions/Current
$ sudo ln -s usr/lib/libruby.dylib Ruby

