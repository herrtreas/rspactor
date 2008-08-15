require File.dirname(__FILE__) + '/../spec_helper'
require 'osx/cocoa'
require 'string'
include OSX

describe String do
  before(:each) do
    @string = "TestAString"
  end  
  
  it 'should provide a colored method to output formatted NSAttributedString strings' do
    @string.colored.should be_kind_of(NSAttributedString)
    @string.colored.to_s.should include('TestAString')
  end
end
