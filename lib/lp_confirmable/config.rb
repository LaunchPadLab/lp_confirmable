module LpConfirmable
  class Config

    # Number of days the confirmation token is active - default 14
    attr_accessor :token_lifetime

    # Number of characters of the confirmation token - default 20
    attr_accessor :token_length

    def initialize
      @token_lifetime = 14
      @token_length = 20
    end
  end
end
