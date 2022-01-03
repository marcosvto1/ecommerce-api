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

      it "should returns error if password is not equal password_confirmation" do
        user_with_password_is_difer = { user: attributes_for(:user, password: "123456789", password_confirmation: "987654331") }.to_json
        post url, headers: auth_header(users.first), params: user_with_password_is_difer

        expect(body_json["errors"]["fields"]).to have_key("password_confirmation")
      end

      it "should return error if email already in use" do
        new_user_attr = User.new
        new_user_attr.attributes = attributes_for(:user, email: "mail@mail.com")
        new_user_attr.save

        user_with_email_already_in_use = { user: attributes_for(:user, email: "mail@mail.com") }.to_json
        post url, headers: auth_header(users.first), params: user_with_email_already_in_use

        expect(body_json["errors"]["fields"]).to have_key("email")
      end

      it "should return :unprocessable_entity status" do
        post url, headers: auth_header(users.first), params: incorrect_params

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "PATCH /users" do
    let!(:user_saved) { create(:user, email: "teste@teste.com") }
    let(:url) { "/admin/v1/users/#{user_saved.id}" }

    context "when correct params" do
      let(:correct_params) { { user: attributes_for(:user, email: "teste2@teste.com") }.to_json }
      it "should update a user" do
        patch url, headers: auth_header(users.last), params: correct_params
        user_saved.reload

        expect(user_saved.email).to eq "teste2@teste.com"
      end

      it "should returns user updated" do
        patch url, headers: auth_header(users.last), params: correct_params
        user_saved.reload
        expected_user = user_saved.as_json only: %i(id name email profile)

        expect(body_json["user"]).to eq expected_user
      end

      it "should return status :ok" do
        patch url, headers: auth_header(users.last), params: correct_params

        expect(response).to have_http_status(:ok)
      end
    end

    context "when incorrect params" do
      let(:incorect_params) { { user: attributes_for(:user, email: nil) }.to_json }

      it "should not update" do
        patch url, headers: auth_header(users.last), params: incorect_params

        user_saved.reload
        expect(user_saved.email).to eq "teste@teste.com"
      end

      it "should return error message" do
        patch url, headers: auth_header(users.last), params: incorect_params

        expect(body_json["errors"]["fields"]).to have_key("email")
      end

      it "should return error if change email to email already in use" do
        new_user_attr = User.new
        new_user_attr.attributes = attributes_for(:user, email: "mail@mail.com")
        new_user_attr.save!

        user_with_email_already_in_use = JSON.parse(incorect_params)
        user_with_email_already_in_use["user"]["email"] = "mail@mail.com"

        patch url, headers: auth_header(users.last), params: user_with_email_already_in_use.to_json

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "DELETE /users" do
    let!(:user) { create(:user) }
    let(:url) { "/admin/v1/users/#{user.id}" }

    it "should remove an user" do
      expect do
        delete url, headers: auth_header(users.last)
      end.to change(User, :count).by(-1)
    end

    it "should does not returns any body content" do
      delete url, headers: auth_header(users.last)
      expect(body_json).to_not be_present
    end

    it "should return status :no_content" do
      delete url, headers: auth_header(users.last)
      expect(response).to have_http_status(:no_content)
    end
  end
end
