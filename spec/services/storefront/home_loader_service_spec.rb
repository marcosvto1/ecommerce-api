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

      it "should not returns unavailiable or non-featured products" do
        service = described_class.new
        service.call

        expect(service.featured).to_not include(unavailable_products, non_featured_products)
      end
    end

    context "on recently released products using 7 days default" do
      let!(:non_last_release_products) do
        products = []
        5.times do
          game = create(:game, release_date: 8.days.ago)
          products << create(:product, productable: game)
        end
        products
      end

      let!(:last_release_products) do
        products = []
        5.times do
          game = create(:game, release_date: rand(1 - 6).days.ago)
          products << create(:product, productable: game)
        end
        products
      end

      it "should returns 4 records" do
        service = described_class.new
        service.call
        expect(service.last_releases.count).to eq 4
      end

      it "returns random last released available products" do
        service = described_class.new
        service.call
        expect(service.last_releases).to satisfy do |expected_products|
          byebug
          expected_products & last_release_products == expected_products
        end
      end
    end
  end
end
