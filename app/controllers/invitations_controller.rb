# Öffentliche Annahme einer Einladung per Token-Link.
class InvitationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :update,
             with: -> { redirect_to new_session_path, alert: "Bitte später erneut versuchen." }

  before_action :set_invitation

  def show
  end

  def update
    user = @invitation.accept!(
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
    start_new_session_for user
    redirect_to hub_path, notice: "Willkommen im Rider Hub!"
  rescue ActiveRecord::RecordInvalid => e
    @error = e.record.errors.full_messages.to_sentence
    render :show, status: :unprocessable_entity
  end

  private
    def set_invitation
      @invitation = Invitation.find_pending(params[:token])
      redirect_to new_session_path, alert: "Diese Einladung ist ungültig oder abgelaufen." unless @invitation
    end
end
