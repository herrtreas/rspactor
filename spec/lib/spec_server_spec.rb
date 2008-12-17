require File.dirname(__FILE__) + '/../spec_helper'
require 'spec_server'

describe SpecServer do
  before(:each) do
    $app = mock('App')
    $app.stub!(:post_notification)
  end
  
  describe 'with initialization and cleanup' do
    it 'should terminate the spec_server task' do
      SpecServer.task = mock('Task')
      SpecServer.should_receive(:stop)
      SpecServer.cleanup
    end
  end
  
  describe 'with spec_server binary detection' do
    it 'should know the spec_server binary path' do
      SpecServer.root = $fpath_rails
      SpecServer.binary.should eql(File.join($fpath_rails, 'script/spec_server'))
    end

    it 'should know if its available' do
      SpecServer.root = $fpath_rails
      SpecServer.available?.should eql(true)
    end
    
    it 'should know if its not available' do
      SpecServer.root = $fpath_simple
      SpecServer.available?.should eql(false)
    end    
  end
  
  describe 'with task preparation' do
    before(:each) do
      SpecServer.root = $fpath_rails      
    end
    
    it 'should create a task and assign pipes' do
      SpecServer.prepare_task
      SpecServer.task.should be_kind_of(OSX::NSTask)
      SpecServer.task.standardOutput.should be_kind_of(OSX::NSPipe)
      SpecServer.task.standardError.should be_kind_of(OSX::NSPipe)
    end
    
    it 'should assign tasks launchpath' do
      SpecServer.prepare_task
      SpecServer.task.launchPath.to_s.should eql(SpecServer.binary)
    end    
  end
  
  describe 'with process handling' do
    before(:each) do      
      SpecServer.task = @mock_task = mock('Task')
      SpecServer.stub!(:prepare_task)      
      SpecServer.stub!(:pid).and_return('111')
      @mock_task.stub!(:running?).and_return(true)
    end
    
    it 'should launch the task' do
      @mock_task.should_receive(:launch)
      SpecServer.start
    end
    
    it 'should post a notification after launch' do
      $app.should_receive(:post_notification).with(:spec_server_loading)
      @mock_task.stub!(:launch)
      SpecServer.start
    end
    
    it 'should not launch the task if binary not available' do
      SpecServer.should_receive(:available?).and_return(false)
      @mock_task.should_not_receive(:launch)
      SpecServer.start
    end
    
    describe 'with termination' do      
      it 'should kill the task if the daemon isnt loaded yet' do
        @mock_task.stub!(:isRunning).and_return(true)
        @mock_task.should_receive(:terminate)
        SpecServer.stop
      end
      
      it 'should kill the process if its running' do
        @mock_task.stub!(:isRunning).and_return(false)
        SpecServer.stub!(:running?).and_return(true)
        SpecServer.should_receive(:send_command)
        SpecServer.stop        
      end      
    end
    
    it 'should restart the task' do
      SpecServer.should_receive(:stop)
      SpecServer.should_receive(:start)
      SpecServer.restart
    end

    it 'should know if the spec_server is running' do
      SpecServer.should_receive(:send_command).and_return('ps aux test result spec_server')
      SpecServer.running?.should be_true
    end

    it 'should not be ready after starting and stopping' do
      @mock_task.stub!(:launch)
      SpecServer.ready = true
      SpecServer.start
      SpecServer.should_not be_ready
    end

    it 'should not be ready after stopping' do
      @mock_task.stub!(:isRunning).and_return(true)
      @mock_task.stub!(:terminate)
      SpecServer.ready = true
      SpecServer.stop
      SpecServer.should_not be_ready
    end

    describe 'and pipe handling' do
      before(:each) do
        @mock_file_handle = mock('FileHandle')
        @mock_error_file_handle = mock('ErrorFileHandle')        
        @mock_std_pipe = mock('StdPipe')
        @mock_std_pipe.stub!(:fileHandleForReading).and_return(@mock_file_handle)
        @mock_err_pipe = mock('ErrPipe')
        @mock_err_pipe.stub!(:fileHandleForReading).and_return(@mock_error_file_handle)
        @mock_notification = mock('Notification')
        @mock_notification.stub!(:object).and_return(nil)        
        SpecServer.stub!(:readDataFromPipe)
      end
      
      it 'should ignore a pipe that doesnt belong to the spec_server' do
        @mock_task.stub!(:standardOutput).and_return(@mock_std_pipe)
        @mock_task.stub!(:standardError).and_return(@mock_err_pipe)
        SpecServer.pipeContentAvailable(@mock_notification).should be_false
      end      
      
      describe 'posting the state' do
        before(:each) do
          @mock_notification.stub!(:object).and_return(@mock_file_handle)
          SpecServer.stub!(:pipeContentMatching?).and_return(true)          
        end
        
        it 'should post a notification if spec_server is ready' do
          @mock_task.stub!(:standardOutput).and_return(@mock_std_pipe)
          $app.should_receive(:post_notification).with(:spec_server_ready)
          SpecServer.should_receive(:readDataFromPipe).and_return('Ready')
          SpecServer.pipeContentAvailable(@mock_notification)
          SpecServer.should be_ready
        end

        it 'should post a notification if spec_server failed' do
          @mock_notification.stub!(:object).and_return(@mock_error_file_handle)
          @mock_task.stub!(:standardOutput).and_return(@mock_std_pipe)
          @mock_task.stub!(:standardError).and_return(@mock_err_pipe)
          $app.should_receive(:post_notification).with(:spec_server_failed, 'error')
          SpecServer.should_receive(:readDataFromPipe).and_return('error')
          SpecServer.pipeContentAvailable(@mock_notification)
        end
      end
      
    end
    
  end  
end