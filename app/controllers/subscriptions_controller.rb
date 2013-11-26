class SubscriptionsController < ApplicationController
  before_filter :lookup_artist_or_user
  before_filter :lookup_subscription, :only => [:show, :edit, :update, :destroy]

  # GET /users/:user_id/subscriptions
  def index
    @subscriptions = current_user.user_subscriptions
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @subscriptions }
    end
  end

  # GET /artists/:artist_id/subscription
  # GET /users/:user_id/subscriptions/:id
  def show
    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @subscription }
    end
  end

  # GET /artists/:artist_id/subscription/new
  def new
    @subscription = UserSubscription.new(:user_id => current_user, :artist_id => @user)
  end

  # POST /artists/:artist_id/subscription
  def create
    @subscription = UserSubscription.new(subscription_params)

    begin
      Stripe::Charge.create(
        :amount => ENV['ASSET_FEE'],
        :currency => "usd",
        :card => params[:stripe_token], # obtained with Stripe.js
        :description => "Charge for asset"
      )

      @subscription.save!
      respond_to do |format|
        format.html { redirect_to artist_assets_path(@user), :notice => 'Subscription successful.' }
        format.json { render :json => @subscription, :status => :created, :location => @subscription }
      end

      redirect_to user_asset_pay_path(@asset.user, @asset)
    rescue Stripe::CardError => e
      respond_to do |format|
        format.html { redirect_to new_artist_assets_path(@user), :notice => "Subscription error: #{e.message}" }
        format.json { render :json => {error: e.message}, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /artists/:artist_id/subscription/:id
  # DELETE /users/:user_id/subscription/:id
  def destroy
    @subscription.destroy

    respond_to do |format|
      format.html { redirect_to artist_subscription_path }
      format.json  { head :ok }
    end
  end

  private
  def subscription_params
    params.require(:subscription).permit(:user_id, :artist_id)
  end

  # Lookup User
  def lookup_artist_or_user
    @user = User.find(params[:artist_id] || params[:user_id])
  end

  # Get associated subscription (two paths)
  def lookup_subscription
    @subscription = if params.has_key?(:id)
      UserSubscription.find(params[:id])
    else
      current_user.user_subscriptions.where(artist: @user).first
    end
  end
end
