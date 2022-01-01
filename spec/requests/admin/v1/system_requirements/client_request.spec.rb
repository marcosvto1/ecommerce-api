require "rails_helper"

RSpec.describe "Admin::V1::SystemRequirement as :client", type: :request do
  let(:user) { create(:user, profile: :client) }

  context "GET /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    let!(:system_requirement) { create_list(:system_requirement, 3) }

    before(:each) do
      get url, headers: auth_header(user)
    end

    include_examples "forbidden access"
  end

  context "POST /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }

    let(:params) { { system_requirement: attributes_for(:system_requirement) }.to_json }

    before(:each) do
      post url, headers: auth_header(user), params: params
    end

    include_examples "forbidden access"
  end

  context "PATCH /system_requirements" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }
    let(:params) { { system_requirement: attributes_for(:system_requirement) }.to_json }

    before(:each) do
      patch url, headers: auth_header(user), params: params
    end

    include_examples "forbidden access"
  end

  context "DELETE /system_requirements" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    before(:each) do
      delete url, headers: auth_header(user)
    end

    include_examples "forbidden access"
  end
end
