module LpConfirmable
  def self.config
    @config ||= Config.new
    yield @config
  end
end

require 'lp_confirmable/config'
require 'lp_confirmable/error'
require 'lp_confirmable/model'
require 'lp_confirmable/version'
