# Öffentliche Annahme einer Einladung per Token-Link.
class InvitationsController < ApplicationController
  allow_unauthenticated_access
  rate_limit to: 10, within: 3.minutes, only: :update,
             with: -> { redirect_to new_session_path, alert: I18n.t("flash.try_again_later") }

  before_action :set_invitation

  def show
  end

  def update
    user = @invitation.accept!(
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
    start_new_session_for user
    cookies.permanent[:locale] = { value: @invitation.language, same_site: :lax }
    redirect_to (user.rider_role? ? hub_path : start_path), notice: t("flash.invitations.welcome")
  rescue ActiveRecord::RecordInvalid => e
    @error = e.record.errors.full_messages.to_sentence
    render :show, status: :unprocessable_entity
  end

  private
    def set_invitation
      @invitation = Invitation.find_pending(params[:token])
      return redirect_to new_session_path, alert: t("flash.invitations.invalid") unless @invitation

      # Einladung in der Sprache des Fahrers zeigen, außer er hat selbst umgeschaltet.
      I18n.locale = @invitation.language if params[:locale].blank? && cookies[:locale].blank?
    end
end
