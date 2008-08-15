class String
  def colored(options = {})
    options = { :red => 0.0, :green => 0.0, :blue => 0.0, :alpha => 1.0 }.merge(options)
    color = OSX::NSColor.colorWithCalibratedRed_green_blue_alpha(options[:red], options[:green], options[:blue], options[:alpha])
    attributes = OSX::NSDictionary.dictionaryWithObjects_forKeys([color], [OSX::NSForegroundColorAttributeName])
    OSX::NSAttributedString.alloc.initWithString_attributes(self.to_str, attributes)
  end
end