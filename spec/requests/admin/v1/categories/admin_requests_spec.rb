require "rails_helper"

RSpec.describe "Admin::V1::Categories as :admin", type: :request do
  let(:user) { create(:user) }

  context "GET /categories" do
    let(:url) { "/admin/v1/categories" }
    let!(:categories) { create_list(:category, 10) }

    context "without any params" do
      it "should returns 10 Categories" do
        get url, headers: auth_header(user)

        expect(body_json["categories"].count).to eq 10
      end

      it "should return 10 first categories" do
        get url, headers: auth_header(user)
        expected_categories = categories[0..9].as_json only: %i(id name)

        expect(body_json["categories"]).to contain_exactly *expected_categories
      end

      it "should return success status" do
        get url, headers: auth_header(user)

        expect(response).to have_http_status(:ok)
      end

      it_behaves_like "pagination meta attributes", { page: 1, length: 10, total_pages: 1 } do
        before { get url, headers: auth_header(user)}
      end
    end

    context "with search[name] params" do
      let!(:search_name_categories) do
        categories = []
        15.times { |n| categories << create(:category, name: "Search #{n + 1}") }
        categories
      end

      let(:search_params) { { search: { name: "Search" } } }

      it "should returns only seached categories limited by default pagination" do
        get url, headers: auth_header(user), params: search_params
        expected_categories = search_name_categories[0..9].map do |category|
          category.as_json only: %i(id name)
        end

        expect(body_json["categories"]).to contain_exactly *expected_categories
      end

      it "should return success status" do
        get url, headers: auth_header(user), params: search_params

        expect(response).to have_http_status(:ok)
      end

      it_behaves_like "pagination meta attributes", { page: 1, length: 10, total_pages: 2 } do
        before { get url, headers: auth_header(user), params: search_params }
      end
    end

    context "with pagination params" do
      let(:page) { 2 }
      let(:length) { 5 }

      let(:pagination_params) { { page: page, length: length } }

      it "should returns categories size by :length" do
        get url, headers: auth_header(user), params: pagination_params

        expect(body_json["categories"].count).to eq length
      end

      it "should returns categories limited by pagination" do
        get url, headers: auth_header(user), params: pagination_params

        expected_categories = categories[5..9].as_json only: %i(id name)

        expect(body_json["categories"]).to contain_exactly *expected_categories
      end

      it "should return success status" do
        get url, headers: auth_header(user), params: pagination_params

        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 2, length: 5, total_pages: 2 } do
        before { get url, headers: auth_header(user), params: pagination_params }
      end
    end

    context "when order params" do
      let(:order_params) { { order: { name: "desc" } } }

      it "should returns ordered categories limited by default pagination" do
        get url, headers: auth_header(user), params: order_params
        categories.sort! { |a, b| b[:name] <=> a[:name] }
        expected_categories = categories[0..9].as_json only: %i(id name)

        expect(body_json["categories"]).to contain_exactly *expected_categories
      end

      it "should return success status" do
        get url, headers: auth_header(user), params: order_params

        expect(response).to have_http_status(:ok)
      end

      it_behaves_like 'pagination meta attributes', { page: 1, length: 10, total_pages: 1 } do
        before { get url, headers: auth_header(user), params: order_params }
      end
    end
  end

  context "GET /categories/id" do
    let!(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    it "should return requested category" do
      get url, headers: auth_header(user)
      expected_category = category.as_json only: %i(id name)

      expect(body_json["category"]).to eq expected_category
    end

    it "should returns success status" do
      get url, headers: auth_header(user)

      expect(response).to have_http_status(:ok)
    end
  end

  context "POST /categories" do
    let(:url) { "/admin/v1/categories" }

    context "with valida params" do
      let(:category_param) { { category: attributes_for(:category) }.to_json }

      it "add a new Category" do
        expect do
          post url, headers: auth_header(user), params: category_param
        end.to change(Category, :count).by(1)
      end

      it "returns last added category" do
        post url, headers: auth_header(user), params: category_param
        expect_category = Category.last.as_json(only: %i(id name))
        expect(body_json["category"]).to eq expect_category
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

      it "does not add a new category" do
        expect do
          post url, headers: auth_header(user), params: category_invalid_param
        end.to_not change(Category, :count)
      end

      it "returns error messages" do
        post url, headers: auth_header(user), params: category_invalid_param
        expect(body_json["errors"]["fields"]).to have_key("name")
        #expect(body_json["errors"]["fields"]).to have_key("processor")
      end

      it "returns unprocessable_entiy status" do
        post url, headers: auth_header(user), params: category_invalid_param
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context "PATCH /categories/:id" do
    let(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    describe "when valid params" do
      let(:new_name) { "My new category" }
      let(:category_params) { { category: { name: new_name } }.to_json }

      it "updates category " do
        patch url, headers: auth_header(user), params: category_params
        category.reload
        expect(category.name).to eq new_name
      end

      it "returns updated category" do
        patch url, headers: auth_header(user), params: category_params
        category.reload
        expect_category = category.as_json(only: %i(id name))
        expect(body_json["category"]).to eq expect_category
      end

      it "return success status" do
        patch url, headers: auth_header(user), params: category_params

        expect(response).to have_http_status(:ok)
      end
    end

    describe "when invalid params" do
      let(:category_invalid_param) do
        { category: attributes_for(:category, name: nil) }.to_json
      end

      it "does not update" do
        old_name = category.name
        patch url, headers: auth_header(user), params: category_invalid_param
        category.reload

        expect(category.name).to eq old_name
      end

      it "returns unprocessable_entiy status" do
        patch url, headers: auth_header(user), params: category_invalid_param
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it "returns error messages" do
        patch url, headers: auth_header(user), params: category_invalid_param
        expect(body_json["errors"]["fields"]).to have_key("name")
      end
    end
  end

  context "DELETE /categories" do
    let!(:category) { create(:category) }
    let(:url) { "/admin/v1/categories/#{category.id}" }

    it "removes categories" do
      expect do
        delete url, headers: auth_header(user)
      end.to change(Category, :count).by(-1)
    end

    it "returns success status" do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end

    it "does not returns any body content" do
      delete url, headers: auth_header(user)
      expect(body_json).to_not be_present
    end

    it "removes all associated products categories" do
      product_categories = create_list(:product_category, 3, category: category)
      delete url, headers: auth_header(user)
      expected_product_categories = ProductCategory.where(id: product_categories.map(&:id))
      expect(expected_product_categories).to eq []
    end
  end
end
