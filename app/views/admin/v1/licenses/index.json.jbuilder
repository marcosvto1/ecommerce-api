json.licenses do
  json.array! @loading_service.records, :id, :key, :game_id, :status, :platform
end

json.meta do
  json.partial! 'shared/pagination', pagination: @loading_service.pagination
end