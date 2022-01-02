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

  context "POST /users" do
    let(:url) { "/admin/v1/users" }
    context "when valid params" do
      let(:correct_params) { { user: attributes_for(:user) }.to_json }

      it "should create an new user" do
        expect do
          post url, headers: auth_header(users.first), params: correct_params
        end.to change(User, :count).by(1)
      end

      it "should returns an new user created" do
        post url, headers: auth_header(users.first), params: correct_params

        expected_new_user = User.last.as_json only: %i(id name email profile)
        expect(body_json["user"]).to be_present
        expect(body_json["user"]).to eq expected_new_user
      end

      it "should returns status :created" do
        post url, headers: auth_header(users.first), params: correct_params

        expect(response).to have_http_status(:created)
      end
    end

    context "when invalid params" do
      let(:incorrect_params) { { user: attributes_for(:user, email: nil) }.to_json }

      it "should not save a new user" do
        expect do
          post url, headers: auth_header(users.first), params: incorrect_params
        end.to_not change(User, :count)
      end

      it "should returns erros message" do
        post url, headers: auth_header(users.first), params: incorrect_params

        expect(body_json["errors"]["fields"]).to have_key("email")
      end

      it "should return :unprocessable_entity status" do
        post url, headers: auth_header(users.first), params: incorrect_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
