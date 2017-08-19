require 'spec_helper'
require 'tempfile'

RSpec.describe EasyLogging do
  it 'has a version number' do
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

  describe 'instance of a class that includes EasyLogging' do
    it 'has a logger' do
      expect(TestClass.new.respond_to?(:logger)).to be(true)
    end
  end

  describe 'class that includes EasyLogging' do
    it 'has a logger' do
      expect(TestClass.respond_to?(:logger)).to be(true)
    end
  end

  describe 'instance level logger' do
    it 'contains class name' do
      expect(TestClass.logger.progname).not_to eq(TestClass.class.name)
    end

    it 'outputs class name' do
      expect { TestClass.new.logger.info }.to output(/.+#{TestClass.class.name}.+/).to_stdout_from_any_process
    end

    it 'can log to STDOUT' do
      msg = 'hi'
      expect { TestClass.new.logger.info(msg) }.to output(/.+#{msg}$/).to_stdout_from_any_process
    end

    it 'is specific to the class' do
      expect(TestClass.new.logger.__id__).not_to eq(TestClass2.new.logger.__id__)
    end
  end

  describe 'class level logger' do
    it 'contains class name' do
      expect(TestClass.logger.progname).not_to eq(TestClass.class.name)
    end

    it 'outputs class name' do
      expect { TestClass.logger.info }.to output(/.+#{TestClass.class.name}.+/).to_stdout_from_any_process
    end

    it 'can log to STDOUT' do
      msg = 'hi'
      expect { TestClass.logger.info(msg) }.to output(/.+#{msg}$/).to_stdout_from_any_process
    end

    it 'is specific to the class' do
      expect(TestClass.logger.__id__).not_to eq(TestClass2.logger.__id__)
    end
  end

  describe 'output destination selection' do

    it 'logs to STDOUT by default' do
      expect(get_device(TestClass.logger).inspect.include?('STDOUT')).to be true
    end

    it 'remembers selected output destination' do
      easy_clone = EasyLogging.clone
      easy_clone.log_destination = 'test'
      expect(easy_clone.log_destination).to eq 'test'
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

        it 'can log to file' do
          EasyLogging.log_destination = log_file.path
          class TestLogFile;end
          TestLogFile.send(:include, EasyLogging)

          msg = 'hi'
          TestLogFile.logger.info(msg)
          expect(log_file.read).to match(/.+#{msg}$/)
        end

        it 'retains `log_destination` between includes' do
          log = log_file.path
          EasyLogging.log_destination = log
          class TestDestinationRetain; end
          TestDestinationRetain.send(:include, EasyLogging)

          class TestDestinationRetain2; end
          TestDestinationRetain2.send(:include, EasyLogging)

          expect(get_device(TestDestinationRetain.logger).path).to eq(log)
          expect(get_device(TestDestinationRetain2.logger).path).to eq(log)
        end

        context 'on the fly modification of logger configuration' do

          let(:old_log) { STDOUT }
          let(:new_log) { log_file.path }

          context 'modification of `EasyLogging.log_destination`' do
            it 'uses new log_destination in new and not yet used loggers' do
              EasyLogging.log_destination = old_log
              class TestDirectLogChange;end
              TestDirectLogChange.send(:include, EasyLogging)

              class TestDirectLogChange2;end
              EasyLogging.log_destination = new_log
              TestDirectLogChange2.send(:include, EasyLogging)

              expect(get_device(TestDirectLogChange2.logger).path).to eq(new_log)
              expect(get_device(TestDirectLogChange.logger).path).to eq(new_log)
            end

            # TODO this is unexplained behaviour
            it 'uses old log_destination in already used loggers' do
              EasyLogging.log_destination = old_log
              class TestDirectLogChange3;end
              TestDirectLogChange3.send(:include, EasyLogging)

              # 'Use' logger
              TestDirectLogChange3.logger

              class TestDirectLogChange4;end
              EasyLogging.log_destination = new_log
              TestDirectLogChange4.send(:include, EasyLogging)

              expect(get_device(TestDirectLogChange4.logger).path).to eq(new_log)
              expect(get_device(TestDirectLogChange3.logger).inspect.include?('STDOUT')).to be true
            end
          end
        end
      end
    end
  end

  context 'level selection' do
    it 'has a level setting of INFO by default' do
      expect(TestClass.logger.level).to eq(Logger::Severity::INFO)
    end

    it 'remembers selected level' do
      easy_clone = EasyLogging.clone
      easy_clone.level = Logger::Severity::DEBUG
      expect(easy_clone.level).to eq(Logger::Severity::DEBUG)
    end

    it 'retains `level` between includes' do
      EasyLogging.level = Logger::Severity::DEBUG
      class TestLevelRetain; end
      TestLevelRetain.send(:include, EasyLogging)

      class TestLevelRetain2; end
      TestLevelRetain2.send(:include, EasyLogging)

      expect(TestLevelRetain.logger.level).to eq(Logger::Severity::DEBUG)
      expect(TestLevelRetain2.logger.level).to eq(Logger::Severity::DEBUG)
    end
  end
end
