require "test_helper"

class Admin::PagesControllerTest < ActionDispatch::IntegrationTest
  setup { @page = Page.create!(slug: "regeln", title_de: "Regeln", title_en: "Rules", body_de: "a", body_en: "b") }

  test "Gäste und Fahrer kommen nicht rein" do
    get admin_pages_path
    assert_redirected_to new_session_path
    sign_in_as users(:rider_user)
    get admin_pages_path
    assert_response :forbidden
  end

  test "Staff legt Seite an, bearbeitet und löscht sie" do
    sign_in_as users(:staff)
    get admin_pages_path
    assert_response :success

    post admin_pages_path, params: { page: { slug: "neu", title_de: "Neu", title_en: "New", body_de: "x", body_en: "y", nav: "footer" } }
    assert_redirected_to admin_pages_path
    assert Page.exists?(slug: "neu")

    patch admin_page_path(@page), params: { page: { title_de: "Regelwerk" } }
    assert_equal "Regelwerk", @page.reload.title_de

    delete admin_page_path(@page)
    assert_not Page.exists?(slug: "regeln")
  end
end
