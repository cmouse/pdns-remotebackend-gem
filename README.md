# Pdns/Remotebackend

This is a helper for PowerDNS remotebackend. It lets you create a backend with less hassle. 

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

You are expected to modify object attribute 'result' to contain an array of records. The easiest way is to do result = [ record("www.example.com","A","127.0.01") ]
This will construct a reply array with one resource record. 

Some methods expect non-array output, you can provide result = true or result = 1 etc. for these. 

If you wish to log something, use @log &lt;&lt; "something I want logged".  

Should you need some parameters passed to the remotebackend connection string, you can always have a look at @parameters, which contains them.  

To start a pipe or unix server, do

  Pdns::Remotebackend::Pipe.new(MyHandlerClass).run
  Pdns::Remotebackend::Unix(MyHandlerClass, { :path => "/path/to/socket").run

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
