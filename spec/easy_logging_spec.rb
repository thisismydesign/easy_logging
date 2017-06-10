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

        context "on the fly modification of logger configuration" do

          let(:old_log) { STDOUT }
          let(:new_log) { log_file.path }

          context "modification of `EasyLogging.log_destination`" do
            it "uses new log_destination in new and not yet used loggers" do
              EasyLogging.log_destination = old_log
              class TestDirectLogChange3;end
              TestDirectLogChange3.send(:include, EasyLogging)

              class TestDirectLogChange4;end
              EasyLogging.log_destination = new_log
              TestDirectLogChange4.send(:include, EasyLogging)

              expect(get_device(TestDirectLogChange4.logger).path).to eq(new_log)
              expect(get_device(TestDirectLogChange3.logger).path).to eq(new_log)
            end

            # TODO this is unexplained behaviour
            it "uses old log_destination in already used loggers" do
              EasyLogging.log_destination = old_log
              class TestDirectLogChange;end
              TestDirectLogChange.send(:include, EasyLogging)

              # 'Use' logger
              TestDirectLogChange.logger

              class TestDirectLogChange2;end
              EasyLogging.log_destination = new_log
              TestDirectLogChange2.send(:include, EasyLogging)

              expect(get_device(TestDirectLogChange2.logger).path).to eq(new_log)
              expect(get_device(TestDirectLogChange.logger).inspect.include?("STDOUT")).to be true
            end

          end

          context "modification of environment variable" do

            it "uses new log_destination in new and not yet used loggers" do
              logfile_env_entry = {'LOGFILE'=>old_log}
              stub_const('ENV',mocked_env_with(logfile_env_entry))

              class TestEnvChange;end
              TestEnvChange.send(:include, EasyLogging)

              logfile_env_entry = {'LOGFILE'=>new_log}
              stub_const('ENV',mocked_env_with(logfile_env_entry))

              class TestEnvChange2;end
              TestEnvChange2.send(:include, EasyLogging)

              expect(get_device(TestEnvChange2.logger).path).to eq(new_log)
              expect(get_device(TestEnvChange.logger).path).to eq(new_log)
            end

            # TODO this is unexplained behaviour
            it "uses old log_destination in already used loggers" do
              logfile_env_entry = {'LOGFILE'=>old_log}
              stub_const('ENV',mocked_env_with(logfile_env_entry))

              class TestEnvChange3;end
              TestEnvChange3.send(:include, EasyLogging)

              # 'Use' logger
              TestEnvChange3.logger

              logfile_env_entry = {'LOGFILE'=>new_log}
              stub_const('ENV',mocked_env_with(logfile_env_entry))

              class TestEnvChange4;end
              TestEnvChange4.send(:include, EasyLogging)

              expect(get_device(TestEnvChange4.logger).path).to eq(new_log)
              expect(get_device(TestEnvChange3.logger).inspect.include?("STDOUT")).to be true
            end
          end

          context "modification of both `EasyLogging.log_destination` and environment variable" do
            it "modification of `EasyLogging.log_destination` will overwrite environment variable setting" do
              logfile_env_entry = {'LOGFILE'=>old_log}
              stub_const('ENV',mocked_env_with(logfile_env_entry))

              class TestDirectAndEnvChange;end
              TestDirectAndEnvChange.send(:include, EasyLogging)

              EasyLogging.log_destination = new_log
              class TestDirectAndEnvChange2;end
              TestDirectAndEnvChange2.send(:include, EasyLogging)

              expect(get_device(TestDirectAndEnvChange2.logger).path).to eq(new_log)
              expect(get_device(TestDirectAndEnvChange.logger).path).to eq(new_log)
            end

            it "modification of environment variable will NOT overwrite `EasyLogging.log_destination` setting" do
              EasyLogging.log_destination = old_log
              class TestDirectAndEnvChange3;end
              TestDirectAndEnvChange3.send(:include, EasyLogging)

              logfile_env_entry = {'LOGFILE'=>new_log}
              stub_const('ENV',mocked_env_with(logfile_env_entry))
              class TestDirectAndEnvChange4;end
              TestDirectAndEnvChange4.send(:include, EasyLogging)

              expect(get_device(TestDirectAndEnvChange4.logger).inspect.include?("STDOUT")).to be true
              expect(get_device(TestDirectAndEnvChange3.logger).inspect.include?("STDOUT")).to be true
            end
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
