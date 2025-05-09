# Workout Generator

A web application that generates personalized workout plans using OpenAI's API. Built with Ruby and Remix.

## Project Structure

```
workout-generator/
├── backend/           # Ruby API
│   ├── workout_generator.rb
│   ├── Gemfile
│   └── .env
└── frontend/         # Remix UI
    ├── app/
    ├── public/
    └── package.json
```

## Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. Install Ruby dependencies:
   ```bash
   bundle install
   ```

3. Create a `.env` file with your OpenAI configuration:
   ```
   OPENAI_BASE_URL=https://proxy.shopify.ai/v1
   OPENAI_API_KEY=your_api_key_here
   ```

4. Start the backend server:
   ```bash
   ruby workout_generator.rb
   ```

## Frontend Setup (Remix)

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Start the development server:
   ```bash
   npm run dev
   ```

## Features

- Natural language workout plan generation
- Customizable workout duration
- Target specific body areas
- Equipment-based workout plans
- Modern web interface with Remix
- Responsive design

## Development

- Backend: Ruby
- Frontend: Remix, React, TailwindCSS
- API: OpenAI GPT-4

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request 