# frozen_string_literal: true

require "samanage"
require "faker"
require "dotenv"
Dotenv.load
describe Samanage::Api do
  context "Task" do
    before(:all) do
      TOKEN ||= ENV["SAMANAGE_TEST_API_TOKEN"]
      @samanage = Samanage::Api.new(token: TOKEN)
      @users = @samanage.users
      @incidents = @samanage.get_incidents[:data]
      @tasks = @samanage.tasks
    end
    it "get_users: it returns API call of users" do
      api_call = @samanage.get_tasks
      expect(api_call).to be_a(Hash)
      expect(api_call[:total_count]).to be_an(Integer)
      expect(api_call).to have_key(:response)
      expect(api_call).to have_key(:code)
    end
    it "collects all tasks" do
      tasks = @tasks
      task_count = @samanage.get_tasks[:total_count]
      expect(tasks).to be_an(Array)
      expect(tasks.size).to eq(task_count)
    end
    it "creates a task with name" do
      task_assignee = @users.find { |u| u["role"]["name"] == "Administrator" }.to_h["email"]
      task_name = Faker::Hacker.say_something_smart
      payload = {
        task: {
          assignee: { email: task_assignee },
          name: task_name,
          due_at: Date.today.strftime("%b %d, %Y")
        }
      }
      incident_id = @incidents.sample["id"]
      task_create = @samanage.create_task(incident_id: incident_id, payload: payload)

      expect(task_create[:data]["id"]).to be_an(Integer)
      expect(task_create[:data]["name"]).to eq(task_name)
      expect(task_create[:code]).to eq(200).or(201)
    end
    it "returns 200|201 given creation" do
      payload = {
        task: {
          name: Faker::Hacker.say_something_smart,
          due_at: Date.today.strftime("%b %d, %Y")
        }
      }
      incident_id = @incidents.sample["id"]
      task_create = @samanage.create_task(incident_id: incident_id, payload: payload)
      expect(task_create[:code]).to eq(200).or(201)
    end
    it "deletes a valid task" do
      sample_task = @tasks.sample
      sample_task_id = sample_task["id"]
      incident_id = sample_task.dig("parent", "id")
      task_delete = @samanage.delete_task(
        incident_id: incident_id,
        task_id: sample_task_id
      )
      expect(task_delete[:code]).to eq(200).or(201)
    end
  end
end
