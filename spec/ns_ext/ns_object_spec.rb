require File.dirname(__FILE__) + '/../spec_helper'
require 'osx/cocoa'
require 'ns_object'
include OSX

describe NSObject do
  before(:each) do
    @object = NSObject.new
  end  
  
  it 'should provide a shortcut for observing notifications' do
    @object.receive 'hello world', :test
  end
end
