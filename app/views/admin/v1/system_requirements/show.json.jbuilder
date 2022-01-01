json.system_requirement do
  json.id @system_requirement.id
  json.name @system_requirement.name
  json.processor @system_requirement.processor
  json.memory @system_requirement.memory
  json.storage @system_requirement.storage
  json.video_board @system_requirement.video_board
  json.operational_system @system_requirement.operational_system
end
