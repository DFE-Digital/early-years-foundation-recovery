require_relative 'content'

class Training::Video < Content
  self.content_type_id = 'video'

  def page_type = 'video_page' 
  def video_title = title
  
  # @return [nil, String]
  def video_url
    return unless video_id

    %(#{video_site}/#{video_id}?enablejsapi=1&amp;origin=#{ENV['DOMAIN']})
  end

  private

  def video_site
    if vimeo?
      'https://player.vimeo.com/video'
    elsif youtube?
      'https://www.youtube.com/embed'
    end
  end

  # @return [Boolean]
  def vimeo?
    video_provider.casecmp?('vimeo')
  end

  # @return [Boolean]
  def youtube?
    video_provider.casecmp?('youtube')
  end

end
