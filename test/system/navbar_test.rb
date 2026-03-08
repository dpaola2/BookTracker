require "application_system_test_case"

class NavbarTest < ApplicationSystemTestCase
  setup do
    @user = users(:one)
  end

  test "authenticated user sees Search link in navbar" do
    visit new_user_session_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"
    click_on "Log in"

    within "nav.navbar" do
      assert_link "Search", href: book_searches_path
    end
  end

  test "Search link is positioned after Shelves and before Settings in navbar" do
    visit new_user_session_path
    fill_in "Email", with: @user.email
    fill_in "Password", with: "password123"
    click_on "Log in"

    within "nav.navbar" do
      nav_items = all("ul.navbar-nav li.nav-item a.nav-link").map(&:text)
      shelves_index = nav_items.index("Shelves")
      search_index = nav_items.index("Search")
      settings_index = nav_items.index("Settings")

      assert_not_nil search_index, "Search link should be present in navbar"
      assert_operator search_index, :>, shelves_index, "Search should appear after Shelves"
      assert_operator search_index, :<, settings_index, "Search should appear before Settings"
    end
  end

  test "unauthenticated visitor does not see Search link in navbar" do
    visit root_path

    within "nav.navbar" do
      assert_no_link "Search"
    end
  end
end
