require 'json'

module PdnsRemotebackend 
  class Result
    @_result = false

    def <<(data)
      if (@_result.class == Array) 
         @_result << data
      else 
         @_result = [data]
      end
    end

    def set(value)
      @_result = value
    end

    def to_json
      @_result.to_json
    end
  end
  
  class Handler
     @_result = Result.new
     @log = []
  
     def initialize
     end
  
     def result=(value)
       @_result.set(value)
     end
    
     def result
       @_result
     end

     def rr(qname, qtype, content, ttl, priority = 0, auth = 1, domain_id = -1)
        {:qname => qname, :qtype => qtype, :content => content, :ttl => ttl.to_i, :priority => priority.to_i, :auth => auth.to_i, :domain_id => domain_id.to_i}
     end
  
     def do_initialize(*args)
       log << "Test bench initialized"
       result = true
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
end 
