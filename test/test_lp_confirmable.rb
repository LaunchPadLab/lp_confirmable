require 'minitest/autorun'
require 'lp_confirmable'

def make_mock(**kwargs)
  mock = MiniTest::Mock.new
  kwargs.each { |k, v| mock.expect(k, v) }
  mock
end

def mock_confirmable_class
  make_mock column_names: %w(
    confirmation_token
    confirmed_at
    confirmation_sent_at
  )
end

def mock_confirmable_model
  make_mock class: mock_confirmable_class
end

describe LpConfirmable::Model do

  before do
    @lpc = LpConfirmable::Model
  end

  describe '#confirmable?' do

    it 'confirmable' do
      assert @lpc.confirmable? mock_confirmable_class
    end

    it 'anything else' do
      refute @lpc.confirmable? String
    end
  end

  describe '#check_confirmable!' do

    it 'confirmable' do
      assert_nil @lpc.check_confirmable! mock_confirmable_class
    end

    it 'anything else' do
      assert_raises LpConfirmable::Error do
        @lpc.check_confirmable! String
      end
    end
  end

  describe '#token_active?' do

  end

  describe '#check_token_active!' do

  end
end
