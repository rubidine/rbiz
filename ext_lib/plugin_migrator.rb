module ActiveRecord
  class PluginMigrator < Migrator

    def initialize(direction, migrations_path, target_version = nil)
      raise StandardError.new("This database does not yet support migrations") unless Base.connection.supports_migrations?
      Base.connection.initialize_schema_migrations_table(ActiveRecord::PluginMigrator)
      @direction, @migrations_path, @target_version = direction, migrations_path, target_version
    end

    def self.schema_migrations_table_name
      'plugin_schema_migrations_cart'
    end
  end
end

module ActiveRecord
  module ConnectionAdapters
    module SchemaStatements

      def initialize_schema_migrations_table migrator=ActiveRecord::Migrator
        sm = migrator.schema_migrations_table_name

        unless tables.detect{|t| t == sm}
          create_table(sm, :id => false) do |t|
            t.column :version, :string, :null => false
          end
          add_index sm, :version, :unique => true, :name => 'unique_schema_migrations_cart'

          # find old style migrations table and bring it up to date!
          si = sm.gsub(/schema_migrations/, 'schema')
          if tables.detect{|t| t == si}
            old_version = select_value("SELECT version FROM #{quote_table_name(si)}")
            assume_migrated_upto_version(old_version, sm)
            drop_table(si)
          end
        end
      end

      def assume_migrated_upto_version(version, migration_table)
        migrated = select_values("SEELCT version FROM #{migration_table}")
        migrated.map!{|x| x.to_i}
        vv = Dir["#{File.dirname(__FILE__)}/../db/migrate/[0-9]*_*.rb"].map do |f|
          f.split('/').last.split('_').first.to_i
        end
        execute "INSERT INTO #{migration_table} (version) VALUES ('#{version}')" unless migrated.include?(version.to_i)
        (vv - migrated).select{|x| x < version.to_i}.each do |v|
          execute "INSERT INTO #{migration_table} (version) VALUES ('#{v}')"
        end
      end

    end
  end
end
