module Api
  class MentionsController < ApplicationController
    def create
      user = User.find_or_create_by(slack_id: event_params[:user])

      app_mention_service = AppMentionService.new(event_params, user)
      app_mention_service.handle_message
      ok_response = app_mention_service.respond

      render json: { ok: ok_response }
    end

    private

    def event_params
      params.require(:event).permit(:user, :ts, :text, :channel)
    end
  end
end
