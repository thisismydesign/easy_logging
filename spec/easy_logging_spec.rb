require "spec_helper"
require 'tempfile'

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

  context 'selective output destination' do

    it "logs to STDOUT by default" do
      expect(get_device(TestClass.logger).inspect.include?("STDOUT")).to be true
    end

    it 'remembers selected output destination' do
      easy_clone = EasyLogging.clone
      easy_clone.log_destination = 'test'
      expect(easy_clone.log_destination).to eq 'test'
    end

    it "reads log destination from `LOGFILE` environment variable if available" do
      logfile_path = 'easy_logging'
      logfile_env_entry = {'LOGFILE'=>logfile_path}
      stub_const('ENV',mocked_env_with(logfile_env_entry))
      easy_clone = EasyLogging.clone

      expect(easy_clone.log_destination).to eq logfile_path
    end

    context 'messing with log_destination settings directly' do

      after :each do
        EasyLogging.log_destination = nil
      end

      context 'logging to files' do

        let(:log_file) { Tempfile.new('easy_logging') }

        after :each do
          log_file.close
          log_file.unlink
        end

        it "can log to file" do
          EasyLogging.log_destination = log_file.path
          class TestLogFile;end
          TestLogFile.send(:include, EasyLogging)

          msg = 'hi'
          TestLogFile.logger.info(msg)
          expect(log_file.read).to match(/.+#{msg}$/)
        end

        context "on the fly modification of `log_destination`" do

          it "uses new log_destination in every logger even already created ones" do
            old_log = STDOUT
            new_log = log_file.path

            EasyLogging.log_destination = old_log
            class TestLogChange;end
            TestLogChange.send(:include, EasyLogging)

            class TestLogChange2;end
            EasyLogging.log_destination = new_log
            TestLogChange2.send(:include, EasyLogging)

            expect(get_device(TestLogChange2.logger).path).to eq(new_log)
            expect(get_device(TestLogChange.logger).path).to eq(new_log)
          end

        end

        it "retains `log_destination` between includes" do
          log = log_file.path
          EasyLogging.log_destination = log
          class TestRetain;end
          TestRetain.send(:include, EasyLogging)

          class TestRetain2;end
          TestRetain2.send(:include, EasyLogging)
          
          expect(get_device(TestRetain.logger).path).to eq(log)
          expect(get_device(TestRetain2.logger).path).to eq(log)
        end
      end
    end
  end
end
