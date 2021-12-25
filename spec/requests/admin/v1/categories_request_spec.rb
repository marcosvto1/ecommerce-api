require 'rails_helper'

RSpec.describe "Admin::V1::Categories", type: :request do
  let(:user) { create(:user) }

  context "GET /categories" do
    let(:url) { "/admin/v1/categories"}
    let!(:categories) { create_list(:category, 5)}

    it "return all categories" do
      get url, headers: auth_header(user)
      expect(body_json['categories']).to contain_exactly *categories.as_json(only: %i(id name))
    end

    it "return success status" do 
      get url, headers: auth_header(user)

      expect(response).to have_http_status(:ok)
    end
  end

  context "POST /categories" do
   let(:url) { "/admin/v1/categories"}

    context "with valida params" do
      let(:category_param) { { category: attributes_for(:category) }.to_json }

      it 'add a new Category' do
        expect do
          post url, headers: auth_header(user), params: category_param
        end.to change(Category, :count).by(1)
      end

      it 'returns last added category' do
        post url, headers: auth_header(user), params: category_param
        expect_category = Category.last.as_json(only: %i(id name))
        expect(body_json['category']).to eq expect_category
      end

      it "return success status" do 
        post url, headers: auth_header(user), params: category_param
  
        expect(response).to have_http_status(:ok)
      end
    end

    context "with invalid params" do
      let(:category_invalid_param) do 
        { category: attributes_for(:category, name: nil) }.to_json
      end

      it 'does not add a new category' do
        expect do
          post url, headers: auth_header(user), params: category_invalid_param
        end.to_not change(Category, :count)
      end

      it 'returns error messages' do
        post url, headers: auth_header(user), params: category_invalid_param
        expect(body_json['errors']['fields']).to have_key('name')
      end

      it 'returns unprocessable_entiy status' do
        post url, headers: auth_header(user), params: category_invalid_param
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end
end
