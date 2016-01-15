require 'httparty'

class PeterpansController < ApplicationController
  include HTTParty

  def index
    render json: { 'hey' => 4 }
  end

  def show
    hl = HookLog.new(the_params: params.to_json)
    hl.save!

    send_to_slack(hl.id)
    send_to_github_issues('alebruck')
    head status: :no_content
  end

  def send_to_slack(message_id)
    return unless ENV['SLACK_INTEGRATION_CODE'].present?
    slack_url = "https://hooks.slack.com/services/#{ENV['SLACK_INTEGRATION_CODE']}"

    Thread.new do
      payload_data = {
        text: "Hey, see the models folder. It has changed... (see id #{message_id})"
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
  def send_to_github_issues(assignee)
    return unless ENV['GITHUB_KEY'].present? && ENV['GITHUB_URL'].present?
    Thread.new do
      HTTParty.post( ENV['GITHUB_URL'], 
        :body => { title: 'An Model file was edited', 
                   body: 'Please update the api', 
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
end
