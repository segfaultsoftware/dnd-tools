require "rails_helper"

RSpec.describe "Public content", type: :request do
  let(:changelog) do
    [
      "# Release <strong>notes</strong> & details",
      "A-long-unbroken-line-#{'x' * 300}",
      *Array.new(31) { |index| "Release note #{index + 1}" }
    ].join("\n")
  end

  before do
    allow_any_instance_of(ApplicationController).to receive(:changelog_content).and_return(changelog)
  end

  it "renders the landing page publicly with escaped changelog content and placeholder stats" do
    get root_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("# Release &lt;strong&gt;notes&lt;/strong&gt; &amp; details")
    expect(response.body).not_to include("<strong>notes</strong>")
    expect(response.body).to include("Release note 31")
    expect(response.body).to include("Unique session views")
    expect(response.body).to include(">45<")
    expect(response.body).to include("Campaigns")
    expect(response.body).to include(">918<")
    expect(response.body).to include("NPCs generated")
    expect(response.body).to include(">2,415<")
  end

  it "renders the complete escaped changelog publicly" do
    get changelog_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to include("# Release &lt;strong&gt;notes&lt;/strong&gt; &amp; details")
    expect(response.body).not_to include("<strong>notes</strong>")
    expect(response.body).to include("Release note 31")
  end

  it "renders the loot generator publicly with the exact controls and page structure" do
    get loot_path

    expect(response).to have_http_status(:ok)

    document = Nokogiri::HTML5(response.body)
    expect(document.css("main h1").map(&:text)).to eq([ "Loot Generator" ])
    expect(document.css("main h2").map(&:text)).to eq([ "Individual Treasure", "Treasure Horde" ])
    expect(document.css("main section + hr + section").length).to eq(1)

    select = document.at_css("select#monster-cr")
    expect(select.previous_element.text.strip).to eq("Monster CR")
    expect(select.css("option").map(&:text)).to eq(
      [ "Select a CR", "1/8", "1/4", "1/2", *1.upto(16).map(&:to_s), "17+" ]
    )
    expect(select.at_css("option[selected]")["value"]).to eq("")
    expect(document.at_css("button[type='submit'][disabled]").text.strip).to eq("Generate")
  end
end
