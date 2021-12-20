FactoryBot.define do
  factory :coupon do
    code { "MyString" }
    status { 1 }
    decimal_value { "" }
    due_date { "2021-12-19 21:05:20" }
  end
end
