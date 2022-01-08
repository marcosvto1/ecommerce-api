FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    description { Faker::Lorem.paragraph }
    image { Rack::Test::UploadedFile.new(Rails.root.join("spec/support/images/product_image.png")) }
    price { Faker::Commerce.price(range: 100.0..400.0) }
    status { :available }

    after :build do |product|
      product.productable = create(:game)
    end
  end
end
