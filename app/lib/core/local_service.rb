require 'drb'
require 'drb/acl'

module RSpactor
  module Core
    class LocalService
      
      def initialize(interop)
        @interop = interop
        init_drb_service
      end
      
      # TODO: Implement searching for a free port
      def init_drb_service
        begin
          service_url = "%s:%s" % ['127.0.0.1', '28128']
          $LOG.debug "Loading RSpactor-core service at druby://#{service_url}"
          DRb.install_acl(ACL.new(%w(deny all allow 127.0.0.1)))
          DRb.start_service("druby://#{service_url}", self)
        rescue => e
          $LOG.error "#{e.message}: #{e.backtrace.first}"
          exit  # TODO: Alert
        end
      end
      
      def ping
        Time.now
      end
      
      def remote_call_in(name, *args)
        begin
          return unless @interop.respond_to?(name) && !@interop.send("#{name}").nil?
          @interop.send("#{name}".intern).call(*args)
        rescue => e
          $LOG.error "#{e.message}: #{e.backtrace.first}"
        end
      end

    end
  end
end