require 'rails_helper'

RSpec.describe '/PATCH Projects', type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project, user: user) }
  let(:unauthorized_user) { create(:user) }

  context 'When user edits project belonging to the user' do
    before do
      login_with_api(user)
      patch "/api/v1/projects/#{project.id}", headers: {
        Authorization: response.headers['Authorization']
      }, params: {
        project: {
          title: 'Updated Project'
        }
      }
    end

    it 'returns 200' do
      expect(response.status).to eq(200)
    end

    it 'returns the updated project' do
      project.reload
      expect(json['id']).to eq(project.id)
      expect(json['title']).to eq(project.title)
    end

    it 'updates the project title' do
      project.reload
      expect(project.title).to eq('Updated Project')
    end
  end

  context 'When user tries to update project not belonging to them' do
    before do
      login_with_api(unauthorized_user)
      patch "/api/v1/projects/#{project.id}", headers: {
        Authorization: response.headers['Authorization']
      }, params: {
        project: {
          title: 'Updated Project'
        }
      }
    end

    it 'returns 401' do
      expect(response.status).to eq(401)
    end

    it 'does not change the project title' do
      project.reload
      expect(project.title).to eq('Project')
    end
  end

  context 'When user tries to update default inbox project' do
    before do
      login_with_api(user)
      patch "/api/v1/projects/#{user.inbox.id}", headers: {
        Authorization: response.headers['Authorization']
      }, params: {
        project: {
          title: 'Updated Project'
        }
      }
    end

    it 'returns 401' do
      expect(response.status).to eq(401)
    end

    it 'does not change the project title' do
      user.inbox.reload
      expect(user.inbox.title).to eq('Inbox')
    end
  end

  context 'When the project is missing' do
    before do
      login_with_api(user)
      patch '/api/v1/projects/blank', headers: {
        Authorization: response.headers['Authorization']
      }, params: {
        project: {
          title: 'Updated Project'
        }
      }
    end

    it 'returns 404' do
      expect(response.status).to eq(404)
    end
  end

  context 'When the Authorization header is missing' do
    before do
      patch "/api/v1/projects/#{project.id}", params: {
        project: {
          title: 'Updated Project'
        }
      }
    end

    it 'returns 401' do
      expect(response.status).to eq(401)
    end
  end
end
