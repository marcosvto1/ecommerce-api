json.licenses do
  json.array! @loading_service.records, :id, :key, :game_id
end
