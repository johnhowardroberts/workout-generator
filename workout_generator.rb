require 'openai'
require 'dotenv/load'
require 'sinatra'
require 'json'
require 'rack/cors'
require 'webrick'
require 'sinatra/static'

class WorkoutGenerator
  def initialize
    if ENV['OPENAI_API_KEY'].nil? || ENV['OPENAI_BASE_URL'].nil?
      puts "Error: Missing required environment variables"
      puts "Please ensure both OPENAI_API_KEY and OPENAI_BASE_URL are set in your .env file"
      exit
    else
      puts "API configuration found"
    end
    @client = OpenAI::Client.new(
      access_token: ENV['OPENAI_API_KEY'],
      uri_base: ENV['OPENAI_BASE_URL']
    )
  end

  def generate_workout(duration, target_area, equipment)
    prompt = <<~PROMPT
      Create a personalized workout plan based on the following information:
      
      Duration: #{duration}
      Target Area: #{target_area}
      Available Equipment: #{equipment}
      
      Please create a workout plan that:
      1. Starts with a brief warm-up appropriate for the target area
      2. Includes main exercises that can be done with the available equipment
      3. Ends with a cool-down
      
      For each exercise, include:
      - Number of sets and reps
      - Rest periods
      - Brief form cues
      
      Format the response in a clear, easy-to-follow structure.
      If any equipment mentioned isn't suitable for the workout, suggest alternatives or bodyweight variations.
    PROMPT

    begin
      response = @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: prompt }],
          temperature: 0.7
        }
      )

      response.dig("choices", 0, "message", "content")
    rescue => e
      "Error generating workout: #{e.message}"
    end
  end
end

# Initialize the workout generator
workout_generator = WorkoutGenerator.new

# Configure Sinatra
set :port, ENV['PORT'] || 4567
set :bind, '0.0.0.0'
set :environment, :production
set :logging, true
set :dump_errors, true
set :show_exceptions, true
set :server, 'webrick'
set :public_folder, File.join(File.dirname(__FILE__), 'frontend/public')
set :static, true

# Configure CORS
use Rack::Cors do
  allow do
    origins '*'  # In production, you might want to restrict this to your frontend domain
    resource '*',
      headers: :any,
      methods: [:get, :post, :options],
      max_age: 86400
  end
end

# Handle OPTIONS requests for CORS preflight
options '*' do
  response.headers['Allow'] = 'GET, POST, OPTIONS'
  response.headers['Access-Control-Allow-Origin'] = '*'
  response.headers['Access-Control-Allow-Methods'] = 'GET, POST, OPTIONS'
  response.headers['Access-Control-Allow-Headers'] = 'Content-Type'
  response.headers['Access-Control-Max-Age'] = '86400'
  200
end

# Root route - serve the frontend
get '/' do
  send_file File.join(settings.public_folder, 'index.html')
end

# Serve static files
get '/build/*' do
  send_file File.join(settings.public_folder, 'build', params['splat'].first)
end

# API endpoint
post '/api/generate-workout' do
  content_type :json
  
  begin
    request_payload = JSON.parse(request.body.read)
    duration = request_payload['duration']
    target_area = request_payload['targetArea']
    equipment = request_payload['equipment']

    workout_plan = workout_generator.generate_workout(duration, target_area, equipment)
    
    { workoutPlan: workout_plan }.to_json
  rescue => e
    status 400
    { error: e.message }.to_json
  end
end

# Error handling
error do
  content_type :json
  status 500
  { error: env['sinatra.error'].message }.to_json
end

# Start the server
if __FILE__ == $0
  port = ENV['PORT'] || 4567
  puts "Starting workout generator API server on port #{port}"
  Sinatra::Application.run!
end 