require "rails_helper"

RSpec.describe "Admin::V1::Categories as :guest", type: :request do
  context "GET /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }
    let!(:system_requirement) { create_list(:system_requirement, 3) }

    before(:each) do
      get url
    end

    include_examples "unauthenticated access"
  end

  context "POST /system_requirements" do
    let(:url) { "/admin/v1/system_requirements" }

    let(:params) { { system_requirement: attributes_for(:system_requirement) }.to_json }

    before(:each) do
      post url, params: params
    end

    include_examples "unauthenticated access"
  end

  context "PATCH /system_requirements" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }
    let(:params) { { system_requirement: attributes_for(:system_requirement) }.to_json }

    before(:each) do
      patch url, params: params
    end

    include_examples "unauthenticated access"
  end

  context "DELETE /system_requirements" do
    let!(:system_requirement) { create(:system_requirement) }
    let(:url) { "/admin/v1/system_requirements/#{system_requirement.id}" }

    before(:each) do
      delete url
    end

    include_examples "unauthenticated access"
  end
end
