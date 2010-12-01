class CollectionsController < ApplicationController
  skip_before_filter :ensure_stories_setup

  def index
    @collections = Collection.all
  end

  def show
    Stories.configure(Collection.find(params[:id]))
    redirect_to '/'
  end

  def create
    #If on gnome
    directory = IO.popen("env -u WINDOWID zenity --file-selection --directory") { |s| s.read }
    
    unless directory.blank?
      Collection.create!(:path => directory.strip)
    end

    redirect_to collections_path
  end

  def edit
    @collection = Collection.find(params[:id])
    render :layout => 'secondary'
  end

  def update
    @collection = Collection.find(params[:id])
    
    if @collection.update_attributes(params[:collection])
      Stories.collection = @collection

      flash[:success] = "Settings changed successfully."
      redirect_to collections_path
    else
      render :action => 'edit'
    end
  end

  def destroy
    Collection.find(params[:id]).destroy
    redirect_to collections_path
  end
end