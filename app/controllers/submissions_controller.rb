class SubmissionsController < ApplicationController
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    begin
      @current_page = Integer(params[:page])
      if @current_page < 1
        flash[:alert] = "Kidding? The page you tell me is non-positive!"
        @current_page = 1
      end
    rescue ArgumentError
      flash[:alert] = "Kidding? The page you tell me is not a number!"
      @current_page = 1
    end
    @submissions = Submission.offset((@current_page - 1) * 10).last(10).reverse
  end

  def new
    @problem = Problem.find(params[:problem_id])
  end

  def create
    @problem = Problem.find(params[:problem_id])
    @submission.problem = @problem
    @submission.user = current_user

    if @submission.save
      @submission.submit	# delayed job
      redirect_to submissions_path, :notice => "Submit successfully."
    else
      flash[:alert] = "Failed to submit."
      render :action => :new
    end
  end

  def compile_error
    @submission = Submission.find(params[:submission_id])
    if @submission.user_id != current_user.id && current_user.has_role?(:user)
      redirect_to submissions_path, :alert => "It's not for you..."
    elsif @submission.status != ApplicationController.helpers.status_list["Compile Error"]
      redirect_to submissions_path, :alert => "The status of submission #{@submission.id} is not Compile Error..."
    end
  end

  def show_code
    @submission = Submission.find(params[:submission_id])
    if @submission.user_id != current_user.id && current_user.has_role?(:user)
      redirect_to submissions_path, :alert => "It's not for you..."
    end
  end
end
