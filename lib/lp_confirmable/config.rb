module LpConfirmable
  class Config
    attr_accessor :token_lifetime, :token_length

    def initialize
      @token_lifetime = 2.weeks
      @token_length = 20
    end
  end
end
