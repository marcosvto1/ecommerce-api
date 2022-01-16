require "rails_helper"

describe Admin::ModelLoadingService do
  context "when #call" do
    let!(:system_requirements) { create_list(:system_requirement, 15) }

    context "when params are present" do
      let!(:search_system_requirements) do
        system_requirements = []
        15.times { |n| system_requirements << create(:system_requirement, name: "Search #{n + 1}", video_board: "GeForce") }
        system_requirements
      end

      let!(:not_expected_search_system_requirements) do
        system_requirements = []
        15.times { |n| system_requirements << create(:system_requirement, name: "Search #{n + 16}") }
        system_requirements
      end


      let(:params) do
        { search: { name: "Search", video_board: "GeFor" }, order: { name: :desc }, page: 2, length: 4 }
      end

      it "should returns right :length following pagination" do
        service = described_class.new(SystemRequirement.all, params)
        service.call

        expect(service.records.count).to eq 4
      end

      it "should returns following search, order and pagination" do
        # se o B for maior q o A return 1
        # se o B E A for iguais vai retorna 0
        # se o B for menor que a vai retorna -1
        # Ordenacao desc
        search_sys_req = search_system_requirements
        search_sys_req.sort! { |a, b| b[:name] <=> a[:name] }
        service = described_class.new(SystemRequirement.all, params)
        service.call
        expected_system_requirements = search_sys_req[4..7]
        expect(service.records).to contain_exactly *expected_system_requirements
      end

      it "sets right :page" do
        service = described_class.new(SystemRequirement.all, params)
        service.call

        expect(service.pagination[:page]).to eq 2
      end

      it "sets right :length" do
        service = described_class.new(SystemRequirement.all, params)
        service.call
        expect(service.pagination[:length]).to eq 4
      end

      it "sets right :total" do
        service = described_class.new(SystemRequirement.all, params)
        service.call

        expect(service.pagination[:total]).to eq 15
      end

      it "sets rigth :total_pages" do
        service = described_class.new(SystemRequirement.all, params)
        service.call

        expect(service.pagination[:total_pages]).to eq 4
      end

      it "should does not return unaexpected records" do
        params.merge!(page: 1, length: 50)
        service = described_class.new(SystemRequirement.all, params)
        service.call
        expect(service.records).to_not include *not_expected_search_system_requirements
      end
    end

    context "when params are not present" do
      it "should returns defualt length pagination" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expect(service.records.count).to eq 10
      end

      it "should return first 10 records" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expected_system_requirements = system_requirements[0..9]
        expect(service.records).to contain_exactly *expected_system_requirements
      end

      it "should sets right :page" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expect(service.pagination[:page]).to eq 1
      end

      it "should sets right :length" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expect(service.pagination[:length]).to eq 10
      end

      it "should sets right :total" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expect(service.pagination[:total]).to eq 15
      end

      it "should sets right :total_pages" do
        service = described_class.new(SystemRequirement.all, nil)
        service.call
        expect(service.pagination[:total_pages]).to eq 2
      end

    end
  end
end
