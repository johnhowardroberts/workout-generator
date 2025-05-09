require 'openai'
require 'dotenv/load'
require 'sinatra'
require 'json'

class WorkoutGenerator
  VALID_DURATIONS = [10, 15, 20, 30, 45, 60]
  VALID_TARGET_AREAS = ['full body', 'upper body', 'lower body', 'chest', 'back', 'arms', 'legs', 'core']
  VALID_EQUIPMENT = ['none', 'dumbbells', 'kettlebells', 'resistance bands', 'pull-up bar', 'bench']

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

# Enable CORS
before do
  response.headers["Access-Control-Allow-Origin"] = "https://johnhowardroberts.github.io"
  response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With, sec-ch-ua, sec-ch-ua-mobile, sec-ch-ua-platform"
  response.headers["Access-Control-Allow-Credentials"] = "true"
  response.headers["Access-Control-Max-Age"] = "86400"
end

options "*" do
  response.headers["Allow"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Origin"] = "https://johnhowardroberts.github.io"
  response.headers["Access-Control-Allow-Methods"] = "GET, POST, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Content-Type, Authorization, X-Requested-With, sec-ch-ua, sec-ch-ua-mobile, sec-ch-ua-platform"
  response.headers["Access-Control-Allow-Credentials"] = "true"
  response.headers["Access-Control-Max-Age"] = "86400"
  200
end

# API endpoint
post '/generate-workout' do
  content_type :json
  
  request_payload = JSON.parse(request.body.read)
  duration = request_payload['duration']
  target_area = request_payload['targetArea']
  equipment = request_payload['equipment']

  workout_plan = workout_generator.generate_workout(duration, target_area, equipment)
  
  { workoutPlan: workout_plan }.to_json
end

# Start the server
puts "Starting workout generator API server on port #{ENV['PORT'] || 4567}" 