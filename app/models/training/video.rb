require_relative 'content'

module Training
  class Video < Content
    # @return [String]
    def self.content_type_id
      'video'
    end

    # # @return [Training::Video]
    # def self.by_id(id)
    #   load_children(0).find(id)
    # end

    # # @return [Training::Video]
    # def self.by_name(name)
    #   load_children(0).find_by(name: name).first
    # end

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
end
