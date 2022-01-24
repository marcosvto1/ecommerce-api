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
      games = Product.joins("JOIN games ON productable_type = 'Game' AND productable_id = games.id").
        includes(productable: [:game]).where(status: :available)
      get_featured_games games
      get_releases_games games
      get_cheapest_games games
    end

    private

    def get_featured_games(games)
      @featured = games.where(featured: true).sample(QUANTITY_OF_RECORDS_PER_GROUP)
    end

    def get_releases_games(games)
      @last_releases = games.where(games: {
                                     release_date: MIN_RELASE_DAYS.days.ago.beginning_of_day..Time.now.end_of_day,
                                   }).sample(QUANTITY_OF_RECORDS_PER_GROUP)
    end

    def get_cheapest_games(games)
      @cheapest = games.order(price: :asc).take(QUANTITY_OF_RECORDS_PER_GROUP)
    end
  end
end
