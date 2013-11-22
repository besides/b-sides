class UsersController < ApplicationController
  before_filter :require_administrator, :only => [:index, :new, :create]
  before_filter :lookup_user, :only => [:show, :edit, :update, :destroy]
  before_filter :require_this_user, :only => [:show, :edit, :update, :destroy]

  # GET /users
  # GET /users.json
  def index
    @users = User.all

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json  { render :json => @user }
    end
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to(:users, :notice => 'Registration successfull. Check your email for activation instructions.') }
        format.json { render :json => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.json { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    respond_to do |format|
      byebug
      if @user.update_attributes(user_params)
        format.html { redirect_to(@user, :notice => 'User was successfully updated.') }
        format.json  { head :ok }
      else
        format.html { render :action => "edit" }
        format.json  { render :json => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy

    respond_to do |format|
      format.html { redirect_to(users_url) }
      format.json  { head :ok }
    end
  end
  
  def activate
    if @user = User.load_from_activation_token(params[:id])
      @user.activate!
      redirect_to(login_path, :notice => 'User was successfully activated.')
    else
      not_authenticated
    end
  end

  protected
  def user_params
    params.require(:user).permit(:email, :name, :role_id)
  end

  def lookup_user
    @user = User.find(params[:id])
  end

  def require_this_user
    unless current_user.administrator? || @user == current_user
      flash[:warning] = "Attempt to access a different user"
      redirect_to controller: "home", action: "index"
    end
  end
end
