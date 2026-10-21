require "rails_helper"

RSpec.describe "Account registration", type: :system do
  it "supports keyboard sign-up and shows accessible validation feedback" do
    visit new_user_registration_path

    expect(page).to be_axe_clean
    expect(page).to have_field("Email", type: "email")
    expect(page).to have_button("Create account")

    email_field = page.find_field("Email")
    expect(page.driver.browser.switch_to.active_element.attribute("id")).to eq(email_field[:id])

    email_field.send_keys("not-an-email", :tab, "short", :tab, "different", :tab, :enter)

    expect(page).to have_css("[role='alert']", text: "There were problems with your sign-up")
    expect(page).to have_css("input[aria-invalid='true']")
    expect(page).to have_field("Email", with: "not-an-email")
  end
end
