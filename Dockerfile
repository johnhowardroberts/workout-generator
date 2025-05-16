FROM ruby:3.1.4

WORKDIR /app

# Install system dependencies and Node.js
RUN apt-get update && apt-get install -y \
    build-essential \
    curl \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Copy Gemfile and Gemfile.lock
COPY Gemfile* ./

# Install Ruby dependencies
RUN bundle install

# Copy the rest of the application
COPY . .

# Install and build frontend
WORKDIR /app/frontend
RUN npm install
RUN npm run build

# Debug: List contents of build directories
RUN echo "Contents of /app/frontend/public:" && ls -la /app/frontend/public
RUN echo "Contents of /app/frontend/public/build:" && ls -la /app/frontend/public/build
RUN echo "Contents of /app/frontend/dist:" && ls -la /app/frontend/dist

# Create the public/build directory if it doesn't exist
RUN mkdir -p public/build

# Go back to app root
WORKDIR /app

# Expose the port the app runs on
EXPOSE 4567

# Set environment variables
ENV RACK_ENV=production
ENV PORT=4567
ENV SINATRA_ENV=production

# Command to run the application
CMD ["bundle", "exec", "ruby", "workout_generator.rb"] 