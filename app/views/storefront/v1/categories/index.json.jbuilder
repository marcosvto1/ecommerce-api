json.categories do
  json.array! @categories do |category|
    json.(category, :id, :name)
  end
end