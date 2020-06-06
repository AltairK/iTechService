module Service
  class FreeJobsController < ApplicationController
    skip_after_action :verify_authorized
    respond_to :html

    def index
      free_jobs = policy_scope(FreeJob).includes(:performer)

      if params[:date].present?
        free_jobs = free_jobs.performed_on(params[:date].to_date)
      end

      if params[:performer].present?
        performer = params[:performer].mb_chars.downcase.to_s
        free_jobs = free_jobs.where('LOWER(name) LIKE :p OR LOWER(surname) LIKE :p', p: performer).references(:users)
      end

      if params[:department_id].present? && policy(FreeJob).view_everywhere?
        free_jobs = free_jobs.in_department(params[:department_id])
      end

      free_jobs = free_jobs.new_first.page(params[:page])
      content = cell(FreeJob::Cell::Index, free_jobs).call

      respond_to do |format|
        format.html { return render(html: content, layout: true) }
        format.js { return render('index', locals: {content: content}) }
      end
    end

    def new
      run FreeJob::Create::Present do
        return render_form
      end
      failed
    end

    def create
      run FreeJob::Create do
        return redirect_to operation_model
      end
      flash.alert = operation_message
      render_form
    end

    def show
      run FreeJob::Show do
        return render_cell FreeJob::Cell::Show
      end
      failed
    end

    def edit
      run FreeJob::Update::Present do
        return render_form
      end
      failed
    end

    def update
      run FreeJob::Update do
        return redirect_to_index
      end
      render_form
    end

    def destroy
      run FreeJob::Destroy do
        return redirect_to_index notice: operation_message
      end
      failed
    end

    def performer_options
      task = FreeTask.find(params[:task_id])
      render partial: 'performer_options', locals: {performers: task.possible_performers}
    end

    private

    def render_form
      tasks = FreeTask.all.order(:name)
      render_cell FreeJob::Cell::Form, tasks: tasks
    end
  end
end
