require 'openai'
require 'dotenv/load'
require 'sinatra'
require 'sinatra/cors'
require 'json'
require 'rack/cors'
require 'webrick'

class WorkoutGenerator < Sinatra::Base
  # Enable CORS
  register Sinatra::Cors
  set :allow_origin, "*"
  set :allow_methods, "GET,HEAD,POST"
  set :allow_credentials, true
  set :dump_errors, false
  set :raise_errors, true
  set :show_exceptions, false

  # Configure static file serving
  set :public_folder, File.join(File.dirname(__FILE__), 'frontend/dist')
  set :static, true
  set :static_cache_control, [:public, :max_age => 300]

  # Configure server settings
  set :port, ENV['PORT'] || 4567
  set :bind, '0.0.0.0'
  set :environment, :production
  set :logging, true
  set :server, 'webrick'

  # Serve the frontend
  get "/" do
    send_file File.join(settings.public_folder, 'index.html')
  end

  # Serve static assets
  get "/assets/*" do
    send_file File.join(settings.public_folder, 'assets', params[:splat].first)
  end

  # API endpoint for generating workouts
  post "/api/generate-workout" do
    content_type :json
    
    begin
      data = JSON.parse(request.body.read)
      
      client = OpenAI::Client.new(
        access_token: ENV['OPENAI_API_KEY'],
        uri_base: ENV['OPENAI_BASE_URL']
      )

      prompt = <<~PROMPT
        Create a workout plan with the following specifications:
        - Duration: #{data['duration']}
        - Target Area: #{data['targetArea']}
        - Available Equipment: #{data['equipment']}

        Please provide a detailed workout plan that includes:
        1. A warm-up routine
        2. Main exercises with sets, reps, and rest periods
        3. A cool-down routine
        4. Any modifications or alternatives based on the available equipment

        Format the response in a clear, easy-to-follow structure.
      PROMPT

      response = client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: [{ role: "user", content: prompt }],
          temperature: 0.7,
        }
      )

      { workoutPlan: response.dig("choices", 0, "message", "content") }.to_json
    rescue => e
      status 500
      { error: e.message }.to_json
    end
  end

  # Handle OPTIONS requests for CORS preflight
  options "*" do
    response.headers["Allow"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Origin"] = "*"
    response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
    response.headers["Access-Control-Allow-Headers"] = "Content-Type"
    response.headers["Access-Control-Max-Age"] = "86400"
    200
  end

  # Error handling
  error do
    content_type :json
    status 500
    { error: env['sinatra.error'].message }.to_json
  end
end

# Start the server
if __FILE__ == $0
  port = ENV['PORT'] || 4567
  puts "Starting workout generator API server on port #{port}"
  WorkoutGenerator.run!
end 