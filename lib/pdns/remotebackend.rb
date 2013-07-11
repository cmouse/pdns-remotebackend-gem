require 'socket'
require 'json'
require 'pdns/remotebackend/version'

module Pdns
 module Remotebackend 
  class Handler
     attr_accessor :log, :result, :ttl

     # Initialize with defaults values
     def initialize
       @log = []
       @result = false
       @ttl = 300
       @params = {}
     end

     # Generates a hash of resource record
     # 
     # @param [String] qname name of record
     # @param [String] qtype type of record
     # @param [String] content record contents
     # @param [Integer] prio Record priority
     # @param [Integer] ttl Record TTL
     # @param [Integer] auth Whether we are authoritative for the record or not
     # @return [Hash] A resource record hash
     def record_prio_ttl(qname,qtype,content,prio,ttl,auth=1)
       {:qtype => qtype, :qname => qname, :content => content, :priority => prio, :ttl => ttl, :auth => auth}
     end

     # Generates a hash of resource record
     #
     # @param [String] qname name of record
     # @param [String] qtype type of record
     # @param [String] content record contents
     # @param [Integer] prio Record priority
     # @param [Integer] auth Whether we are authoritative for the record or not
     # @return [Hash] A resource record hash
     def record_prio(qname,qtype,content,prio,auth=1)
       record_prio_ttl(qname,qtype,content,prio,@ttl,auth)
     end

     # Generates a hash of resource record
     #
     # @param [String] qname name of record
     # @param [String] qtype type of record
     # @param [String] content record contents
     # @param [Integer] auth Whether we are authoritative for the record or not
     # @return [Hash] A resource record hash
     def record(qname,qtype,content,auth=1)
       record_prio_ttl(qname,qtype,content,0,@ttl,auth)
     end
  
     def do_initialize(*args)
       @params = args
       @log << "PowerDNS ruby remotebackend version #{Pdns::Remotebackend::VERSION} initialized"
       @result = true
     end
  
     def do_lookup(args) 
     end
  
     def do_list(args)
     end 
  
     def do_getdomainmetadata(args)
     end
  
     def do_setdomainmetadata(args)
     end
  
     def do_adddomainkey(args)
     end
  
     def do_getdomainkeys(args) 
     end 
  
     def do_activatedomainkey(args) 
     end 
  
     def do_deactivatedomainkey(args)
     end
  
     def do_removedomainkey(args)
     end 
  
     def do_getbeforeandafternamesabsolute(args)
     end
  
     def do_gettsigkey(args) 
     end
  
     def do_setnotified(args) 
     end
  
     def do_getdomaininfo(args) 
     end
  
     def do_supermasterbackend(args) 
     end
  
     def do_createslavedomain(args)
     end
  
     def do_feedrecord(args)
     end
  
     def do_replacerrset(args)
     end 
  
     def do_feedents(args)
     end
  
     def do_feedents3(args)
     end
  
     def do_settsigkey(args) 
     end
  
     def do_deletetsigkey(args)
     end
  
     def do_gettsigkeys(*args)
     end
  
     def do_starttransaction(args) 
     end
  
     def do_committransaction(args)
     end
  
     def do_aborttransaction(args)
     end
    
     def do_calculatesoaserial(args)
     end
  end

  class Connector 
    def initialize(klass, options = {})
      @handler = klass
      @options = options
    end

    # Reads one line at a time from remotebackend, and calls approriate method 
    #
    # @param [Socket] reader Socket to read from'
    # @param [Socket] writer Socket to write to
    def mainloop(reader,writer)
      h = @handler.new
      
      reader.each_line do |line|
        # expect json
        input = {}
        line = line.strip
        next if line.empty?
        begin
          input = JSON.parse(line)
          method = "do_#{input["method"].downcase}"
          args = input["parameters"] || {}
          h.result = false
          h.log = []
          if h.respond_to?(method.to_sym) == false
            res = false
          else
            h.send(method,args)
          end
          writer.puts ({:result => h.result, :log => h.log}).to_json
        rescue JSON::ParserError
          writer.puts ({:result => false, :log => "Cannot parse input #{line}"}).to_json
          next
        end
      end
    end
  end

  class Pipe < Connector
    def run
      begin
        STDOUT.sync=true
        mainloop STDIN,STDOUT
      rescue SystemExit, Interrupt
      end
    end
  end

  class Unix < Connector
    def run
      @path = @options[:path] || "/tmp/remotebackend.sock"
      begin 
        Socket.unix_server_loop(@path) do |sock, client_addrinfo| 
          begin 
            mainloop sock, sock
          ensure
            sock.close
          end
        end
      rescue SystemExit, Interrupt 
      end
    end
  end
 end
end
