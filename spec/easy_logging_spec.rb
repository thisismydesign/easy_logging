require "spec_helper"

RSpec.describe EasyLogging do
  it "has a version number" do
    expect(EasyLogging::VERSION).not_to be nil
  end

  before :each do
    class TestClass
      include EasyLogging
    end

    class TestClass2
      include EasyLogging
    end
  end

  context "instance of a class that includes EasyLogging" do
    it "has a logger" do
      expect(TestClass.new.respond_to?(:logger)).to be(true)
    end
  end

  context "class that includes EasyLogging" do
    it "has a logger" do
      expect(TestClass.respond_to?(:logger)).to be(true)
    end
  end

  context "instance level logger" do
    it "contains class name" do
      expect(TestClass.logger.progname).not_to eq(TestClass.class.name)
    end

    it "outputs class name" do
      expect { TestClass.new.logger.info }.to output(/.+#{TestClass.class.name}.+/).to_stdout_from_any_process
    end

    it "can log to STDOUT" do
      msg = "hi"
      expect { TestClass.new.logger.info(msg) }.to output(/.+#{msg}$/).to_stdout_from_any_process
    end

    it "is specific to the class" do
      expect(TestClass.new.logger.__id__).not_to eq(TestClass2.new.logger.__id__)
    end
  end

  context "class level logger" do
    it "contains class name" do
      expect(TestClass.logger.progname).not_to eq(TestClass.class.name)
    end
    
    it "outputs class name" do
      expect { TestClass.logger.info }.to output(/.+#{TestClass.class.name}.+/).to_stdout_from_any_process
    end

    it "can log to STDOUT" do
      msg = "hi"
      expect { TestClass.logger.info(msg) }.to output(/.+#{msg}$/).to_stdout_from_any_process
    end

    it "is specific to the class" do
      expect(TestClass.logger.__id__).not_to eq(TestClass2.logger.__id__)
    end
  end

end
