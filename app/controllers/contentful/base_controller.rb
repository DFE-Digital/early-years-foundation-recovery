class Contentful::BaseController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[webhooks]
  # Triggered on content release
  #
  # {
  #   "action": "validate",
  #   "sys": {
  #     "type": "ReleaseAction",
  #     "space": {
  #       "sys": {
  #         "type": "Link",
  #         "linkType": "Space",
  #         "id": "dvmeh832nmjc"
  #       }
  #     },
  #     "environment": {
  #       "sys": {
  #         "id": "production",
  #         "type": "Link",
  #         "linkType": "Environment"
  #       }
  #     },
  #     "release": {
  #       "sys": {
  #         "type": "Link",
  #         "linkType": "Release",
  #         "id": "2Eh4WlGyuOLAixqHLi8UIe"
  #       }
  #     },
  #     "id": "2Z5Ikk91OSg5CaNqGCk1ki",
  #     "status": "succeeded",
  #     "createdBy": {
  #       "sys": {
  #         "type": "Link",
  #         "linkType": "User",
  #         "id": "0k0cYaiYnbm3uNwSdmsGSw"
  #       }
  #     },
  #     "createdAt": "2023-03-13T16:38:14.222Z",
  #     "updatedAt": "2023-03-13T16:38:14.543Z",
  #     "startedAt": "2023-03-13T16:38:14.430Z",
  #     "completedAt": "2023-03-13T16:38:14.543Z"
  #   }
  # }
  #
  def webhooks
    ContentCheckJob.enqueue # confirm validity
    # FillPageViewsJob.enqueue  # preserve progress state

    render json: { status: 'ENQUEUED' }, status: :ok
  end
end
