class StoriesController < ApplicationController
  def index
    params[:sort] ||= 'created_at'
    params[:sort_direction] ||= 'DESC'
    @stories = if !params[:search].blank?
      included_tags, excluded_tags = ActsAsTaggableOn::TagList.from(params[:search]).partition { |t| t.gsub!(/^-/, ''); $& != '-' }

      results = Story
      
      results = results.where("opens > 0") if included_tags.delete 's:read'
      results = results.where("opens = 0") if included_tags.delete 's:unread'
      #results = results.where("COUNT(taggings.id) > 0") if included_tags.delete 's:tagged'
      


      results = results.tagged_with(excluded_tags, :exclude => true) unless excluded_tags.empty?
      results = results.tagged_with(included_tags) unless included_tags.empty?

      c = Story.connection
      #This next part makes me want to become an hero
      search_inc = included_tags.empty? ? nil : included_tags.map { |t| "stories.title LIKE #{c.quote "%#{t}%"}" }.join(" AND ")
      search_ex = excluded_tags.empty? ? nil : excluded_tags.map { |t| "NOT stories.title LIKE #{c.quote "%#{t}%"}" }.join(" AND ")
      
      results.where_values = ["(#{(results.where_values + [search_ex]).compact.map { |w| "(#{w})" }.join(" AND ")})" +
       (search_inc.nil? ? "" : " OR (#{search_inc})")]

      results
    else
      Story
    end.order("#{params[:sort]} #{params[:sort_direction]}").paginate(:page => params[:page], :per_page => 10)
    
    @tags = Story.tag_counts_on(:tags)
  end

  def new
    @story = Story.new
  end

  def create
    _process_edit_content
    @story = Story.new(params[:story])

    if @story.save
      flash[:success] = "Story successfully created"
    else
      render :action => 'new'
    end
  end

  def edit
    @story = Story.find(params[:id])
  end

  def update
    _process_edit_content
    @story = Story.find(params[:id])
    if @story.update_attributes(params[:story])
      render :action => request.xhr? ? 'update_fields' : 'update'
    else
      #boom
    end
  end

  def destroy
    @story = Story.find(params[:id])
    @story.destroy
  end

  def show
    @story = Story.find(params[:id])
    @story.open
  end

  def more_info
    @story = Story.find(params[:id])
    render :layout => 'secondary'
  end

  

  

  def import_and_update
    #Thread.new do #Temporarily remopve threading as it seems to be causing import problems
      Story.import_and_update
    #end
  end

  def info
    if Story.count == 0
      render :text => 'No items yet', :layout => 'secondary'
    end

    @oldest_story = Story.order('published_on ASC').first
    @newest_story = Story.order('published_on DESC').first
    #@longest_story = Story.order('pages DESC').first
    #@shortest_story = Story.order('pages ASC').first
    @most_popular_story = Story.order('opens DESC').first
    @least_popular_story = Story.order('opens ASC').first
    render :layout => 'secondary'
  end


  #TODO: Move someplace better
  def quit
    Process.kill("TERM", $$)
  end

  private
  def _process_edit_content
    params[:story][:content] = Nsf::Document.from_text(params[:story][:content]).to_nsf if params[:story][:content]
  end
end