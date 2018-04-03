# Downloads dump from S3 and restores to current database
module Api
  module V3
    module DatabaseImport
      class Importer
        include CacheUtils

        IMPORT_DIR = 'tmp/import'.freeze
        INSTANCE_NAME = ENV['INSTANCE_NAME']
        API_HOST = ENV['API_HOST']

        def initialize(s3_filename)
          raise 'Invalid S3 object name' unless s3_filename.match?(/\w+\/.+\.dump\.gz/)
          @s3_filename = s3_filename
          @filename = s3_filename.split('/').last
          @local_filename = IMPORT_DIR + '/' + @filename
        end

        # @param s3_filename [String]
        def call
          Rails.logger.debug "Starting import #{@s3_filename}"
          FileUtils.mkdir_p(IMPORT_DIR) unless File.directory?(IMPORT_DIR)

          download_from_s3(@s3_filename, @local_filename)
          Rails.logger.debug 'Download completed'

          restore(@local_filename)

          clear_cache
        ensure
          FileUtils.rm_f Dir.glob("#{IMPORT_DIR}/*") if dir_exists?
        end

        private

        def download_from_s3(s3_filename, local_filename)
          metadata = Api::V3::S3Downloader.instance.call(s3_filename, local_filename)
          Rails.logger.debug 'Database downloaded'
          schema_version = ActiveRecord::Migrator.current_version.to_s
          schema_match = (metadata['schema_version'] == schema_version)
          return if schema_match
          raise "Incompatible schema version #{metadata['schema_version']}, \
cannot restore"
        end

        def restore(local_filename)
          exporter = Api::V3::DatabaseExport::Exporter.new
          exporter.call(
            keep_local_copy: true
          )
          backup_local_filename = exporter.local_filename
          config = Rails.configuration.database_configuration
          env_config = config[Rails.env]
          active_db_name = env_config['database']
          pg_tasks = ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(env_config)
          begin
            pg_tasks.data_restore(local_filename, active_db_name)
            Rails.logger.debug 'Database restored to new version'
          rescue
            # restore database to previous version using local backup
            pg_tasks.data_restore(backup_local_filename, active_db_name)
            Rails.logger.debug 'Database restored to previous version'
            raise
          end
        end

        def clear_cache
          clear_cache_for_regexp_with_uri('/api/v3/', API_HOST)
          clear_cache_for_regexp_with_uri('/content/', API_HOST)
          Dictionary::Ind.instance.reset
          Dictionary::Qual.instance.reset
          Dictionary::Quant.instance.reset
        end

        def dir_exists?
          File.directory?(IMPORT_DIR)
        end
      end
    end
  end
end
