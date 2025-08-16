# Grader.ai - Career Counselling MVP

A comprehensive AI-powered career counselling and IELTS speaking assessment platform.

## Features

### Career Counselling
- **Structured Profile Analysis**: Comprehensive form-based input for academic background, interests, skills, goals, and constraints
- **Career Assessment Questionnaire**: Interactive questions to understand work preferences, skills, and values
- **Personalized Career Guidance**: AI-powered recommendations including:
  - Top career recommendations with salary estimates
  - Educational pathways and university suggestions
  - Skill development plans
  - Actionable next steps
  - Industry trends and networking opportunities
- **Session Management**: Save and load career counselling sessions
- **Modern UI**: Clean, responsive interface with Bootstrap styling

### IELTS Speaking Assessment
- **Random Task Generation**: Get random IELTS speaking tasks
- **Audio Recording**: Record and upload speaking responses
- **AI Assessment**: Comprehensive evaluation using official IELTS band descriptors
- **Real-time Feedback**: Detailed feedback on fluency, vocabulary, grammar, and pronunciation

## Setup

1. Install dependencies:
```bash
pip install -r requirements.txt
```

2. Set up environment variables:
```bash
export OPENAI_API_KEY="your-openai-api-key"
export GOOGLE_APPLICATION_CREDENTIALS="path-to-google-credentials.json"
```

3. Run the application:
```bash
python -m uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

4. Open http://localhost:8000 in your browser

## Usage

### Career Counselling
1. Navigate to the "Career Guidance" tab
2. Optionally complete the career assessment questionnaire
3. Fill in your profile information (academic background, interests, skills, goals, etc.)
4. Click "Get Career Guidance" for personalized recommendations
5. Save your session for future reference

### IELTS Assessment
1. Navigate to the "IELTS Grader" tab
2. Get a random speaking task or request a new one
3. Record your response using the microphone
4. Submit for AI-powered assessment
5. Review detailed feedback and scores

## API Endpoints

- `GET /task` - Get random IELTS speaking task
- `POST /assess` - Assess IELTS speaking response
- `GET /career-assessment-questions` - Get career assessment questions
- `POST /career-guidance` - Get personalized career guidance

## Technologies Used

- **Backend**: FastAPI, Python
- **Frontend**: HTML, CSS, JavaScript, Bootstrap
- **AI**: OpenAI GPT-4
- **Audio Processing**: Google Cloud Speech-to-Text, pydub
- **Storage**: Google Cloud Storage

## Development

The application is structured with:
- `main.py` - FastAPI backend with all endpoints
- `frontend.html` - Complete frontend interface
- `requirements.txt` - Python dependencies

## License

© 2025 - Powered by Google Cloud and OpenAI 