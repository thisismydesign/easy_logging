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

    it 'is not polluted by module variables' do
      expect(TestClass.new.respond_to?(:level)).to be(false)
      expect(TestClass.new.respond_to?(:log_destination)).to be(false)
    end

    it 'does not interfere with super without parameters' do
      class NoInitializeParams; def initialize; end end

      class TestInitialize < NoInitializeParams
        include EasyLogging
        def initialize(param)
          super()
        end
      end

      expect_any_instance_of(NoInitializeParams).to receive(:initialize)

      TestInitialize.new('param')
    end

    it 'does not interfere with super with parameters' do
      class InitializeParams; def initialize(param); end end

      class TestInitializeWithParams < InitializeParams
        include EasyLogging
        def initialize(param)
          super
        end
      end
      param = :param

      expect_any_instance_of(InitializeParams).to receive(:initialize).with(param)

      TestInitializeWithParams.new(param)
    end
  end

  describe 'class that includes EasyLogging' do
    it 'has a logger' do
      expect(TestClass.respond_to?(:logger)).to be(true)
    end

    it 'is not polluted by module variables' do
      expect(TestClass.respond_to?(:level)).to be(false)
      expect(TestClass.respond_to?(:log_destination)).to be(false)
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
      end
    end
  end

  describe 'level selection' do

    after :each do
      EasyLogging.level = Logger::INFO
    end

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

  describe 'formatter selection' do
    let(:formatter) do
      proc do |severity, datetime, progname, msg|
        severity + datetime + progname + msg
      end
    end

    after :each do
      EasyLogging.formatter = nil
    end

    it 'has a level setting of INFO by default' do
      expect(TestClass.logger.formatter).to eq(nil)
    end

    it 'remembers selected formatter' do
      easy_clone = EasyLogging.clone
      easy_clone.formatter = formatter
      expect(easy_clone.formatter).to eq(formatter)
    end

    it 'retains formatter between includes' do
      EasyLogging.formatter = formatter
      class TestFormatterRetain; end
      TestFormatterRetain.send(:include, EasyLogging)

      class TestFormatterRetain2; end
      TestFormatterRetain2.send(:include, EasyLogging)

      expect(TestFormatterRetain.logger.formatter).to eq(formatter)
      expect(TestFormatterRetain2.logger.formatter).to eq(formatter)
    end
  end

  describe 'on the fly modification of logger configuration' do
    let(:old_level) { Logger::WARN }
    let(:new_level) { Logger::ERROR }

    after :each do
      EasyLogging.level = Logger::INFO
    end

    context 'class level logger' do
      it 'uses old config if EasyLogging was included before config change' do
        EasyLogging.level = old_level
        class TestConfigChange1; end
        TestConfigChange1.send(:include, EasyLogging)

        EasyLogging.level = new_level

        expect(TestConfigChange1.logger.level).to eq(old_level)
      end

      it 'uses new config if EasyLogging was included after config change' do
        EasyLogging.level = old_level
        class TestConfigChange2; end

        EasyLogging.level = new_level
        TestConfigChange2.send(:include, EasyLogging)

        expect(TestConfigChange2.logger.level).to eq(new_level)
      end
    end

    context 'instance level logger' do
      it 'uses old config if instance was created before config change' do
        EasyLogging.level = old_level
        class TestConfigChange3; end
        TestConfigChange3.send(:include, EasyLogging)

        instance = TestConfigChange3.new
        EasyLogging.level = new_level

        expect(instance.logger.level).to eq(old_level)
      end

      it 'uses new config if instance was created after config change' do
        EasyLogging.level = old_level
        class TestConfigChange4; end
        TestConfigChange4.send(:include, EasyLogging)

        EasyLogging.level = new_level
        instance = TestConfigChange4.new

        expect(instance.logger.level).to eq(new_level)
      end
    end
  end
end
