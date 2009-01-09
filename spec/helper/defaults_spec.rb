require File.dirname(__FILE__) + '/../spec_helper'
require 'defaults'

describe Defaults do
  describe 'with options by question' do    
    it 'should catch method calls' do
      lambda { Defaults.is_enabled? }.should_not raise_error(NoMethodError)
    end
    
    it 'should not catch methods without question marks' do
      lambda { Defaults.is_enabled }.should raise_error(NoMethodError)      
    end
    
    it 'should return false if the called default doesnt exist' do
      Defaults.stub!(:get).and_return('')
      Defaults.is_enabled?.should be_false
    end
    
    it 'should return true if the called default is "1"' do
      Defaults.stub!(:get).and_return('1')
      Defaults.is_enabled?.should be_true
    end
  end
end