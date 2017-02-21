require 'minitest/autorun'
require 'lp_confirmable'

def days(duration=1)
  duration * 60 * 60 * 24
end

CONFIRM_COLS = %w(
  confirmation_token
  confirmed_at
  confirmation_sent_at
)

class MockActiveRecord
  def self.column_names
    []
  end

  def self.find_by(**kwargs)
    MockActiveRecord.new
  end

  def update_columns(**kwargs)
    kwargs.each { |k, v| send("#{k}=", v) }
  end
end

class MockConfirmable < MockActiveRecord
  attr_accessor *CONFIRM_COLS

  def self.column_names
    CONFIRM_COLS
  end

  def self.find_by(**kwargs)
    confirmable = MockConfirmable.new
    confirmable.confirmation_token = kwargs[:confirmation_token]

    if kwargs[:confirmation_token] == 'expired'
      confirmable.confirmation_sent_at = Time.now - 1000 * days
    end

    if kwargs[:confirmation_token] == 'active'
      confirmable.confirmation_sent_at = Time.now - 1 * days
    end

    confirmable
  end
end

describe LpConfirmable::Config do
  it 'has defaults' do
    assert LpConfirmable.config.token_lifetime
    assert LpConfirmable.config.token_length
  end

  it 'can be set' do
    default_token_lifetime = LpConfirmable.config.token_lifetime
    new_token_lifetime = default_token_lifetime + 5
    LpConfirmable.config do |config|
      config.token_lifetime = new_token_lifetime
    end
    assert_equal LpConfirmable.config.token_lifetime, new_token_lifetime
  end
end

LPC = LpConfirmable::Model

describe LpConfirmable::Model do

  before do
    LpConfirmable.config do |config|
      config.token_lifetime = 14
      config.token_length = 20
    end
  end

  describe '#confirmable?' do

    it 'anything' do
      refute LPC.confirmable? String
    end

    it 'active record' do
      refute LPC.confirmable? MockActiveRecord
    end

    it 'confirmable' do
      assert LPC.confirmable? MockConfirmable
    end
  end

  describe '#check_confirmable!' do

    it 'anything' do
      assert_raises LpConfirmable::Error do
        LPC.check_confirmable! String
      end
    end

    it 'active record' do
      assert_raises LpConfirmable::Error do
        LPC.check_confirmable! MockActiveRecord
      end
    end

    it 'confirmable' do
      assert_nil LPC.check_confirmable!(MockConfirmable)
    end
  end

  describe '#token_active?' do
    before do
      @confirmable_model = MockConfirmable.new
    end

    it 'when token does not exist' do
      refute LPC.token_active?(@confirmable_model)
    end

    it 'when token sent at does not exist' do
      @confirmable_model.confirmation_token = 'foo'
      refute LPC.token_active?(@confirmable_model)
    end

    it 'when token expired' do
      LpConfirmable.config { |config| config.token_lifetime = 14 }
      @confirmable_model.confirmation_token = 'foo'
      @confirmable_model.confirmation_sent_at = Time.now - (21 * days)
      refute LPC.token_active?(@confirmable_model)
    end

    it 'when token active' do
      LpConfirmable.config { |config| config.token_lifetime = 14 }
      @confirmable_model.confirmation_token = 'foo'
      @confirmable_model.confirmation_sent_at = Time.now - (7 * days)
      assert LPC.token_active?(@confirmable_model)
    end
  end

  describe '#check_token_active!' do
    before do
      @confirmable_model = MockConfirmable.new
    end

    it 'when token not active' do
      assert_raises LpConfirmable::Error do
        LPC.check_token_active!(@confirmable_model)
      end
    end

    it 'when model not found' do
      assert_raises LpConfirmable::Error do
        LPC.check_token_active!(nil)
      end
    end

    it 'when token active' do
      LpConfirmable.config { |config| config.token_lifetime = 14 }
      @confirmable_model.confirmation_token = 'foo'
      @confirmable_model.confirmation_sent_at = Time.now - (7 * days)
      assert_nil LPC.check_token_active!(@confirmable_model)
    end
  end

  describe '#confirmation_not_sent?' do
    before do
      @confirmable_model = MockConfirmable.new
    end

    it 'when not sent' do
      assert LPC.confirmation_not_sent?(@confirmable_model)
    end

    it 'when sent' do
      @confirmable_model.confirmation_sent_at = Time.now - (7 * days)
      refute LPC.confirmation_not_sent?(@confirmable_model)
    end
  end

  describe '#check_confirmation_not_sent!' do
    before do
      @confirmable_model = MockConfirmable.new
    end

    it 'when not sent' do
      assert_nil LPC.check_confirmation_not_sent!(@confirmable_model)
    end

    it 'when sent' do
      @confirmable_model.confirmation_sent_at = Time.now - (7 * days)
      assert_raises LpConfirmable::Error do
        LPC.check_confirmation_not_sent!(@confirmable_model)
      end
    end
  end

  describe '#set_confirmation_token!' do

    describe 'when not confirmable' do
      before do
        @model = MockActiveRecord.new
      end

      it 'raises' do
        assert_raises LpConfirmable::Error do
          LPC.set_confirmation_token!(@model)
        end
      end
    end

    describe 'when confirmable' do
      before do
        @model = MockConfirmable.new
      end

      it 'sets the confirmation token to the configured length' do
        LPC.set_confirmation_token! @model
        assert_equal @model.confirmation_token.length, LpConfirmable.config.token_length
      end

      it 'sets confirmed at time to nil' do
        LPC.set_confirmation_token! @model
        assert_nil @model.confirmed_at
      end

      it 'sets confirmation sent at time to nil' do
        LPC.set_confirmation_token! @model
        assert_nil @model.confirmation_sent_at
      end

      it 'returns the confirmation token' do
        token = LPC.set_confirmation_token! @model
        assert_equal token, @model.confirmation_token
      end

      describe 'when token length is provided' do
        it 'sets the confirmation token to the provided length' do
          LPC.set_confirmation_token! @model, 40
          assert_equal @model.confirmation_token.length, 40
        end
      end
    end

    describe '#confirm_by_token!' do

      describe 'when not confirmable' do
        before do
          @klass = MockActiveRecord
          @token = 'foo'
        end

        it 'raises' do
          assert_raises LpConfirmable::Error do
            LPC.confirm_by_token!(@klass, @token)
          end
        end
      end

      describe 'when expired' do
        before do
          @klass = MockConfirmable
          @token = 'expired'
        end

        it 'raises' do
          assert_raises LpConfirmable::Error do
            LPC.confirm_by_token!(@klass, @token)
          end
        end
      end

      describe 'when active' do
        before do
          @klass = MockConfirmable
          @token = 'active'
        end

        it 'returns the model' do
          model = LPC.confirm_by_token!(@klass, @token)
          assert_instance_of MockConfirmable, model
        end

        it 'sets the confirmation token to nil' do
          model = LPC.confirm_by_token!(@klass, @token)
          assert_equal model.confirmation_token, @token
        end

        it 'sets the confirmed at time to now' do
          model = LPC.confirm_by_token!(@klass, @token)
          assert_in_delta model.confirmed_at, Time.now, 1
        end
      end
    end

    describe '#send_confirmation_instructions!' do

      describe 'when not confirmable' do
        before do
          @model = MockActiveRecord.new
        end

        it 'raises' do
          assert_raises LpConfirmable::Error do
            LPC.send_confirmation_instructions!(@model)
          end
        end
      end

      describe 'when confirmation sent' do
        before do
          @model = MockConfirmable.new
          @model.confirmation_token = 'foo'
          @model.confirmation_sent_at = Time.now
        end

        it 'raises' do
          assert_raises LpConfirmable::Error do
            LPC.send_confirmation_instructions!(@model)
          end
        end
      end

      describe 'when confirmation not sent' do
        before do
          @model = MockConfirmable.new
          @model.confirmation_token = 'foo'
        end

        it 'sets confirmation sent at' do
          LPC.send_confirmation_instructions!(@model)
          assert_in_delta @model.confirmation_sent_at, Time.now, 1
        end

        it 'calls the block if given' do
          @mock_block = Minitest::Mock.new
          @mock_block.expect(:foo, 'bar')
          LPC.send_confirmation_instructions! @model do
            @mock_block.foo
          end
          @mock_block.verify
        end
      end
    end
  end
end
