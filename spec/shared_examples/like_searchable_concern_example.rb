shared_examples "like searchable concern" do |factory_name, field|
  let!(:search_params) { "Example" }
  let!(:record_to_find) do
    (0..3).to_a.map { |index| create(factory_name, field => "Example #{index}") }
  end
  let!(:record_to_ignore) { create_list(factory_name, 3) }

  it "found record with expression in :#{field}" do
    found_records = described_class.like(field, search_params)

    expect(found_records.to_a).to contain_exactly(*record_to_find)
  end

  it "ignore record without expression in :#{field}" do
    found_records = described_class.like(field, search_params)

    expect(found_records.to_a).to_not contain_exactly(*record_to_ignore)
  end
end
