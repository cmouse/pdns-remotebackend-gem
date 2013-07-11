require 'json'
require 'pdns_remotebackend/pipe'
require 'pdns_remotebackend/unix'

module PdnsRemotebackend 
  class Handler
     attr_accessor :log, :result, :ttl

     def initialize
       @log = []
       @result = false
       @ttl = 300
     end
 
     def record_prio_ttl(qtype,qname,content,prio,ttl,auth=1)
        {:qtype => qtype, :qname => qname, :content => content, :priority => prio, :ttl => ttl, :auth => auth}
     end

     def record_prio(qtype,qname,content,prio,auth=1)
        record_prio_ttl(qtype,qname,content,prio,@ttl,auth)
     end

     def record(qtype,qname,content,auth=1)
        record_prio_ttl(qtype,qname,content,0,@ttl,auth)
     end
  
     def do_initialize(*args)
       @log << "Test bench initialized"
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
end 
