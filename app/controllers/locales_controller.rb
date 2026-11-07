class LocalesController < ApplicationController
  allow_unauthenticated_access

  def update
    locale = params[:locale].to_s
    cookies.permanent[:locale] = { value: locale, same_site: :lax } if I18n.available_locales.map(&:to_s).include?(locale)
    redirect_back_or_to root_path, status: :see_other
  end
end
