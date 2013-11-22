class AssetEncodingController < ApplicationController
  before_filter :require_artist, :except => [:index, :show]
  before_filter :require_payment, :only => [:index, :show]
  before_filter :lookup_asset
  before_filter :require_encoding, :only => [:show, :edit, :destroy, :update]

  # GET /assets/:asset_id/assets/
  def index
    @encodings = @asset.asset_encodings
  end

  # Show a particular asset
  # GET /assets/:asset_id/assets/:asset_id
  def show
  end

  # GET /assets/:asset_id/assets/new
  def new
    @encoding = AssetEncoding.new
    @encoding.asset = @asset
  end

  def create
    @encoding = AssetEncoding.new(encoding_params)

    if @encoding.save
      flash[:success] = 'Encoding created successfully'
      redirect_to asset_encodings_path
    else
      puts @encoding.errors.messages
      flash.now[:error] = @encoding.errors.messages.first
      render 'new'
    end    
  end

  # GET /assets/:asset_id/assets/:asset_id/edit
  def edit
    if @asset.user != current_user && !current_user.administrator?
      flash[:error] = 'Can not edit this encoding'
      redirect_to asset_encodings_path
    end
  end

  # POST /assets/:asset_id/assets/:asset_id
  def update
    if @asset.user != current_user && !current_user.administrator?
      flash[:error] = 'Can not edit this encoding'
      redirect_to asset_encodings_path
    else
      @encoding.update_attributes(encoding_params)
      if @encoding.save
        flash[:success] = 'Encoding updated successfully'
        redirect_to asset_encodings_path
      else
        puts @encoding.errors.messages
        flash.now[:error] = @encoding.errors.messages.first
        render 'edit'
      end
    end
  end

  # DELETE /assets/:asset_id/assets/:asset_id
  def destroy
    if @asset.user != current_user && !current_user.administrator?
      redirect_to asset_encodings_path, :notice => "Can't delete this asset."
    else
      @encoding.destroy
      redirect_to asset_encodings_path, :notice => "Asset Deleted"
    end
  end

  private
  def encoding_params
    params.require(:asset_encoding).permit(:duration, :height, :width, :uri)
  end

  # Get associated asset
  def lookup_asset
    @asset = Asset.find(params[:asset_id])
  end

  # Lookup AssetEncoding
  def lookup_encoding
    @encoding = AssetEncoding.find(params[:id])
  end
end
