class ArtistsController < UsersController
  before_filter :require_login
  skip_before_filter :require_administrator, :only => [:index]
  skip_before_filter :lookup_user, :only => [:show, :edit, :update, :destroy]

  # GET /artists
  # GET /artists.json
  def index
    @artists = User.all.select(&:artist?)

    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => @artists }
    end
  end

  # GET /artists/1
  # GET /artists/1.json
  def show
    @artist = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json  { render :json => @artist }
    end
  end
end
