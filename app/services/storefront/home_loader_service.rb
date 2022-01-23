module Storefront
  class HomeLoaderService
    QUANTITY_OF_RECORDS_PER_GROUP = 4
    MIN_RELASE_DAYS = 7

    attr_reader :featured, :last_releases, :cheapest

    def initialize
      @featured = []
      @last_releases = []
      @cheapest = []
    end

    def call
      @games = Product.joins("JOIN games ON productable_type = 'Game' AND productable_id = games.id")
      get_featured_games
      get_releases_games
      get_cheapest_games
    end

    private

    def get_featured_games
      @featured = @games.where(featured: true, status: :available).sample(QUANTITY_OF_RECORDS_PER_GROUP)
    end

    def get_releases_games
      @last_releases
    end

    def get_cheapest_games
      @cheapest
    end
  end
end
