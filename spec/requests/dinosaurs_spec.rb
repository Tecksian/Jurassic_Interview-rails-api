require 'rails_helper'

RSpec.describe "Dinosaurs", type: :request do
  describe "GET /dinosaurs" do
    it "works! (now write some real specs)" do
      get dinosaurs_path
      expect(response).to have_http_status(200)
    end
  end
end
