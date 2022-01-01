require "rails_helper"

RSpec.describe "Admin::V1::Coupon as :admin", type: :request do
  let(:user) { create(:user) }
  let(:only_attr) { %i(id code discount_value due_date status) }

  context "GET /coupons" do
    let(:url) { "/admin/v1/coupons" }
    let!(:coupons) { create_list(:coupon, 2) }

    it "should return all coupons" do
      get url, headers: auth_header(user)
      expect(body_json["coupons"]).to contain_exactly *coupons.as_json(only: %i(id code discount_value due_date status))
    end

    it "should retuns status :ok" do
      get url, headers: auth_header(user)
      expect(response).to have_http_status(:ok)
    end
  end

  context "POST /coupons" do
    let(:url) { "/admin/v1/coupons" }
    context "when correct params" do
      let(:correct_params) { { coupon: attributes_for(:coupon) }.to_json }

      it "should create an new coupon" do
        expect do
          post url, headers: auth_header(user), params: correct_params
        end.to change(Coupon, :count).by(1)
      end

      it "should returns an new coupon created" do
        post url, headers: auth_header(user), params: correct_params
        expect_coupon = Coupon.last.as_json(only: only_attr)
        expect(body_json["coupon"]).to eq expect_coupon
      end

      it "should retuns success status" do
        post url, headers: auth_header(user), params: correct_params
        expect(response).to have_http_status(:ok)
      end
    end
    context "when invalid params" do
    end
  end
end
