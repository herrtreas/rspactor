require File.dirname(__FILE__) + '/../spec_helper'
require 'html_view'
require 'spec_file_view'
require 'converter'
require 'example_file'

describe SpecFileView do
  before(:each) do
    $app = mock('App')
    $app.stub!(:root)
    $app.stub!(:post_notification)
    @mock_view = mock('WebView')    
    @mock_frame = mock('Frame')
    @mock_document = mock('Document')
    @mock_element = mock('Element')
    @mock_element.stub!(:setInnerHTML)
    @mock_document.stub!(:getElementById).and_return(@mock_element)
    @mock_frame.stub!(:DOMDocument).and_return(@mock_document)
    @mock_view.stub!(:mainFrame).and_return(@mock_frame)
    @mock_spec_object = mock('SpecObject', :state => :passed, :message => 'test')
    @mock_spec_object.stub!(:file_object=)
    @mock_spec_object.stub!(:full_file_path)
    @mock_spec_object.stub!(:file_of_first_backtrace_line)
    @example_file = ExampleFile.new(:path => '/path/to/test.rb')
    @example_file.add_spec(@mock_spec_object)
    @spec_file_view = SpecFileView.new(@mock_view, @example_file)
    Converter.stub!(:source_to_html)
  end
  
  it 'should initialize with webview and file index' do
    @spec_file_view.web_view.should eql(@mock_view)
    @spec_file_view.file.should eql(@example_file)
  end
  
  it 'should set the view' do
    @mock_spec_object.stub!(:state).and_return(:failed)
    @mock_spec_object.should_receive(:backtrace).and_return('')
    @spec_file_view.should_receive(:fold_button).and_return('<img />')
    @spec_file_view.should_receive(:setInnerHTML).with('title', /Test/)
    @spec_file_view.should_receive(:setInnerHTML).with('subtitle', /path\/to/)
    @spec_file_view.should_receive(:setInnerHTML)
    @spec_file_view.update
  end
  
  it 'should set the folding button by state' do
    @mock_spec_object.stub!(:state).and_return(:passed)
    @spec_file_view.fold_button(@mock_spec_object).should include('+')
    @mock_spec_object.stub!(:state).and_return(:pending)
    @spec_file_view.fold_button(@mock_spec_object).should include('-')
  end  
  
  it 'should not show backtraces for passing specs' do
    $spec_list.stub!(:file_by_index).and_return(@spec_file)
    @mock_spec_object.should_not_receive(:backtrace).and_return('')
    @spec_file_view.update
  end
  
  it 'should store the spec file name in the file_name accessor' do
    @spec_file_view.update
    @spec_file_view.file.name.should eql('Test.rb')
  end

  it "should call formatted_message if there is a message" do
    @spec_file_view.should_receive(:formatted_message).with(@mock_spec_object.message).and_return "formatted test"
    @spec_file_view.update
  end

  describe "#formatted_message" do

    it "should properly format the given text" do
      @spec_file_view.formatted_message(nil).should == %Q(<p class="spec_message"></p>)

      @spec_file_view.formatted_message("crazy\r\n cross\r platform linebreaks").should == %Q(<p class="spec_message">crazy\n<br /> cross\n<br /> platform linebreaks</p>)
      @spec_file_view.formatted_message("A paragraph\n\nand another one!").should == %Q(<p class="spec_message">A paragraph</p>\n\n<p>and another one!</p>)
      @spec_file_view.formatted_message("A paragraph\n With a newline").should == %Q(<p class="spec_message">A paragraph\n<br /> With a newline</p>)

      text = "A\nB\nC\nD".freeze
      @spec_file_view.formatted_message(text).should == %Q(<p class="spec_message">A\n<br />B\n<br />C\n<br />D</p>)

      text = "A\r\n  \nB\n\n\r\n\t\nC\nD".freeze
      @spec_file_view.formatted_message(text).should == %Q(<p class="spec_message">A\n<br />  \n<br />B</p>\n\n<p>\t\n<br />C\n<br />D</p>)
    end

  end
end