require File.dirname(__FILE__) + '/../spec_helper'
require 'converter'
require 'ext/syntax/base_syntax'
require 'ext/syntax/syntax/common'
require 'ext/syntax/syntax/convertors/abstract'
require 'ext/syntax/syntax/convertors/html'

describe Converter do
  before(:each) do
    puts "RAW OUTPUT in Converter#10"
    $app.stub!(:default_from_key)
    @mock_spec = mock('SpecObject', :line => 10, :full_file_path => '/test.rb')
    @mock_spec.stub!(:source).and_return(['def test()', 'puts "bud"', 'end'])
  end
  
  it 'should convert source to html for webkit view' do
    "hasdasd"
    Converter.source_to_html(@mock_spec).should =~ /def/
  end
  
  it 'should format a specs backtrace' do
    @mock_spec.should_receive(:backtrace).and_return(['/path/to/file.rb'])
    trace = Converter.formatted_backtrace(@mock_spec)
    trace.should eql("<li><a href='#' onclick='alert(\"/path/to/file.rb\")'>/path/to/file.rb</a></li>")
  end
  
  it 'should trim backtrace alerts to only contain file and line number' do
    @mock_spec.should_receive(:backtrace).and_return(['/path/to/file.rb:5:xx:trash'])
    trace = Converter.formatted_backtrace(@mock_spec)
    trace.should eql("<li><a href='#' onclick='alert(\"/path/to/file.rb:5\")'>/path/to/file.rb:5:xx:trash</a></li>")    
  end
  
end