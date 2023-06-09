require "application_system_test_case"

class ShelvesTest < ApplicationSystemTestCase
  setup do
    @shelf = shelves(:one)
  end

  test "visiting the index" do
    visit shelves_url
    assert_selector "h1", text: "Shelves"
  end

  test "should create shelf" do
    visit shelves_url
    click_on "New shelf"

    fill_in "Name", with: @shelf.name
    click_on "Create Shelf"

    assert_text "Shelf was successfully created"
    click_on "Back"
  end

  test "should update Shelf" do
    visit shelf_url(@shelf)
    click_on "Edit this shelf", match: :first

    fill_in "Name", with: @shelf.name
    click_on "Update Shelf"

    assert_text "Shelf was successfully updated"
    click_on "Back"
  end

  test "should destroy Shelf" do
    visit shelf_url(@shelf)
    click_on "Destroy this shelf", match: :first

    assert_text "Shelf was successfully destroyed"
  end
end
