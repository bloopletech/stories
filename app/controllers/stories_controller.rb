class StoriesController < ApplicationController
  def index
    _run_search

    @stories = @stories.paginate(:page => params[:page], :per_page => 100)
    
    @tags = Story.tag_counts_on(:tags)

    self.formats = [:js, :html] if params[:page]
  end

  def new
    @story = Story.new
  end

  def create
    @page_id = "stories-new"

    _process_edit_content

    @story = Story.new(params[:story])

    if @story.save
      flash[:success] = "Story successfully created"
      redirect_to story_path(@story)
    else
      render :action => 'new'
    end
  end

  def edit
    @story = Story.find(params[:id])
  end

  def update
    @page_id = "stories-edit"

    _process_edit_content

    @story = Story.find(params[:id])    
    if @story.update_attributes(params[:story])
      redirect_to story_path(@story)
    else
      render :action => 'edit'
    end
  end

  def destroy
    @story = Story.find(params[:id])
    @story.destroy
    redirect_to stories_path
  end

  def show
    @story = Story.find(params[:id])
    Thread.new do
      sleep 1
      @story.open
    end
  end

  def more_info
    @story = Story.find(params[:id])
    render :layout => 'secondary'
  end

  def export
    exported = []

    if params.key?(:mode) && params.key?(:format)
      if params[:mode] == 'multiple'
        _run_search
        exported = @stories.map { |s| s.export(params[:format]) }
      else
        @story = Story.find(params[:id])
        exported = [@story.export(params[:format])]
      end
      
      if params[:format] == 'csv'
        require 'csv'
        CSV.open("#{Stories.export_dir}/#{DateTime.now.to_s.gsub(' ', '_')}.csv", "w") do |csv|
          csv << Story::CSV_HEADER
          exported.each { |e| csv << e }
        end
      else
        exported.each do |e|
          File.open("#{Stories.export_dir}/#{e.filename}", "w") do |f|
            f << e.content
            f.flush
          end
        end
      end

      flash[:success] = "Export completed successfully."
      self.formats = [:html, :js]
      render :action => 'export_done'
    else
      render :action => 'export', :layout => 'secondary'
    end
  end

  def export_done
    render :action => 'export_done', :layout => 'secondary'
  end

  

  

  def import
    #Thread.new do #Temporarily remopve threading as it seems to be causing import problems
      Story.import
      flash[:success] = "Import completed successfully."
      redirect_to :action => 'index'
    #end
  end

  def info
    if Story.count == 0
      render :text => 'No items yet'
    end

    @oldest_story = Story.order('published_on ASC').first
    @newest_story = Story.order('published_on DESC').first
    @longest_story = Story.order('word_count DESC').first
    @shortest_story = Story.order('word_count ASC').first
    @most_popular_story = Story.order('opens DESC').first
    @least_popular_story = Story.order('opens ASC').first    
  end


  #TODO: Move someplace better
  def quit
    Process.kill("TERM", $$)
  end

  private
  def _process_edit_content
    if params[:story][:content]
      doc = Nsf::Document.from_text(params[:story][:content].gsub(/\r?\n/, "\n"))

      params[:story][:title] = doc.title
      params[:story][:content] = doc.to_nsf
    end
  end

  def _run_search
    params[:sort] ||= 'created_at'
    params[:sort_direction] ||= 'DESC'
    @stories = if !params[:search].blank?
      included_tags, excluded_tags = ActsAsTaggableOn::TagList.from(params[:search]).partition { |t| t.gsub!(/^-/, ''); $& != '-' }

      results = Story
      
      results = results.where("opens > 0") if included_tags.delete 's:read'
      results = results.where("opens = 0") if included_tags.delete 's:unread'
      #results = results.where("COUNT(taggings.id) > 0") if included_tags.delete 's:tagged'
      results = results.where("word_count >= 5000") if included_tags.delete 's:long'
      results = results.where("word_count <= 4999") if included_tags.delete 's:short'
      


      results = results.tagged_with(excluded_tags, :exclude => true) unless excluded_tags.empty?
      results = results.tagged_with(included_tags) unless included_tags.empty?

      c = Story.connection

      #This next part makes me want to become an hero
      search_inc = if included_tags.empty?
        nil
      else
        included_tags.map do |t|
          "(stories.title LIKE ? OR stories.most_frequent_words LIKE ?)".gsub("?", c.quote("%#{t}%"))
        end.join(" AND ")
      end
      search_ex = if excluded_tags.empty?
        nil
      else
        excluded_tags.map do |t|
          "(NOT (stories.title LIKE ? OR stories.most_frequent_words LIKE ?))".gsub("?", c.quote("%#{t}%"))
        end.join(" AND ")
      end
      
      results.where_values = ["(#{(results.where_values + [search_ex]).compact.map { |w| "(#{w})" }.join(" AND ")})" +
       (search_inc.nil? ? "" : " OR (#{search_inc})")]

      results
    else
      Story
    end.order("#{params[:sort]} #{params[:sort_direction]}")
  end
end
