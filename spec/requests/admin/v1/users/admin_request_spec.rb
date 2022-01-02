require "rails_helper"

RSpec.describe "Admin::V1::User" do
  let!(:users) { create_list(:user, 2) }

  context "GET /users" do
    let(:url) { "/admin/v1/users" }

    it "should returns all users" do
      get url, headers: auth_header(users.first)
      expected_users = users.as_json(only: %i(id name profile email))
      expect(body_json["users"]).to contain_exactly *expected_users
    end

    it "should returns status :ok" do
      get url, headers: auth_header(users.first)
      expect(response).to have_http_status(:ok)
    end
  end
end
