require File.dirname(__FILE__) + '/../spec_helper'
require 'converter'
require 'ext/syntax/base_syntax'
require 'ext/syntax/syntax/common'
require 'ext/syntax/syntax/convertors/abstract'
require 'ext/syntax/syntax/convertors/html'

describe Converter do
  before(:each) do
    @mock_spec = mock('SpecObject', :line => 10, :full_file_path => '/test.rb')
    @mock_spec.stub!(:source).and_return(['def test()', 'puts "bud"', 'end'])
  end
  
  it 'should convert source to html for webkit view' do
    Converter.source_to_html(@mock_spec).should =~ /def/
  end
end