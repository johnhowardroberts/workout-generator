# Workout Generator

A full-stack application that generates personalized workout plans using AI. Built with Ruby (Sinatra) and Remix.

## Features

- Generate personalized workout plans based on:
  - Duration
  - Target area
  - Available equipment
- Modern, responsive UI
- AI-powered workout generation using OpenAI

## Tech Stack

- Backend:
  - Ruby
  - Sinatra
  - OpenAI API
- Frontend:
  - Remix
  - React
  - Tailwind CSS

## Setup

1. Clone the repository
2. Install Ruby dependencies:
   ```bash
   bundle install
   ```
3. Install frontend dependencies:
   ```bash
   cd frontend
   npm install
   ```
4. Create a `.env` file in the root directory with:
   ```
   OPENAI_API_KEY=your_api_key_here
   OPENAI_BASE_URL=your_base_url_here
   ```

## Running the Application

1. Start the backend server:
   ```bash
   bundle exec ruby workout_generator.rb
   ```

2. In a new terminal, start the frontend:
   ```bash
   cd frontend
   npm run dev
   ```

3. Open http://localhost:5173 in your browser

## Development

- Backend API runs on http://localhost:4567
- Frontend development server runs on http://localhost:5173 