require "rails_helper"

RSpec.describe "Admin::V1::Coupon as :guest", type: :request do
  context "GET /coupons" do
    let(:url) { "/admin/v1/coupons" }
    let!(:coupon) { create_list(:coupon, 3) }

    before(:each) do
      get url
    end

    include_examples "unauthenticated access"
  end

  context "POST /coupons" do
    let(:url) { "/admin/v1/coupons" }

    let(:params) { { coupon: attributes_for(:coupon) }.to_json }

    before(:each) do
      post url, params: params
    end

    include_examples "unauthenticated access"
  end

  context "PATCH /coupons" do
    let!(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }
    let(:params) { { coupon: attributes_for(:coupon) }.to_json }

    before(:each) do
      patch url, params: params
    end

    include_examples "unauthenticated access"
  end

  context "DELETE /coupons" do
    let!(:coupon) { create(:coupon) }
    let(:url) { "/admin/v1/coupons/#{coupon.id}" }

    before(:each) do
      delete url
    end

    include_examples "unauthenticated access"
  end
end
