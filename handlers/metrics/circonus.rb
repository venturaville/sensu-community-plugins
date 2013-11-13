#!/usr/bin/env ruby

require 'rubygems'
require 'sensu-handler'
require 'circonus'

class CirconusSensu < Sensu::Handler

  def handle
    client = Circonus.new(
      settings['circonus']['api_key'],
      settings['circonus']['app_name']
    )

    data = []
    time = Time.now
    metrics = @event['check']['output']
    metrics.split("\n").each do |metric|
      m = metric.split()
      data.push({ 'key' => m[0], 'v' => m[1].to_f })
    end

    begin
      timeout(3) do
        client.write(time, data)
      end
    rescue Timeout::Error
      puts "circonus -- timed out"
    rescue => error
      puts "circonus -- Send failure: #{error}"
    end
  end
end

