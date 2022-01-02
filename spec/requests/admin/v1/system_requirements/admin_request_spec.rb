require "rails_helper"

RSpec.describe "Admin::V1::SystemRequirement as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    let!(:system_requirements) { create_list(:system_requirement, 3) }

    it "should returns all system_requirements" do
      get url, headers: auth_header(user)
      expect(body_json["system_requirements"]).to contain_exactly *system_requirements.as_json(only: %i(id name processor memory operational_system video_board))
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

    context "when valid params" do
      let(:correct_params) do
        { system_requirement: attributes_for(:system_requirement) }.to_json
      end

      it "should create an new system_requirement" do
        expect do
          post url, headers: auth_header(user), params: correct_params
        end.to change(SystemRequirement, :count).by(1)
      end

      it "should return status ok" do
        post url, headers: auth_header(user), params: correct_params
        expect(response).to have_http_status(:ok)
      end
    end
  end

  context "PUT /system_requirements" do
    let(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    describe "when correct params" do
      let(:correct_params) do
        { system_requirement: attributes_for(:system_requirement, name: "Nova System") }.to_json
      end

      it "should update system_requirement" do
        patch url, headers: auth_header(user), params: correct_params
        system_requirement.reload
        expect(system_requirement.name).to eq "Nova System"
      end

      it "should returns status :ok" do
        patch url, headers: auth_header(user), params: correct_params
        expect(response).to have_http_status(:ok)
      end

      it "should returns system_requirement updated" do
        patch url, headers: auth_header(user), params: correct_params
        system_requirement.reload
        expected_system_requirement = system_requirement.as_json except: %i(created_at updated_at)
        expect(body_json["system_requirement"]).to eq expected_system_requirement
      end
    end

    describe "when incorrect params" do
      let(:incorret_params) do
        { system_requirement: attributes_for(:system_requirement, name: nil, storage: nil) }.to_json
      end

      it "should does not update system_requirement" do
        old_system_requirement = system_requirement.name
        patch url, headers: auth_header(user), params: incorret_params
        system_requirement.reload
        expect(system_requirement.name).to eq old_system_requirement
      end

      it "should returns unprocessable_entiy status" do
        patch url, headers: auth_header(user), params: incorret_params
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "should returns errors messages" do
        patch url, headers: auth_header(user), params: incorret_params
        expect(body_json["errors"]["fields"]).to have_key("name")
      end
    end
  end

  describe "DELETE /system_requirements/:id" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    it "should remove system_requirement" do
      expect do
        delete url, headers: auth_header(user)
      end.to change(SystemRequirement, :count).by(-1)
    end

    it "should returns statys :no_content" do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it "should does not returns content in body" do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end

    it "should returns error if has games associated" do
      games = create_list(:game, 2, system_requirement: system_requirement)
      delete url, headers: auth_header(user)

      expect(body_json["errors"]["fields"]).to have_key("base")
    end
  end
end
