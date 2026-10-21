require "rails_helper"

RSpec.describe "JavaScript browser support", type: :system do
  it "runs a page with the headless Chrome driver", js: true do
    visit "/not-a-real-route"

    expect(page).to have_css("body")
    expect(page.status_code).to eq(404)
  end
end
