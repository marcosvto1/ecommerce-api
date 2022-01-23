require "rails_helper"

describe Storefront::HomeLoaderService do
  context "when #call" do
    let!(:unavailable_products) do
      products = []
      5.times do
        game = create(:game, release_date: 2.days.ago)
        products = create(:product, productable: game, price: 5.00, status: :unavailable)
      end
      products
    end

    context "on feature products" do
      let!(:non_featured_products) { create_list(:product, 5, featured: false) }
      let!(:featured_products) { create_list(:product, 5) }

      it "should returns 4 records" do
        service = described_class.new
        service.call

        expect(service.featured.count).to eq 4
      end

      it "should returns random featured availiable product" do
        service = described_class.new
        service.call

        expect(service.featured).to satisfy do |expected_products|
          expected_products & featured_products == expected_products
        end
      end
    end
  end
end
