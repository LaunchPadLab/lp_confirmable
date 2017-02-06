module LpConfirmable
  def self.config
    @config ||= LpConfirmable::Config.new
    if block_given?
      yield @config
    else
      @config
    end
  end
end

require 'lp_confirmable/config'
require 'lp_confirmable/error'
require 'lp_confirmable/model'
require 'lp_confirmable/version'
