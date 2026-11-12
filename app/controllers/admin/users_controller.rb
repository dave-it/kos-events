module Admin
  # Zugänge für Mitarbeiter (staff) und Besucher (visitor). Fahrer werden über die Fahrerliste eingeladen.
  class UsersController < ApplicationController
    before_action :require_staff

    INVITABLE_ROLES = %w[staff visitor].freeze

    def index
      @users = User.where(role: %w[staff visitor]).order(:role, :email_address)
      @invitations = Invitation.pending.where(role: INVITABLE_ROLES).order(created_at: :desc)
    end

    def new
      @invitation = Invitation.new(role: "visitor", locale: I18n.locale.to_s)
    end

    def create
      @invitation = Invitation.new(invitation_params.merge(invited_by: current_user))
      if INVITABLE_ROLES.include?(@invitation.role) && @invitation.save
        InvitationMailer.invite(@invitation).deliver_later
        # Der Link wird dem Team angezeigt, damit er auch ohne Mailversand weitergegeben werden kann.
        flash[:invite_url] = invitation_url(token: @invitation.token)
        redirect_to admin_users_path, notice: t("flash.users.invited", email: @invitation.email)
      else
        @invitation.errors.add(:role, :inclusion) unless INVITABLE_ROLES.include?(@invitation.role)
        render :new, status: :unprocessable_entity
      end
    end

    def destroy
      user = User.where(role: %w[staff visitor]).find(params[:id])
      if user == current_user
        redirect_to admin_users_path, alert: t("flash.users.cannot_revoke_self")
      else
        user.destroy!
        redirect_to admin_users_path, notice: t("flash.users.revoked", email: user.email_address)
      end
    end

    private
      def invitation_params
        params.expect(invitation: %i[email role locale])
      end
  end
end
