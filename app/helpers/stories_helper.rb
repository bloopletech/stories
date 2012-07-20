# encoding: UTF-8
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
    wbrize(story.title.gsub(/\s+/, ' '))
  end

  def ic(icon, text)
    "#{raw image_tag("icons/#{icon}.png")} <span>#{text}</span>".html_safe
  end

  def number_to_stars(num)
    return "" if num < 0

    case num
    when 0..1999
      "•"
    when 2000..4999
      "••"
    when 5000..9999
      "•••"
    else
      "••••"
    end
  end

  def number_to_pages(num)
    return 0 if num < 0
    number_with_delimiter((num / 250.0).ceil)
  end

  def show_toc?(story)
    story.nsf.toc.length > 1
  end


  def toc(story)
    headings = story.nsf.toc

    out = "<ul>"
    headings.each_with_index do |heading, i|
      p = i > 0 ? headings[i - 1].level : nil
      n = (x = headings[i + 1]) && x.level

      out << "<li><a href=\"##{CGI.escapeHTML(heading.ref_html)}\">#{CGI.escapeHTML(heading.text)}</a>"
      out << if n && heading.level < n
        "<ul>"
      elsif n && heading.level == n
        "</li>"
      else
        "</li></ul></li>"
      end
    end
    out << "</ul>"

    out.html_safe
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
