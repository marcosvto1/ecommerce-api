require "rails_helper"

RSpec.describe "Admin::V1::Coupon as :client", type: :request do
  !let(:user) { create(:user, profile: :client) }

  context "GET /cupons" do
    let(:url) { "/admin/v1/coupons" }

    before(:each) { get url, headers: auth_header(user) }

    include_examples "forbidden access"
  end

  context "POST /coupons" do
    let(:params) { attributes_for(:user) }
    let(:url) { "/admin/v1/coupons" }

    before(:each) { post url, headers: auth_header(user), params: params }

    include_examples "forbidden access"
  end

  context "PATCH /coupons/:id" do
    let!(:coupon) { create(:coupon) }
    let(:params) { attributes_for(:user) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    before(:each) { patch url, headers: auth_header(user), params: params }

    include_examples "forbidden access"
  end

  context "DELETE /coupon/:id" do
    let!(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    before(:each) { delete url, headers: auth_header(user) }

    include_examples "forbidden access"
  end
end
