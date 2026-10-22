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
end
