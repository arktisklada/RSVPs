require 'sinatra'
require 'sinatra/json'
require 'csv'
require 'ostruct'
require 'sanitize'
require 'sinatra/reloader' if development?
require 'pry' if development?

class Guest
  attr_reader :first_name, :last_name

  def self.find(first, last)
    match = Proc.new {|s, subject| s.length > 1 && !(subject =~ /^#{s}$/i).nil? }

    self.list.select do |guest|
      match.call(first, guest["First Name"]) && match.call(last, guest["Last Name"])
    end
  end

  private

  def self.list
    @list ||= CSV.read('./guest_list.csv', headers: :first_row)
  end
end

class Rsvp < OpenStruct
  def self.list
    CSV.open('./rsvp_list.csv', 'ab')
  end

  def save
    list = Rsvp.list
    list.add_row to_h.values
    list.close
  end
end

get '/' do
  response['Access-Control-Allow-Origin'] = '*'

  first = rsvp_params['first_name']
  last = rsvp_params['last_name']
  names = Guest.find(first, last).map {|n| "#{n["First Name"]} #{n["Last Name"]}" }

  json names.size > 0
end

post '/' do
  response['Access-Control-Allow-Origin'] = '*'

  rsvp = Rsvp.new(rsvp_params)
  rsvp.save

  json true
end

get '/form' do
  '''
  <form method="post" action="/">
    <input name="rsvp[first_name]">
    <input name="rsvp[last_name]">
    <select name="rsvp[meal_choice]">
      <option value="vegetarian">Vegetarian</option>
      <option value="meat">Meat</option>
      <option value="fish">Fish</option>
    </select>
    <button type="submit">Submit</button>
  </form>
  '''
end

def rsvp_params
  params.fetch('rsvp', {}).tap do |h|
    h.each do |k, v|
      h[k] = Sanitize.clean v
    end
  end
end