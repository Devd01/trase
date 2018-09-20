module Api
  module V3
    module Dashboards
      class FilterDestinations < BaseFilter
        private

        def initialize_query
          @query = Api::V3::Readonly::Dashboards::Destination.
            select(
              :id,
              :name,
              :node_type
            ).
            group(:id, :name, :node_type)
        end
      end
    end
  end
end
