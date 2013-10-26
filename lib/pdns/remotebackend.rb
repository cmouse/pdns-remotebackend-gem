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
       @params = args[0]
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

    # Reads one line at a time from pipebackend, and calls approriate method
    #
    # @param [Socket] reader Socket to read from
    # @param [Socket] writer Socket to write to
    def mainloop3(reader,writer)
      h = @handler.new
      state = :init
      abi = 1
      last_soa_name = nil

      reader.each_line do |line|
        h.log = []
        h.result = false

        # cannot continue anymore
        if state == :fail
          next
        end

        input = {}
        line = line.strip
        if (state == :init) 
          if line.match "HELO[ \t]*([0-9])"
            abi = $2.to_i
            # synthesize empty init
            h.do_initialize(input)

            if h.result == false
               state = :fail
               h.log.each do |l| 
                 writer.puts "LOG\t#{l}"
               end
               writer.puts "FAIL"
            else
               writer.puts "OK\tPowerDNS ruby remotebackend version #{Pdns::Remotebackend::VERSION} initialized"
               state = :main 
            end
          else
            writer.puts "FAIL"
            state = :fail
          end
          next
        end
 
        # parse input
        query = line.split /[\t ]+/
        input["method"] = query[0]
        if input["method"] == "Q"
           input["method"] = "lookup"
           input["parameters"] = {
               "qname" => query[1], "qclass" => query[2],
               "qtype" => query[3], "domain_id" => query[4].to_i,
               "zone_id" => query[4].to_i, "remote" => query[5]
           }
           if abi > 1 
             input["parameters"]["local"] = query[6]
           end
           if abi > 2
             input["parameters"]["edns-subnet"] = query[7]
           end
           if input["parameters"]["qtype"] == "SOA"
             last_soa_name = input["parameters"]["qname"]
           end
        elsif input["method"] == "AXFR"
           input["method"] = "list"
           input["parameters"] = { "zonename" => last_soa_name, "domain_id" => line[1].to_i }
        else
           writer.puts "FAIL"
           next
        end

        method = "do_#{input["method"]}"
        # try to call
        if h.respond_to?(method.to_sym) == true
          h.send(method, input["parameters"])
        else
          writer.puts "FAIL"
          next
        end

        if (h.result != false) 
          h.result.each do |r|
             if r.has_key? :scopemask == false
                r[:scopemask] = 0
             end
             if r.has_key?(:domain_id) == false
                r[:domain_id] = input["parameters"]["domain_id"]
             end

             # fix content to contain prio if needed
             if ["MX", "SRV", "NAPTR"].include? r[:qtype].upcase
                if r.has_key?("prio")
                   r[:content] = "#{r[:prio].to_i} #{r[:content]}"
                else
                   r[:content] = "0 #{r[:content]}"
                end
             end
             if (abi < 3)
                writer.puts "DATA\t#{r[:qname]}\tIN\t#{r[:qtype]}\t#{r[:ttl]}\t#{r[:domain_id]}\t#{r[:content]}"
             else
                writer.puts "DATA\t#{r[:scopemask]}\t#{r[:auth]}\t#{r[:qname]}\tIN\t#{r[:qtype]}\t#{r[:ttl]}\t#{r[:domain_id]}\t#{r[:content]}"
             end
          end
        end

        h.log.each do |l|
          writer.puts "LOG\t#{l}"
        end
        writer.puts "END"
      end
    end

    # Reads one line at a time from remotebackend, and calls approriate method 
    #
    # @param [Socket] reader Socket to read from
    # @param [Socket] writer Socket to write to
    def mainloop4(reader,writer)
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
        if (@options.has_key? :abi and @options[:abi].to_sym == :pipe) 
            mainloop3 STDIN,STDOUT
        else
            mainloop4 STDIN,STDOUT
        end
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
            if (@options.has_key? :abi and @options[:abi].to_sym == :pipe)
               mainloop3 sock,sock
            else
               mainloop4 sock,sock
            end
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
