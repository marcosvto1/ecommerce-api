FactoryBot.define do
  factory :game do
    mode { %i(pvp pve both).sample }
    release_date { "2021-12-19 20:10:34" }
    developer { Faker::Company.name }
    system_requirement
  end
end
