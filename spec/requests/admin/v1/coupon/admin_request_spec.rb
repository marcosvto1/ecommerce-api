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
      let(:incorrect_params) { { coupon: attributes_for(:coupon, code: nil, due_date: nil, discount_value: 0) }.to_json }

      it "should not save coupon" do
        expect do
          post url, headers: auth_header(user), params: incorrect_params
        end.to_not change(Coupon, :count)
      end

      it "should return an error if code does not provided" do
        post url, headers: auth_header(user), params: incorrect_params
        expect(body_json["errors"]["fields"]).to have_key("code")
        expect(body_json["errors"]["fields"]).to have_key("due_date")
        expect(body_json["errors"]["fields"]).to have_key("discount_value")
      end

      it "should return an error if due_date is before than current date" do
        incorrect = JSON.parse(incorrect_params)
        incorrect["coupon"]["due_date"] = Time.now - 1.days
        post url, headers: auth_header(user), params: incorrect.to_json
        expect(body_json["errors"]["fields"]).to have_key("due_date")
        expect(body_json["errors"]["fields"]).to have_key("code")
      end

      it "returns unprocessable_entiy status" do
        post url, headers: auth_header(user), params: incorrect_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "PATCH /coupons/:id" do
      let!(:coupon) { create(:coupon, code: "NATAL10") }
      let!(:coupon_saved) { create(:coupon, code: "NATAL20") }
      let(:url) { "/admin/v1/coupons/#{coupon.id}" }

      context "when invalid params" do
        let(:incorrect_params) { { coupon: attributes_for(:coupon, code: nil) }.to_json }
        it "should not update coupon" do
          patch url, headers: auth_header(user), params: incorrect_params
          coupon.reload

          expect(coupon.code).to eq "NATAL10"
        end

        it "returns unprocessable_entiy status" do
          patch url, headers: auth_header(user), params: incorrect_params
          expect(response).to have_http_status(:unprocessable_entity)
        end

        it "should returns an error if change code to a exists" do
          coupon_with_code_is_already_in_use = { coupon: attributes_for(:coupon, code: "NATAL20") }.to_json

          patch url, headers: auth_header(user), params: coupon_with_code_is_already_in_use

          expect(body_json["errors"]["fields"]).to have_key("code")
        end

        it "should returns an error if change due_date to a before date current" do
          coupon_with_due_date_before_dt_current = { coupon: attributes_for(:coupon, code: "NATAL10", due_date: Date.today - 1) }.to_json

          patch url, headers: auth_header(user), params: coupon_with_due_date_before_dt_current

          expect(body_json["errors"]["fields"]).to have_key("due_date")
        end

        it "should returns an error if change discount_value to 0" do
          coupon_with_discount_value_invalid = { coupon: attributes_for(:coupon, code: "NATAL10", discount_value: 0) }.to_json

          patch url, headers: auth_header(user), params: coupon_with_discount_value_invalid

          expect(body_json["errors"]["fields"]).to have_key("discount_value")
        end
      end

      context "when correct params" do
        let(:correct_params) { { coupon: attributes_for(:coupon, code: "NEWYEAR10") }.to_json }

        it "should update a coupon" do
          patch url, headers: auth_header(user), params: correct_params

          coupon.reload
          expect(coupon.code).to eq "NEWYEAR10"
        end

        it "should returns status ok" do
          patch url, headers: auth_header(user), params: correct_params

          expect(response).to have_http_status(:ok)
        end

        it "should returns coupon an updated" do
          patch url, headers: auth_header(user), params: correct_params
          coupon.reload
          expect(body_json["coupon"]).to contain_exactly *coupon.as_json(only: only_attr)
        end
      end
    end

    context "DELETE /coupons/#{id}" do
      let!(:coupon) { create(:coupon, code: "NATAL10") }
      let(:url) { "/admin/v1/coupons/#{coupon.id}" }

      it "should delete an coupon" do
        expect do
          delete url, headers: auth_header(user)
        end.to change(Coupon, :count).by(-1)
      end

      it "should returns status no_content if delete performed successfully" do
        delete url, headers: auth_header(user)
        expect(response).to have_http_status(:no_content)
      end

      it "should returns empty content" do
        delete url, headers: auth_header(user)
        expect(body_json).to_not be_present
      end
    end
  end
end
