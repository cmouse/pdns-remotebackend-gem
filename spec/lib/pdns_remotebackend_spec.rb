require 'spec_helper'

describe Pdns::Remotebackend::Handler, "#do_initialize" do
  it "should return true for initialize" do
     h = Pdns::Remotebackend::Handler.new
     h.do_initialize
     h.result.should eq true
  end
end
