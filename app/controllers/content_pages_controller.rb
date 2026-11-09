# Öffentliche redaktionelle Seiten unter /<slug> (z. B. /training, /preise).
class ContentPagesController < ApplicationController
  layout "public"
  allow_unauthenticated_access
  before_action :resume_session

  def show
    @page = Page.published.find_by!(slug: params[:slug])
  end
end
