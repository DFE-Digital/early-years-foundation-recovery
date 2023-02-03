require_relative 'content'

module Training
  class Video < Content
    # @return [String]
    def self.content_type_id
      'video'
    end

    # @return [String]
    def video_title
      title
    end

    # @return [nil, String]
    def video_url
      return unless video_id

      %(#{video_site}/#{video_id}?enablejsapi=1&amp;origin=#{ENV['DOMAIN']})
    end

  private

    # @return [String]
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
