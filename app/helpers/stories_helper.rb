module StoriesHelper
  include ActsAsTaggableOn::TagsHelper

  def is_last_page?(collection)
    collection.total_pages == 0 || (collection.total_pages == (params[:page].blank? ? 1 : params[:page].to_i))
  end

  def stories_with(new_params)
    stories_path(params.except(:controller, :action, :page).merge(new_params))
  end

  def wbrize(str)
    str
    #str.split(' ').map { |sub_str| sub_str.split(/.{,30}/).join("<wbr>") }.join(' ')
  end

  def story_title(story)
    raw "<div class='title'>#{h wbrize(story.title)}</div>"
  end

  

  def fd_piechart(div, title, keys, values)
    return raw <<-EOF
    <script type="text/javascript">
    $(function()
    {
      pieify('#{div}', "#{escape_javascript title}", #{keys.to_json}, #{values.to_json});
    })
    </script>
EOF
  end
    
end