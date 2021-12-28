json.system_requirements do
  json.array! @system_requirements do |system_requirement|
    json.id system_requirement.id
    json.name system_requirement.name
  end
end
