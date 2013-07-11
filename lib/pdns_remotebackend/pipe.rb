module PdnsRemotebackend
  class Pipe
    def initialize(klass, options = {})
      @handler = klass
    end
  
    def run
      h = @handler.new
      
      STDOUT.sync = true
      begin
        STDIN.each_line do |line|
          f.puts line
          # expect json
          input = {}
          line = line.strip
          next if line.empty?
          begin
            input = JSON.parse(line)
            method = "do_#{input["method"].downcase}"
            args = input["parameters"] || []

            h.result = false
            h.log = []
 
            if h.respond_to?(method.to_sym) == false
               res = false
            elsif args.size > 0
               h.send(method,args)
            else
               h.send(method)
            end

            puts ({:result => h.result, :log => h.log}).to_json
          rescue JSON::ParserError
            puts ({:result => false, :log => "Cannot parse input #{line}"}).to_json
            next
          end
        end
      rescue SystemExit, Interrupt
      end 
    end
  end
end
