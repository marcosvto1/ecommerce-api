require 'rails_helper'

RSpec.describe 'Admin::V1::License as :admin', type: :request do
  let!(:user) { create(:user) }
  let!(:game) { create(:game) }

  context 'GET /games/:game_id/licenses' do
    let(:url) { "/admin/v1/games/#{game.id}/licenses" }
    let!(:licenses) { create_list(:license, 20, game: game) }

    context 'without any params' do
      before(:each) { get url, headers: auth_header(user) }

      it 'should returns 10 first records' do
        expected_records = licenses[0..9].as_json only: %i(id key platform status game_id)

        expect(body_json['licenses']).to contain_exactly *expected_records
      end

      it 'should returns 10 records' do
        expect(body_json['licenses'].count).to eq 10
      end

      it 'should returns success status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with search[:key] params' do
      let!(:searched_list) {
        licences_search = []
        10.times { |index| licences_search << create(:license, key: "KeySearched#{index}", game: game) }
        licences_search
      }
      let(:search_params) { { search: { key: 'KeySearched' } } }

      before(:each) { get url, headers: auth_header(user), params: search_params }

      it 'should returns 10 registers' do
        expect(body_json['licenses'].count).to eq 10
      end

      it 'should return 10 licenses' do
        expected_lincenses = searched_list[0..9].map do |item|
          item.as_json only: %i(id key platform status game_id)
        end
        expect(body_json['licenses']).to contain_exactly *expected_lincenses
      end

      it 'should return success status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with paginate params' do
      let(:page) { 2 }
      let(:length) { 5 }
      let(:paginate_params) { { page: page, length: length } }

      before(:each) { get url, headers: auth_header(user), params: paginate_params }

      it 'should returns 5 registers' do
        expect(body_json['licenses'].count).to eq length
      end

      it 'should returns 5 licenses' do
        expected_licences = licenses[5..9].as_json only: %i(id key platform status game_id)
        expect(body_json['licenses']).to contain_exactly *expected_licences
      end

      it 'should returns success status' do
        expect(response).to have_http_status(:ok)
      end
    end

    context 'with order params' do
      let(:order_params) { { order: { key: :desc } } }

      before(:each) { get url, headers: auth_header(user), params: order_params }

      it 'should returns 10 ordered registers' do
        licenses.sort! { |a, b| b[:key] <=> a[:key] }
        expected_licenses = licenses[0..9].as_json only: %i(id key platform status game_id)

        expect(body_json['licenses']).to contain_exactly *expected_licenses
      end
    end
  end

  context 'GET /licenses/:id' do
    let(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    before(:each) { get url, headers: auth_header(user) }

    it 'should returns requested lincense' do
      expected_license = license.as_json only: [:id, :key, :game_id, :status, :platform]
      expect(body_json['license']).to contain_exactly *expected_license
    end

    it 'should returns success status' do
      expect(response).to have_http_status(:ok)
    end
  end

  context 'POST /licenses' do
    let!(:game) { create(:game) }
    let(:url) { "/admin/v1/games/#{game.id}/licenses" }

    context 'with correct params' do
      let(:correct_params) { { license: attributes_for(:license, game_id: game.id) }.to_json }

      it 'should creates a new license' do
        expect {
          post url, headers: auth_header(user), params: correct_params
        }.to change(License, :count).by(1)
      end

      it 'should return a new license' do
        post url, headers: auth_header(user), params: correct_params
        expected_license = License.last.as_json(only: [:id, :key, :game_id, :platform, :status])
        expect(body_json['license']).to contain_exactly *expected_license
      end

      it 'should returns created status' do
        post url, headers: auth_header(user), params: correct_params
        expect(response).to have_http_status(:created)
      end
    end

    context 'with incorrect params' do
      let(:incorrect_params) { { license: attributes_for(:license, key: '', game_id: game.id) }.to_json }
      let(:incorrect_params_game_empty) { { license: attributes_for(:license) }.to_json }
      it 'should not create license if not informed key' do
        expect {
          post url, headers: auth_header(user), params: incorrect_params
        }.to change(License, :count).by(0)
        expect(body_json['errors']['fields']).to have_key('key')
      end

      it 'should not create license if not informed game_id' do
        expect {
          post url, headers: auth_header(user), params: incorrect_params_game_empty
        }.to change(License, :count).by(0)
        expect(body_json['errors']['fields']).to have_key('game')
      end

      it 'returns unprocessable_entiy status' do
        post url, headers: auth_header(user), params: incorrect_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  context 'PATH /licenses/:id' do
    let(:license) { create(:license)}
    let(:url) { "/admin/v1/licenses/#{license.id}"}

    context 'with valid params' do
      let(:key) { 'newkey' }
      let(:license_params) { { license: { key: key } }.to_json }

      it 'should updates License' do
        patch url, headers: auth_header(user), params: license_params
        license.reload
        expect(license.key).to eq key
      end

      it 'should returns updated License' do
        patch url, headers: auth_header(user), params: license_params
        license.reload
        expected_license = license.as_json(only: %i(id key platform status game_id))
        expect(body_json['license']).to eq expected_license
      end

      it 'should returns success status' do
        patch url, headers: auth_header(user), params: license_params
        expect(response).to have_http_status(:ok)
      end
    end
    context 'with invalid params' do
      let(:license_invalid_params) do
        { license: attributes_for(:license, key: nil) }.to_json
      end

      it 'should does not update license' do
        old_key = license.key
        patch url, headers: auth_header(user), params: license_invalid_params
        license.reload
        expect(license.key).to eq old_key
      end

      it 'should return error message' do
        patch url, headers: auth_header(user), params: license_invalid_params
        expect(body_json['errors']['fields']).to have_key('key')
      end

      it 'returns unprocessable_entiy status' do
        patch url, headers: auth_header(user), params: license_invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

  end

  context 'DELETE /licenses/:id' do
    let!(:license) { create(:license) }
    let(:url) { "/admin/v1/licenses/#{license.id}" }

    it 'should remove License' do
      expect do
        delete url, headers: auth_header(user)
      end.to change(License, :count).by(-1)
    end

    it 'returns success status' do
      delete url, headers: auth_header(user)
      expect(response).to have_http_status(:no_content)
    end
  end
end
