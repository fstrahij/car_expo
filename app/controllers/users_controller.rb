class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :show, :edit, :update]
  before_action :correct_user, only: [:show, :edit, :update]

  def show
    @user = User.find(params[:id])
  end

  def new
  	@user = User.new
  end

  def create
  	@user = User.new(user_params)

  	respond_to do |format|
	  	if @user.save
	  		format.html { redirect_to @user, notice: 'User was successfully created.' }
	      format.json { render :show, status: :created, location: @user }
	  	else
	  		format.html { render :new }
	      format.json { render json: @user.errors, status: :unprocessable_entity }
	  	end
	  end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:succes] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def index
     @users = User.paginate(page: params[:page], :per_page => 15)
  end 

  private
  	def user_params
      params.require(:user).permit(:first_name, :last_name, :user_name,	:password, :password_confirmation, :email)
    end

    def logged_in_user
      unless logged_in?
        store_location
        flash[:danger] = "Please log in."
        redirect_to root_url
      end
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end
end
