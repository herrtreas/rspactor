module SpecServer
  class << self
    attr_accessor :root
    attr_accessor :task
    attr_accessor :ready
    attr_accessor :pid_file
    
    def cleanup
      stop if self.task 
    end
    
    def binary
      File.join(self.root, 'script/spec_server')
    end
    
    def available?
      self.root && File.exist?(File.join(self.root, 'script/spec_server'))
    end
    
    def ready?
      self.ready && self.ready == true
    end
    
    def start
      self.ready = false
      if available?
        $LOG.debug "Loading spec:server at #{binary}"
        $app.post_notification(:spec_server_loading)
        prepare_task
        self.task.launch
      end
    end
    
    def stop
      self.ready = false
      self.task.terminate if self.task && self.task.isRunning
      if self.running?
        $LOG.debug "Sendind QUIT to spec_server (#{pid})"
        send_command "kill -9 #{pid}"
      end
    end
    
    def restart
      stop
      start
    end
    
    def pid
      begin
        @pid ||= File.open('/tmp/rspactor_spec_server.pid', 'r') { |f| f.readlines }.first.strip.chomp
      rescue
        @pid = nil
      end
    end
    
    def running?
      send_command("ps aux | grep #{pid}").include?('spec_server')
    end

    def pipeContentAvailable(notification)
      return false unless pipeContentMatching?(notification)

      data = readDataFromPipe(notification)
      $LOG.debug "spec_server: #{data.to_s.strip.chomp}"
      return if data.empty?
      
      case notification.object
      when self.task.standardOutput.fileHandleForReading
        if data && data.include?('Ready')
          self.ready = true
          $app.post_notification(:spec_server_ready)
        end
      when self.task.standardError.fileHandleForReading
        if data.to_s =~ /error/i
          $raw_output[0][1] << data          
          $app.post_notification(:spec_server_failed, data)
        end
      end
    end
    
    def bootTaskFinished!
      if self.running?      
        self.ready = true
        $app.post_notification(:spec_server_ready)
      else
        $app.post_notification(:spec_server_failed, '')
      end
    end
    
    def prepare_task
      @pid = nil      
      self.task = OSX::NSTask.alloc.init      
      self.task.currentDirectoryPath = self.root
      self.task.standardOutput = OSX::NSPipe.alloc.init
      self.task.standardError = OSX::NSPipe.alloc.init      
      self.task.standardOutput.fileHandleForReading.readInBackgroundAndNotify
      self.task.standardError.fileHandleForReading.readInBackgroundAndNotify      
      self.task.launchPath = self.binary
      self.task.arguments = ['--daemon', '--pid=/tmp/rspactor_spec_server.pid']      
    end   

    def send_command(cmd)
      %x(#{cmd})
    end   
    
    
    private
   
    def pipeContentMatching?(notification)
      return false if self.task.nil?
      notification.object == self.task.standardError.fileHandleForReading || notification.object == self.task.standardOutput.fileHandleForReading
    end

    def readDataFromPipe(notification)
      NSString.alloc.initWithData_encoding(notification.userInfo[OSX::NSFileHandleNotificationDataItem], NSASCIIStringEncoding)
    end    
  end
end