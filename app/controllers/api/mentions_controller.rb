module Api
  class MentionsController < ApplicationController
    def create
      User.find_or_create_by(slack_id: event_params[:user])
      ok_response = AppMentionService.respond(params)

      render json: { ok: ok_response }
    end

    private

    def event_params
      params.require(:event).permit(:user)
    end
  end
end
