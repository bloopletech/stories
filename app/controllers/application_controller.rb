class ApplicationController < ActionController::Base
  protect_from_forgery
  layout 'application'

  before_filter :ensure_stories_setup

  private
  def ensure_stories_setup
    redirect_to collections_path if Stories.dir.nil?
  end
  
  
  #HACK to fix params encoding https://rails.lighthouseapp.com/projects/8994/tickets/4336
  private
  before_filter :force_utf8_params

  def force_utf8_params
    traverse = lambda do |object, block|
      if object.kind_of?(Hash)
        object.each_value { |o| traverse.call(o, block) }
      elsif object.kind_of?(Array)
        object.each { |o| traverse.call(o, block) }
      else
        block.call(object)
      end
      object
    end
    force_encoding = lambda do |o|
      o.force_encoding(Encoding::UTF_8) if o.respond_to?(:force_encoding)
    end
    traverse.call(params, force_encoding)
  end
end
