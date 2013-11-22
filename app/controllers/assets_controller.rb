##
# Manipulate assets of a particular artist (User)
class AssetsController < ApplicationController
  before_filter :require_artist, :except => [:index, :show]
  before_filter :require_payment, :only => [:index, :show]

  # GET /artists/:artist_id/assets/
  def index
    @artist = User.find(params[:artist_id])
    @assets = @artist.assets
  end

  # Have a user pay to get access to an artist's assets
  # GET /artists/:artist_id/assets/pay
  def pay
    @asset = Asset.find(params[:id])

    if !UserAssetPurchase.where(user: current_user, asset: @asset).empty?
      redirect_to user_asset_path(@asset.user, @asset)
    end

  end

  # POST /artists/:artist_id/assets/pay
  def postPay
    @asset = Asset.find(params[:id])

    begin
      Stripe::Charge.create(
        :amount => ENV['ASSET_FEE'],
        :currency => "usd",
        :card => params[:stripe_token], # obtained with Stripe.js
        :description => "Charge for asset"
      )

      @userPurchase = UserAssetPurchase.new
      @userPurchase.user = current_user
      @userPurchase.asset = asset

      @userPurchase.save

      redirect_to user_asset_pay_path(@asset.user, @asset)
    rescue Stripe::CardError => e
      err  = e.json_body[:error]
      flash.now[:error] = err.message
      render 'pay'
    end
  end

  # Show a particular asset
  # GET /artists/:artist_id/assets/:asset_id
  def show
    @asset = Asset.find(params[:id])

    if UserAssetPurchase.where(user: current_user, asset: @asset).empty?
      redirect_to user_asset_pay_path(@asset.user, @asset)
    end
  end

  # GET /artists/:artist_id/assets/new
  def new
    @asset = Asset.new
    @asset.user = current_user
  end

  def create
    @asset = Asset.new(asset_params)
    @asset.user = current_user

    if @asset.save
      flash[:success] = 'Asset created successfully'
      redirect_to user_assets_path
    else
      puts @asset.errors.messages
      flash.now[:error] = @asset.errors.messages.first
      render 'new'
    end    
  end

  # GET /artists/:artist_id/assets/:asset_id/edit
  def edit
    @asset = Asset.find(params[:id])

    if @asset.user != current_user
      flash[:error] = 'Can not edit this asset'
      redirect_to user_assets_path
    end
  end

  # POST /artists/:artist_id/assets/:asset_id
  def update
    @asset = Asset.find(params[:id])

    if @asset.user != current_user
      flash[:error] = 'Can not edit this asset'
      redirect_to user_assets_path
    else
      @asset.update_attributes(asset_params)
      if @asset.save
        flash[:success] = 'Asset updated successfully'
        redirect_to user_assets_path
      else
        puts @asset.errors.messages
        flash.now[:error] = @asset.errors.messages.first
        render 'edit'
      end
    end
  end

  # DELETE /artists/:artist_id/assets/:asset_id
  def destroy
    user = User.find(params[:artist_id])
    asset = Asset.find(params[:id])

    if user == current_user
      asset.destroy
      redirect_to user_assets_path, :notice => "Asset Deleted"
    else
      redirect_to user_assets_path, :notice => "Can't delete this asset."
    end
  end

  private
    def asset_params
      params.require(:asset).permit(:artist_id, :uri)
    end

    # Payment is required of non-artist/adminitrator users to list or view assets
    def require_payment
      case
      when current_user.role.name == "administrator"
        true
      when current_user.id == params[:artist_id]
        true  # Artists can view their own works
      unless %w(artist administrator).include?(current_user.role.name)
      end
    end
end
