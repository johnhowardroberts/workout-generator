FROM ruby:2.6.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install Ruby dependencies
RUN bundle install

# Copy the rest of the application
COPY . .

# Expose the port the app runs on
EXPOSE 4567

# Command to run the application
CMD ["bundle", "exec", "ruby", "workout_generator.rb"] 