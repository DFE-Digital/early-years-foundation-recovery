# CMS webooks
class HookController < ApplicationController
  before_action :authenticate_hook!
  skip_before_action :verify_authenticity_token, only: %i[release change]

  # POST production / delivery
  # https://ey-recovery.london.cloudapps.digital/release (currently set to dev)
  # Publish, Unpublish (content types and entries)
  # Release, Schedule, Bulk (execution)
  def release
    Release.create!(
      name: payload.dig('sys', 'id'),
      time: payload.dig('sys', 'completedAt'),
      properties: payload,
    )

    # preserve progress state
    FillPageViewsJob.enqueue

    render json: { status: 'content release received' }, status: :ok
  end

  # Request headers
  # {
  #   "X-Contentful-Topic": "ContentManagement.Entry.auto_save",
  #   "X-Contentful-Webhook-Name": "Edited content for Staging (preview)",
  #   "Content-Type": "application/vnd.contentful.management.v1+json",
  #   "Content-Length": 1431
  # }
  #
  # Request body
  # {
  #   "metadata": {
  #     "tags": []
  #   },
  #   "sys": {
  #     "space": {
  #       "sys": {
  #         "type": "Link",
  #         "linkType": "Space",
  #         "id": "dvmeh832nmjc"
  #       }
  #     },
  #     "id": "34KKy52CZ0my765ECxxf3w",
  #     "type": "Entry",
  #     "createdAt": "2023-03-08T16:24:38.998Z",
  #     "updatedAt": "2023-03-17T16:40:32.911Z",
  #     "environment": {
  #       "sys": {
  #         "id": "production",
  #         "type": "Link",
  #         "linkType": "Environment"
  #       }
  #     },
  #     "publishedVersion": 2,
  #     "publishedAt": "2023-03-08T16:24:39.744Z",
  #     "firstPublishedAt": "2023-03-08T16:24:39.744Z",
  #     "createdBy": {
  #       "sys": {
  #         "type": "Link",
  #         "linkType": "User",
  #         "id": "0k0cYaiYnbm3uNwSdmsGSw"
  #       }
  #     },
  #     "updatedBy": {
  #       "sys": {
  #         "type": "Link",
  #         "linkType": "User",
  #         "id": "0k0cYaiYnbm3uNwSdmsGSw"
  #       }
  #     },
  #     "publishedCounter": 1,
  #     "version": 4,
  #     "publishedBy": {
  #       "sys": {
  #         "type": "Link",
  #         "linkType": "User",
  #         "id": "0k0cYaiYnbm3uNwSdmsGSw"
  #       }
  #     },
  #     "automationTags": [],
  #     "contentType": {
  #       "sys": {
  #         "type": "Link",
  #         "linkType": "ContentType",
  #         "id": "question"
  #       }
  #     }
  #   },
  #   "fields": {
  #   }
  # }
  #
  #
  # TODO:
  #    - version history
  #    - content delta
  #    - author history
  #    - publish history
  #
  # POST staging / preview
  # Entry events: Save, Autosave, Archive, Unarchive, Delete
  # https://ey-recovery-staging.london.cloudapps.digital/change
  def change
    Release.create!(
      name: payload.dig('sys', 'id'),
      time: payload.dig('sys', 'updatedAt'),
      properties: payload,
    )

    # check validity of changes
    ContentCheckJob.enqueue

    render json: { status: 'content change received' }, status: :ok
  end

private

  def authenticate_hook!
    render json: { status: 'invalid secure header' }, status: :unauthorized unless bot_token?
  end

  # @return [Hash]
  def payload
    @payload ||= JSON.parse(request.body.read)
  end
end
