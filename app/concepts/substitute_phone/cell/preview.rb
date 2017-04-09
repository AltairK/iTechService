class SubstitutePhone < ApplicationRecord
  module Cell
    class Preview < ModelCell
      delegate :presentation, :name, :serial_number, :imei, to: :item

      def can_manage?
        policy(model).manage?
      end

      private

      def item
        # @item ||= presenter_for(model.item, ItemDecorator)
        @item ||= ItemDecorator.new(model.item)
      end
    end
  end
end