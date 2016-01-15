require 'httparty'

class PeterpansController < ApplicationController
  def index
    render json: { 'hey' => 4 }
  end

  def show
    hl = HookLog.new(the_params: params.to_json)
    hl.save!

    # Rails.logger.info("Hey, looks those params: #{params.inspect}")

    send_to_slack(hl.id)
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

  def root
    render json: { works: 'yes, it works' }
  end
end
