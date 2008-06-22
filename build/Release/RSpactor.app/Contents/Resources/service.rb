require 'drb'
require 'drb/acl'

module Service
  class << self
    def init(port = '28127')
      init_drb_service(port)
    end
    
    # TODO: Implement trial+error searching for a free port
    def init_drb_service(port)
      begin
        service_url = "%s:%s" % ['127.0.0.1', port]
        $LOG.debug "Loading remote service at druby://#{service_url}"
        DRb.install_acl(ACL.new(%w(deny all allow 127.0.0.1)))
        DRb.start_service("druby://#{service_url}", self)
      rescue => e
        $LOG.error "#{e.message}: #{e.backtrace.first}"
        exit  # TODO: Create alert and inform user about drb error
      end
    end
    
    def ping
      Time.now
    end

    def center
      OSX::NSNotificationCenter.defaultCenter
    end
    
    def incoming(name, *args)
      center.postNotificationName_object_userInfo(name, self, args)
    end
    
  end
end