class RobotsTxtsController < ApplicationController
  def show
    if disallow_all_crawlers?
      render 'robots', layout: false, content_type: 'text/plain'
    else
      head :not_found
    end
  end

private

  def disallow_all_crawlers?
    !ENV['WORKSPACE'].eql?('production')
  end
end
