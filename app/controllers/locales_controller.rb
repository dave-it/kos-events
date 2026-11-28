class LocalesController < ApplicationController
  allow_unauthenticated_access

  def update
    locale = params[:locale].to_s
    if available_locales.include?(locale)
      cookies.permanent[:locale] = { value: locale, same_site: :lax }
      # Beim Fahrer merkt sich das Profil die Wahl (andere Geräte, E-Mails).
      Current.user.rider&.update_column(:locale, locale) if authenticated?
    end
    redirect_back_or_to root_path, status: :see_other
  end
end
