# Pdns/Remotebackend

This is a helper for PowerDNS remotebackend. It lets you create a backend with less hassle. Also supports pipe backend.

## Installation

Add this line to your application's Gemfile:

    gem 'pdns-remotebackend'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pdns-remotebackend

## Usage

Please see contrib/example.rb for example script. All methods and their arguments are described in detail at http://doc.powerdns.com/remotebackend.html. When your script
is called, the Handler class needs to have method with name do\_&lt;name-of-method;gt;(args). Such as do\_lookup(args). Any arguments are passed as hash to your handler. 

To get starting, subclass Pdns::Remotebackend::Handler. You need to override at least 'do\_lookup(args)' method. You are passed in arguments as

    args = { "qname" => "www.example.com", "qtype" => "ANY|SOA", .. + other stuff }

You are expected to modify object attribute 'result' to contain an array of records. The easiest way is to do 

    result = [ record("www.example.com","A","127.0.01") ]

This will construct a reply array with one resource record. 

Some methods expect non-array output, you can provide

    result = true
    result = { :foo => :bar } 

If you wish to log something, use 

    log &lt;&lt; "something I want logged".  

Should you need some parameters passed to the remotebackend connection string, you can always have a look at @parameters, which contains them.  

To start a pipe or unix server, do

    Pdns::Remotebackend::Pipe.new(MyHandlerClass).run
    Pdns::Remotebackend::Unix(MyHandlerClass, { :path => "/path/to/socket"} ).run

To use it with PowerDNS pipe backend, use

    Pdns::Remotebackend::Pipe.new(MyHandlerClass, { :abi => :pipe }).run
    Pdns::Remotebackend::Unix(MyHandlerClass, { :path => "/path/to/socket", :abi => :pipe } ).run

In this mode, it supports do\_lookup and do\_list. 

## Reference

In addition to stubs for remotebackend, the Pdns::Remotebackend::Handler has following helpers for making records

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

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
