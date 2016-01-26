require 'httparty'

class PeterpansController < ApplicationController
  include HTTParty

  def index
    render json: { 'hey' => 5 }
  end

  def show
    params_as_json = params.to_json
    hl = HookLog.new(the_params: params_as_json)
    hl.save!

    cp = ChickenParser.new(params_as_json)
    commits = cp.modified_commits_for_model

    if commits.present?
      message = compose_message_for(commits)

      send_to_slack(message)
      send_to_github_issues('alebruck', message)
    end

    head status: :no_content
  end

  def send_to_slack(message)
    return unless ENV['SLACK_INTEGRATION_CODE'].present?
    slack_url = "https://hooks.slack.com/services/#{ENV['SLACK_INTEGRATION_CODE']}"

    Thread.new do
      payload_data = {
        text: message
      }

      HTTParty.post(slack_url,
        body: {
          payload: payload_data.to_json
        },
        headers: {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'User-Agent' => 'Zordon'
        })
    end
  end

  #TODO: use gem retryable
  def send_to_github_issues(assignee, message)
    return unless ENV['GITHUB_KEY'].present? && ENV['GITHUB_URL'].present?
    Thread.new do
      HTTParty.post( ENV['GITHUB_URL'],
        :body => { title: 'An Model file was edited',
                   body: message,
                   assignee: assignee }.to_json,
        :headers => { 'Authorization' => "token #{ENV['GITHUB_KEY']}",
                      'X-GitHub-Media-Type' => 'github.v3',
                      'Content-Type' => 'application/json',
                      'User-Agent' => 'Zordon'})
    end
  end

  def root
    render json: { works: 'yes, it works' }
  end

  private

  def compose_message_for(commits)
    "Some commits modified files in folder app/models:\n\n" +
    commits.map do |commit|
      files = commit[:modified].join('; ')
      "  #{commit[:id]} from @#{commit[:committer][:username]} (#{commit[:committer][:name]}) modified files #{files}."
    end.join("\n")
  end
end
