module Api
  module V1

    class QuickTasksController < Api::BaseController
      #load_and_authorize_resource

      def index
        respond_with @quick_tasks
      end

    end

  end
end