require 'spec_helper'

describe PdnsRemotebackend::Handler, "#do_initialize" do
  it "should return true for initialize" do
     h = PdnsRemotebackend::Handler.new
     h.do_initialize
     h.result.should eq true
  end
end
