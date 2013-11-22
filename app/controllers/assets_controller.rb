##
# Manipulate assets of a particular artist (User)
class AssetsController < ApplicationController
  before_filter :lookup_artist
  before_filter :lookup_asset, :only => [:show, :edit, :update, :destroy, :pay, :postPay]
  before_filter :require_artist, :except => [:index, :show]
  before_filter :require_payment, :only => [:index, :show]

  # GET /artists/:artist_id/assets/
  def index
    @assets = @artist.assets
  end

  # Have a user pay to get access to an artist's assets
  # GET /artists/:artist_id/assets/pay
  def pay
    if !UserAssetPurchase.where(user: current_user, asset: @asset).empty?
      redirect_to user_asset_path(@asset.user, @asset)
    end

  end

  # POST /artists/:artist_id/assets/pay
  def postPay
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
    if UserAssetPurchase.where(user: current_user, asset: @asset).empty?
      redirect_to user_asset_pay_path(@asset.user, @asset)
    end
  end

  # GET /artists/:artist_id/assets/new
  def new
    @asset = Asset.new
    @asset.user = @artist
  end

  def create
    @asset = Asset.new(asset_params)
    @asset.user = @artist

    if @asset.save
      flash[:success] = 'Asset created successfully'
      redirect_to artist_assets_path
    else
      puts @asset.errors.messages
      flash.now[:error] = @asset.errors.messages.first
      render 'new'
    end    
  end

  # GET /artists/:artist_id/assets/:asset_id/edit
  def edit
    if @asset.user != current_user && !current_user.administrator?
      flash[:error] = 'Can not edit this asset'
      redirect_to artist_assets_path
    end
  end

  # POST /artists/:artist_id/assets/:asset_id
  def update
    if @asset.user != current_user && !current_user.administrator?
      flash[:error] = 'Can not edit this asset'
      redirect_to artist_assets_path
    else
      @asset.update_attributes(asset_params)
      if @asset.save
        flash[:success] = 'Asset updated successfully'
        redirect_to artist_assets_path
      else
        puts @asset.errors.messages
        flash.now[:error] = @asset.errors.messages.first
        render 'edit'
      end
    end
  end

  # DELETE /artists/:artist_id/assets/:asset_id
  def destroy
    if @asset.user != current_user && !current_user.administrator?
      redirect_to artist_assets_path, :notice => "Can't delete this asset."
    else
      asset.destroy
      redirect_to artist_assets_path, :notice => "Asset Deleted"
    end
  end

  private
  def asset_params
    params.require(:asset).permit(:artist_id, :uri)
  end

  # Lookup User
  def lookup_artist
    @artist = User.find(params[:artist_id])
  end

  # Get associated asset
  def lookup_asset
    @asset = Asset.find(params[:id])
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
