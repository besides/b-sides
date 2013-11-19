class AssetsController < ApplicationController
  Stripe.api_key = ENV['STRIPE_API_KEY']

  S3_BUCKET_NAME = ENV['AWS_BUCKET']
  S3_SECRET_KEY = ENV['AWS_ACCESS_SECRET']
  S3_ACCESS_KEY = ENV['AWS_ACCESS_KEY']

  def index
    @user = User.find(params[:user_id])
    @assets = @user.assets
  end

  def pay
    @asset = Asset.find(params[:id])

    if !UserAssetPurchase.where(user: current_user, asset: @asset).empty?
      redirect_to user_asset_path(@asset.user, @asset)
    end

  end

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

  def show
    @asset = Asset.find(params[:id])

    if UserAssetPurchase.where(user: current_user, asset: @asset).empty?
      redirect_to user_asset_pay_path(@asset.user, @asset)
    end
  end

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

  def edit
    @asset = Asset.find(params[:id])

    if @asset.user != current_user
      flash[:error] = 'Can not edit this asset'
      redirect_to user_assets_path
    end
  end

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

  def destroy
    user = User.find(params[:user_id])
    asset = Asset.find(params[:id])

    if user == current_user
      asset.destroy
      redirect_to user_assets_path, :notice => "Asset Deleted"
    else
      redirect_to user_assets_path, :notice => "Can't delete this asset."
    end
  end


  def signS3put
    objectName = params[:s3_object_name]
    mimeType = params['s3_object_type']
    expires = Time.now.to_i + 100 # PUT request to S3 must start within 100 seconds

    amzHeaders = "x-amz-acl:public-read" # set the public read permission on the uploaded file
    stringToSign = "PUT\n\n#{mimeType}\n#{expires}\n#{amzHeaders}\n/#{S3_BUCKET_NAME}/#{objectName}";
    sig = CGI::escape(Base64.strict_encode64(OpenSSL::HMAC.digest('sha1', S3_SECRET_KEY, stringToSign)))
    
    jsonToReturn = {
      signed_request: CGI::escape("https://s3.amazonaws.com/#{S3_BUCKET_NAME}/#{objectName}?AWSAccessKeyId=#{S3_ACCESS_KEY}&Expires=#{expires}&Signature=#{sig}"),
      url: "http://s3.amazonaws.com/#{S3_BUCKET_NAME}/#{objectName}"
    }.to_json

    render json: jsonToReturn
  end

  private
    def asset_params
      params.require(:asset).permit(:user_id, :uri)
    end
end
