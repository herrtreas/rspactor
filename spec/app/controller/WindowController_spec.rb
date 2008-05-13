require File.join(File.dirname(__FILE__), '/../../spec_helper')
require 'lib/Callback'
require 'lib/Growl'
require 'controller/WindowController'

describe WindowController do
  before(:each) do
    @wc = WindowController.new
  end
end