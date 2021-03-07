include RbCommonHelper

class RbTasksController < RbApplicationController
  unloadable

  def create
    @settings = Backlogs.settings
    @task = nil
    begin
      @task  = RbTask.create_with_relationships(tasks_params.to_unsafe_h, User.current.id, @project.id)
    rescue => e
      render :text => e.message.blank? ? e.to_s : e.message, :status => 400
      return
    end

    result = @task.errors.size
    status = (result == 0 ? 200 : 400)
    @include_meta = true

    respond_to do |format|
      format.html { render :partial => "task", :object => @task, :status => status }
    end
  end

  def update
    @task = RbTask.find_by_id(tasks_params[:id])
    @settings = Backlogs.settings
    result = @task.update_with_relationships(tasks_params.to_unsafe_h)
    status = (result ? 200 : 400)
    @include_meta = true

    @task.story.story_follow_task_state if @task.story

    respond_to do |format|
      format.html { render :partial => "task", :object => @task, :status => status }
    end
  end

  private
    def tasks_params
      params.permit(:id, :subject, :description, :assigned_to_id, :priority_id, :remaining_hours, :parent_issue_id, :status_id, :project_id)
    end
end
