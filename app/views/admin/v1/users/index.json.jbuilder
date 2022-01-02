json.users do
  json.array! @users do |user|
    json.id user.id
    json.name user.name
    json.profile user.profile
    json.email user.email
  end
end
