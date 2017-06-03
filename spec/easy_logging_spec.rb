require "spec_helper"

require_relative 'test_class'

RSpec.describe EasyLogging do
  it "has a version number" do
    expect(EasyLogging::VERSION).not_to be nil
  end

  context "a class using EasyLogging" do
    it "has a logger field" do
      expect(TestClass.new.respond_to?(:logger)).to be(true)
    end
  end

end
