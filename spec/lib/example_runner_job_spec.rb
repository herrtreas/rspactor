require File.dirname(__FILE__) + '/../spec_helper'
require 'example_runner_job'

describe ExampleRunnerJob do
  before(:each) do
    @job = ExampleRunnerJob.new(:root => '/test')
  end
  
  it 'should take paths as argument on initialize' do
    job = ExampleRunnerJob.new(:paths => ['test'])
    job.paths.should eql(['test'])
  end
  
  it 'should accept paths for running' do
    @job.paths = ['test1', 'test2']
    @job.paths.should eql(['test1', 'test2'])
  end
  
  it 'should return root + /spec if no paths are given' do
    @job.paths.should eql(['/test/spec/'])
  end
  
  it 'should return $app.root if root wasnt definded' do
    $app.stub!(:root).and_return('/test/app/root')
    job = ExampleRunnerJob.new()    
    job.root.should eql('/test/app/root')
  end
end