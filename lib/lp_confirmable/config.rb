module LpConfirmable
  class Config
    attr_accessor :token_lifetime

    def initialize
      @token_lifetime = 2.weeks
    end
  end
end
