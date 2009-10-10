require 'rspactor/inspector'

describe RSpactor::Inspector do
  before(:all) do
    options = { :view => true }
    @inspector = described_class.new(mock('Runner', :dir => '/project', :options => options))
  end
  
  def translate(file)
    @inspector.translate(file)
  end
  
  describe "#translate" do
    it "should consider all controllers when application_controller changes" do
      translate('/project/app/controllers/application_controller.rb').should == ['/project/spec/controllers']
      translate('/project/app/controllers/application.rb').should == ['/project/spec/controllers']
    end
    
    it "should translate files under 'app/' directory" do
      translate('/project/app/controllers/foo_controller.rb').should ==
        ['/project/spec/controllers/foo_controller_spec.rb']
    end
    
    it "should translate templates" do
      translate('/project/app/views/foo/bar.erb').should == ['/project/spec/views/foo/bar.erb_spec.rb']
      translate('/project/app/views/foo/bar.html.haml').should ==
        ['/project/spec/views/foo/bar.html.haml_spec.rb', '/project/spec/views/foo/bar.html_spec.rb']
    end
    
    it "should consider all views when application_helper changes" do
      translate('/project/app/helpers/application_helper.rb').should == ['/project/spec/helpers', '/project/spec/views']
    end
    
    it "should consider related templates when a helper changes" do
      translate('/project/app/helpers/foo_helper.rb').should ==
        ['/project/spec/helpers/foo_helper_spec.rb', '/project/spec/views/foo']
    end
    
    it "should translate files under deep 'lib/' directory" do
      translate('/project/lib/awesum/rox.rb').should ==
        ['/project/spec/lib/awesum/rox_spec.rb', '/project/spec/awesum/rox_spec.rb', '/project/spec/rox_spec.rb']
    end
    
    it "should translate files under shallow 'lib/' directory" do
      translate('lib/runner.rb').should == ['/project/spec/lib/runner_spec.rb', '/project/spec/runner_spec.rb']
    end
    
    it "should handle relative paths" do
      translate('foo.rb').should == ['/project/spec/foo_spec.rb']
    end
    
    it "should handle files without extension" do
      translate('foo').should == ['/project/spec/foo_spec.rb']
    end
    
    it "should consider all controllers, helpers and views when routes.rb changes" do
      translate('config/routes.rb').should == ['/project/spec/controllers', '/project/spec/helpers', '/project/spec/views', '/project/spec/routing']
    end
    
    it "should consider all models when config/database.yml changes" do
      translate('config/database.yml').should == ['/project/spec/models']
    end
    
    it "should consider all models when db/schema.rb changes" do
      translate('db/schema.rb').should == ['/project/spec/models']
    end
    
    it "should consider all models when spec/factories.rb changes" do
      translate('spec/factories.rb').should == ['/project/spec/models']
    end
    
    it "should consider related model when its observer changes" do
      translate('app/models/user_observer.rb').should == ['/project/spec/models/user_observer_spec.rb', '/project/spec/models/user_spec.rb']
    end
    
    it "should consider all specs when spec_helper changes" do
      translate('spec/spec_helper.rb').should == ['/project/spec']
    end
    
    it "should consider all specs when code under spec/shared/ changes" do
      translate('spec/shared/foo.rb').should == ['/project/spec']
    end
    
    it "should consider all specs when app configuration changes" do
      translate('config/environment.rb').should == ['/project/spec']
      translate('config/environments/test.rb').should == ['/project/spec']
      translate('config/boot.rb').should == ['/project/spec']
    end
    
    it "should consider cucumber when a features file change" do
      translate('features/login.feature').should == ['cucumber']
      translate('features/steps/webrat_steps.rb').should == ['cucumber']
      translate('features/support/env.rb').should == ['cucumber']
    end
    
  end
  
  describe "#determine_files" do
    def determine(file)
      @inspector.determine_files(file)
    end
    
    it "should filter out files that don't exist on the filesystem" do
      @inspector.should_receive(:translate).with('foo').and_return(%w(valid_spec.rb invalid_spec.rb))
      File.should_receive(:exists?).with('valid_spec.rb').and_return(true)
      File.should_receive(:exists?).with('invalid_spec.rb').and_return(false)
      determine('foo').should == ['valid_spec.rb']
    end
    
    it "should filter out files in subdirectories that are already on the list" do
      @inspector.should_receive(:translate).with('foo').and_return(%w(
        spec/foo_spec.rb
        spec/views/moo/bar_spec.rb
        spec/views/baa/boo_spec.rb
        spec/models/baz_spec.rb
        spec/controllers/moo_spec.rb
        spec/models
        spec/controllers
        spec/views/baa
      ))
      File.stub!(:exists?).and_return(true)
      determine('foo').should == %w(
        spec/foo_spec.rb
        spec/views/moo/bar_spec.rb
        spec/models
        spec/controllers
        spec/views/baa
      )
    end
  end
end