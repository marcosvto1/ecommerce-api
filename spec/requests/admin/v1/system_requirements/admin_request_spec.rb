require "rails_helper"

RSpec.describe "Admin::V1::SystemRequirement as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    let!(:system_requirements) { create_list(:system_requirement, 3) }

    it "should returns all system_requirements" do
      get url, headers: auth_header(user)
      expect(body_json["system_requirements"]).to contain_exactly *system_requirements.as_json(only: %i(id name))
    end

    it "should returns status ok" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "POST /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    context "when invalid params" do
      let(:invalid_params) do
        { system_requirement: attributes_for(:system_requirement, name: nil, processor: nil) }.to_json
      end
      it "should does not save system_requirement" do
        expect do
          post url, headers: auth_header(user), params: invalid_params
        end.to_not change(SystemRequirement, :count)
      end

      it "should return error" do
        post url, headers: auth_header(user), params: invalid_params
        expect(body_json["errors"]["fields"]).to have_key("name")
        expect(body_json["errors"]["fields"]).to have_key("processor")
      end

      it "should return :unprocessable_entity status" do
        post url, headers: auth_header(user), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "when valida params" do
    end
  end
end
