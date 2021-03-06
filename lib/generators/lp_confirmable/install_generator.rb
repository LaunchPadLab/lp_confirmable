module LpConfirmable
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates a LpConfirmable initializer in your application.'

      def copy_initializer
        copy_file 'initializer.rb', 'config/initializers/lp_confirmable.rb'
      end
    end
  end
end
