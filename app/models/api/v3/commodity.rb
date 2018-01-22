module Api
  module V3
    class Commodity < BlueTable
      has_many :contexts

      def self.import_key
        [
          {name: :name, sql_type: 'TEXT'}
        ]
      end
    end
  end
end
