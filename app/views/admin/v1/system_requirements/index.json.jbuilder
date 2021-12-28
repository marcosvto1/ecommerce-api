json.system_requirements do
  json.array! @system_requirements do |system_requirement|
    json.id system_requirement.id
    json.name system_requirement.name
    json.memory system_requirement.memory
    json.processor system_requirement.processor
    json.video_board system_requirement.video_board
    json.operational_system system_requirement.operational_system
  end
end
