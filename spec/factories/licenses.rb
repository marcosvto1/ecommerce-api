FactoryBot.define do
  factory :license do
    key { Faker::Crypto.md5 }
    platform { :steam }
    status { :available }
    game
  end
end
