module LpConfirmable
  module Generators
    class LpConfirmableGenerator < NamedBase
      include Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      desc 'Creates an LpConfirmable migration for the specified model.'

      argument :model, optional: true, type: :string, default: 'User', banner: 'model'

      migration_template 'migration.rb', "db/migrate/add_lp_confirmable_to_#{model_class_name}.rb"

      def model_class_name
        options[:model] ? options[:model].classify : 'User'
      end
    end
  end
end
