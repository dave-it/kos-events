module Admin
  class PagesController < ApplicationController
    before_action :require_staff
    before_action :set_page, only: %i[edit update destroy]

    def index
      @pages = Page.order(:nav, :position, :slug)
    end

    def new
      @page = Page.new(nav: "none")
    end

    def create
      @page = Page.new(page_params)
      if @page.save
        redirect_to admin_pages_path, notice: t("flash.pages.created")
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @page.update(page_params)
        redirect_to admin_pages_path, notice: t("flash.pages.saved")
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @page.destroy
      redirect_to admin_pages_path, notice: t("flash.pages.deleted"), status: :see_other
    end

    private
      def set_page = @page = Page.find_by!(slug: params[:id])

      def page_params
        params.expect(page: %i[slug title_de title_en body_de body_en nav position published])
      end
  end
end
