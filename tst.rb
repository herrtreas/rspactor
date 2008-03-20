require "curses"

module Curses
  def self.program
    main_screen = init_screen
    noecho
    cbreak
    curs_set(0)
    main_screen.keypad = true
    yield main_screen
  end
end

Curses.program do |scr|
  scr.setpos(scr.maxy - 2, 0)
  scr.maxx.times { scr.addstr("-") }
  
  scr.setpos(scr.maxy - 1, 0)
  scr.addstr("Mode: Run all specs")
  
  # 100.times do
  #   scr.setpos(rand(max_y), rand(max_x))
  #   scr.addstr(str)
  # end
  loop do
    scr.addstr(scr.getch.to_s)
  end
end