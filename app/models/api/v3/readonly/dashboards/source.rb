# == Schema Information
#
# Table name: dashboards_sources_mv
#
#  id               :integer          primary key
#  name             :text
#  node_type_id     :integer
#  node_type        :text
#  parent_node_type :text
#  parent_name      :text
#  flow_id          :integer
#
# Indexes
#
#  index_dashboards_sources_mv_on_flow_id                    (flow_id)
#  index_dashboards_sources_mv_on_flow_id_and_id             (flow_id,id) UNIQUE
#  index_dashboards_sources_mv_on_id_and_name_and_node_type  (id,name,node_type)
#

module Api
  module V3
    module Readonly
      module Dashboards
        class Source < Api::V3::Readonly::BaseModel
          include Refresh

          self.table_name = 'dashboards_sources_mv'
          belongs_to :node

          def self.refresh(options = {})
            Scenic.database.refresh_materialized_view(
              'context_node_types_mv', concurrently: false
            )
            super(options)
          end
        end
      end
    end
  end
end
