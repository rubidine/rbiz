module ActiveRecord
  class RbizMigrator < Migrator

    def initialize(direction, migrations_path, target_version = nil)
      raise StandardError.new("This database does not yet support migrations") unless Base.connection.supports_migrations?
      Base.connection.initialize_schema_migrations_table(ActiveRecord::RbizMigrator) unless Rails::VERSION::MINOR < 2
      @direction, @migrations_path, @target_version = direction, migrations_path, target_version
    end

    def self.schema_migrations_table_name
      'plugin_schema_migrations_rbiz'
    end

    if Rails::VERSION::MINOR < 2
      def self.migrate migrations_path, target_version=nil
        Base.connection.initialize_schema_information(ActiveRecord::RbizMigrator)

        case
        when target_version.nil?, current_version < target_version
          up(migrations_path, target_version)
        when current_version > target_version
          down(migrations_path, target_version)
        when current_version == target_version
          return # You're on the right version
        end
      end

      def self.schema_info_table_name
        'plugin_schema_rbiz'
      end
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
        migrated = select_values("SELECT version FROM #{migration_table}")
        migrated.map!{|x| x.to_i}
        vv = Dir["#{File.dirname(__FILE__)}/../db/migrate/[0-9]*_*.rb"].map do |f|
          f.split('/').last.split('_').first.to_i
        end
        execute "INSERT INTO #{migration_table} (version) VALUES ('#{version}')" unless migrated.include?(version.to_i)
        (vv - migrated).select{|x| x < version.to_i}.each do |v|
          execute "INSERT INTO #{migration_table} (version) VALUES ('#{v}')"
        end
      end

      if Rails::VERSION::MINOR < 2
        def initialize_schema_information migrator=ActiveRecord::Migrator
          begin
            execute "CREATE TABLE #{migrator.schema_info_table_name} (version #{type_to_sql(:integer)})"
            execute "INSERT INTO #{migrator.schema_info_table_name} (version) VALUES(0)"
          rescue ActiveRecord::StatementInvalid
            # Schema has been intialized
          end
        end
      end

    end
  end
end
