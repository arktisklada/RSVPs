require 'sinatra'
require 'sinatra/json'
require 'csv'
require 'sinatra/reloader' if development?
require 'pry' if development?

class Guest
  attr_reader :first_name, :last_name

  def self.find(str = '')
    match = Proc.new {|s, subject| s.length > 1 && !(subject =~ /^#{s}/i).nil? }

    strings = str.split(' ')
    self.guest_list.select do |guest|
      if strings.length > 1
        match.call(strings[0], guest["First Name"]) && match.call(strings[1], guest["Last Name"])
      else
        match.call(strings[0], guest["First Name"]) || match.call(strings[0], guest["Last Name"])
      end
    end
  end

  private

  def self.list
    @guest_list ||= CSV.read('./guest_list.csv', headers: :first_row)
  end
end

class Rsvp
  def self.list
    CSV.open('./guest_list.csv', 'a')
  end
end

get '/' do
  response['Access-Control-Allow-Origin']

  name = params['name'].strip
  names = Guest.find(name).map {|n| "#{n["First Name"]} #{n["Last Name"]}" }

  json names
end

put '/' do
  response['Access-Control-Allow-Origin']

  rsvp = Rsvp.new(params[:rsvp])
  # rsvp.save

  json true
end