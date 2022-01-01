json.coupon do
  json.id @coupon.id
  json.code @coupon.code
  json.due_date @coupon.due_date
  json.discount_value @coupon.discount_value
  json.status @coupon.status
end
