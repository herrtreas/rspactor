require File.dirname(__FILE__) + '/../spec_helper'
require 'html_view'

describe HtmlView do
  before(:each) do
    @mock_view = mock('WebView')    
    @mock_frame = mock('Frame')
    @mock_document = mock('Document')
    @mock_element = mock('Element')
    @mock_document.stub!(:getElementById).and_return(@mock_element)
    @mock_frame.stub!(:DOMDocument).and_return(@mock_document)
    @mock_view.stub!(:mainFrame).and_return(@mock_frame)
    @html = HtmlView.new
    @html.web_view = @mock_view
  end
  
  it 'should have a reference to the document' do
    @html.document.should eql(@mock_document)
  end
  
  it 'should get a element by id' do
    @html.getElementById('content').should eql(@mock_element)
  end  
  
  it 'should setInnerHTML' do
    @html.should_receive(:getElementById).and_return(@mock_element)
    @mock_element.should_receive(:setInnerHTML).with('testhtml')
    @html.setInnerHTML('content', 'testhtml')
  end  
  
  it 'should replace html characters to make them visible' do
    @html.h("<").should eql('&lt;')
    @html.h(">").should eql('&gt;')
  end
end