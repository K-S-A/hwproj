class SubmissionsController < ApplicationController
  def new
    @submission = Submission.new
    unless params[:problem_id].nil?
      @submission.task = Task.where(user_id: current_user.id, problem_id: params[:problem_id]).first
    else
      @submission.task = Task.new
    end
  end

  def create
    @task = current_user.tasks.where(problem_id: params[:submission][:task][:problem_id]).first
    @submission = @task.submissions.create(submission_params)
    UserMailer.new_submission_notify(@submission).deliver
    redirect_to @submission.task
  end

  def update
    @submission = Submission.find(params[:submission][:id])
    @submission.update_attributes(notes_params)

    if @submission.notes.any?
      @submission.task.update(status: "accepted_partially")
    end

    redirect_to @submission.task
  end

  private

    def notes_params
      params.require(:submission).permit(notes_attributes: [:id, :text])
    end

    def submission_params
      params[:submission][:user_id] = current_user.id
      params[:submission][:version] = @task.submissions.count + 1
      params.require(:submission).permit(:text, :user_id, :version, :file)
    end
end