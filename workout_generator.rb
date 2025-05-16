require 'openai'
require 'dotenv/load'
require 'sinatra'
require 'json'
require 'rack/cors'
require 'webrick'

class WorkoutGenerator < Sinatra::Base
  # Configure CORS
  use Rack::Cors do
    allow do
      origins '*'
      resource '*',
        headers: :any,
        methods: [:get, :post, :options],
        max_age: 86400
    end
  end

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
        You are a personal trainer, who specialises in creating workouts for people who work from home, that can fit into their work routine, and using the equipment they have available to them at home.

        I am providing a form for the user that they will fill in. They will give information on how long they have to exercise (duration), what type of exercise they want to do, what area of the body they want to target, and what equipment they have available to them at home.

        The target audience is the average person who works from home. They sit at a desk all day, have virtual meetings, and are usually squeezed for time to exercise. They need something easy to follow, and is easily done inbetween meetings, or during a lunch break.

        Based on this context, create a workout plan with the following specifications:
        - Duration: #{data['duration']}
        - Exercise Type: #{data['exerciseType']}
        - Target Area: #{data['targetArea']}
        - Available Equipment: #{data['equipment']}

        Start with a brief, motivational introduction that acknowledges their busy schedule and encourages them to take this time for themselves.

        Then provide a detailed workout plan that includes:
        1. A warm-up routine (10-15% of total time)
        2. Main exercises with sets, reps, and rest periods (70-80% of total time)
        3. A cool-down routine (10-15% of total time)
        4. Any modifications or alternatives based on the available equipment

        For each section, clearly state the allocated time. For example:
        - Total Workout Time: X minutes
        - Warm-up: X minutes
        - Main Exercises: X minutes
        - Cool-down: X minutes

        End with a brief summary of what they've accomplished and a positive note about how this workout will benefit them during their workday.

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