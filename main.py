from fastapi import FastAPI, File, UploadFile, Request
from fastapi.responses import JSONResponse
from fastapi.staticfiles import StaticFiles
import os
import random
from google.cloud import speech, storage
from openai import OpenAI
from pydub import AudioSegment
import re

# Initialize OpenAI client. It will automatically use the OPENAI_API_KEY environment variable.
client = OpenAI()

app = FastAPI()

# Serve static files (frontend.html, etc.) from the current directory
app.mount("/static", StaticFiles(directory=".", html=True), name="static")

# --- Helper Functions ---

def convert_to_wav(input_path, output_path):
    """Converts an audio file to WAV format (16kHz, mono)."""
    try:
        audio = AudioSegment.from_file(input_path)
        audio = audio.set_frame_rate(16000).set_channels(1)
        audio.export(output_path, format="wav")
    except Exception as e:
        print(f"Error converting audio: {e}")
        raise

def transcribe_with_google(audio_file_path):
    """Transcribes an audio file using Google Cloud Speech-to-Text."""
    try:
        speech_client = speech.SpeechClient()
        with open(audio_file_path, "rb") as audio_file:
            content = audio_file.read()

        audio = speech.RecognitionAudio(content=content)
        config = speech.RecognitionConfig(
            encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
            sample_rate_hertz=16000,
            language_code="en-US",
            enable_automatic_punctuation=True  # <-- Add this line
        )

        response = speech_client.recognize(config=config, audio=audio)
        transcript = ""
        for result in response.results:
            transcript += result.alternatives[0].transcript
        return transcript
    except Exception as e:
        print(f"Error in Google STT: {e}")
        raise

def upload_to_gcs(local_file_path, bucket_name, destination_blob_name):
    """Uploads a file to the bucket."""
    storage_client = storage.Client()
    bucket = storage_client.bucket(bucket_name)
    blob = bucket.blob(destination_blob_name)
    blob.upload_from_filename(local_file_path)
    return f"gs://{bucket_name}/{destination_blob_name}"

def transcribe_long_audio_gcs(gcs_uri):
    """Transcribes a long audio file using a GCS URI."""
    client = speech.SpeechClient()
    audio = speech.RecognitionAudio(uri=gcs_uri)
    config = speech.RecognitionConfig(
        encoding=speech.RecognitionConfig.AudioEncoding.LINEAR16,
        sample_rate_hertz=16000,
        language_code="en-US",
        enable_automatic_punctuation=True,
    )
    operation = client.long_running_recognize(config=config, audio=audio)
    response = operation.result(timeout=300) # 5-minute timeout
    transcript = ""
    for result in response.results:
        transcript += result.alternatives[0].transcript
    return transcript

# --- IELTS Tasks ---

IELTS_TASKS = [
    "Describe a person who has influenced you.",
    "Talk about a memorable journey you have taken.",
    "Describe your favorite book and why you like it.",
    "Describe a place you would like to visit.",
    "Talk about a hobby you enjoy.",
]

# --- Career Assessment Questions ---

CAREER_ASSESSMENT_QUESTIONS = [
    {
        "category": "Work Environment",
        "questions": [
            "Do you prefer working independently or as part of a team?",
            "Would you rather work in a fast-paced, dynamic environment or a more structured, predictable one?",
            "Do you enjoy working with people directly or prefer behind-the-scenes work?",
            "Are you comfortable with public speaking and presentations?",
            "Do you prefer working outdoors or in an office environment?"
        ]
    },
    {
        "category": "Skills & Interests",
        "questions": [
            "What subjects did you enjoy most in school?",
            "Do you enjoy solving complex problems or following established procedures?",
            "Are you more creative/artistic or analytical/logical?",
            "Do you enjoy working with technology and computers?",
            "What activities make you lose track of time?"
        ]
    },
    {
        "category": "Values & Goals",
        "questions": [
            "What's more important to you: job security or career advancement opportunities?",
            "Do you prefer a high salary or work-life balance?",
            "Would you rather make a positive impact on society or focus on personal achievement?",
            "Are you willing to relocate for career opportunities?",
            "What's your ideal work schedule?"
        ]
    }
]

# --- API Endpoints ---

@app.get("/task")
def get_task():
    """Returns a random IELTS speaking task."""
    return {"task": random.choice(IELTS_TASKS)}

@app.post("/assess")
async def assess(audio: UploadFile = File(...)):
    """Receives audio, transcribes it, and assesses it using OpenAI."""
    temp_upload_file = "temp_upload.webm"
    wav_file = "temp.wav"
    bucket_name = "grader-ai-audio-bucket"
    destination_blob_name = f"uploads/{wav_file}"
    try:
        # Save and convert audio
        with open(temp_upload_file, "wb") as f:
            f.write(await audio.read())
        convert_to_wav(temp_upload_file, wav_file)

      
        gcs_uri = upload_to_gcs(wav_file, bucket_name, destination_blob_name)
        transcript = transcribe_long_audio_gcs(gcs_uri)

        if not transcript.strip():
            return JSONResponse({
                "transcript": "No speech detected.",
                "assessment": "No speech was detected in the audio. Please try recording your answer again."
            })

        prompt = f"""
Prompt for IELTS Speaking Test Grader:

You are an IELTS Speaking Test examiner. Your task is to evaluate a candidate's speaking performance based on the official IELTS Speaking Band Descriptors. Assess the candidate across the following criteria: Fluency and Coherence, Lexical Resource, Grammatical Range and Accuracy, and Pronunciation. 

1. Fluency and Coherence: Rate the candidate's ability to speak at length on a given topic without noticeable effort or loss of coherence. Consider how well they organize their ideas and whether their speech flows logically.

2. Lexical Resource: Evaluate the range and appropriateness of the vocabulary used by the candidate. Note the use of less common and idiomatic language and how effectively they convey precise meaning.

3. Grammatical Range and Accuracy**: Assess the variety of grammatical structures employed by the candidate and the accuracy of their usage. Identify any errors that may impede communication or distort meaning.

4. Pronunciation: Judge the clarity and intelligibility of the candidate's speech. Consider their use of stress, intonation, and rhythm, as well as any accent that may affect understanding.

Provide a detailed band score for each criterion (from 1 to 9) and an overall band score based on the candidate’s performance. Include constructive feedback that highlights strengths and areas for improvement, aligning your assessment closely with the actual IELTS scoring system.

Separate each criteria responce with a new line. 
{transcript}
"""
        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are an IELTS speaking examiner."},
                {"role": "user", "content": prompt}
            ]
        )
        assessment = response.choices[0].message.content

        return JSONResponse({
            "transcript": transcript,
            "assessment": assessment
        })
    except Exception as e:
        print(f"Error in /assess endpoint: {e}")
        return JSONResponse(status_code=500, content={"message": "An internal error occurred."})
    finally:
        # Clean up temp files
        if os.path.exists(temp_upload_file):
            os.remove(temp_upload_file)
        if os.path.exists(wav_file):
            os.remove(wav_file)

@app.get("/career-assessment-questions")
def get_career_assessment_questions():
    """Returns career assessment questions to help users understand their preferences."""
    return {"questions": CAREER_ASSESSMENT_QUESTIONS}

@app.post("/career-guidance")
async def career_guidance(request: Request):
    """Provides comprehensive career guidance based on user input using OpenAI."""
    try:
        data = await request.json()
        user_input = data.get("question", "")

        prompt = f"""
You are a world-class career counsellor and educational consultant specializing in helping students and professionals make informed career decisions. Your expertise covers academic planning, career transitions, skill development, and university admissions.

TASK: Analyze the user's profile and provide comprehensive, personalized career guidance.

ANALYSIS FRAMEWORK:
1. Profile Assessment: Analyze academic background, skills, interests, personality traits, and goals
2. Career Path Analysis: Identify suitable career paths based on the profile
3. Educational Planning: Recommend academic paths and institutions
4. Skill Development: Suggest specific skills to develop
5. Action Plan: Provide actionable next steps

RESPONSE STRUCTURE (use these exact headings):

PROFILE SUMMARY
- Brief overview of the user's key strengths and areas of interest

TOP CAREER RECOMMENDATIONS (3-5 careers)
For each career, provide:
- Career title and brief description
- Why it's a good fit for this profile
- Average salary range (specify currency and region if mentioned)
- Required education/training
- Job outlook and growth potential

EDUCATIONAL PATHWAYS
- Recommended degree programs or certifications
- Top universities/institutions (if applicable)
- Admission requirements and strategies
- Timeline for completion

SKILL DEVELOPMENT PLAN
- Technical skills to develop
- Soft skills to enhance
- Recommended learning resources (courses, books, platforms)
- Timeline for skill development

ACTION PLAN
- Immediate next steps (next 3-6 months)
- Medium-term goals (6-12 months)
- Long-term career milestones (1-3 years)
- Resources and tools to utilize

ADDITIONAL CONSIDERATIONS
- Potential challenges and how to overcome them
- Networking opportunities
- Industry trends to watch
- Alternative career paths to explore

IMPORTANT GUIDELINES:
- Be specific and actionable in all recommendations
- Consider the user's location, background, and constraints
- Provide realistic timelines and expectations
- Include both traditional and emerging career options
- Focus on growth potential and job market trends
- Use clear, professional language without jargon
- Format as plain text with clear section breaks

USER PROFILE FOR ANALYSIS:
{user_input}
"""

        response = client.chat.completions.create(
            model="gpt-4o-mini",
            messages=[
                {"role": "system", "content": "You are an expert career counsellor providing comprehensive, structured career guidance. Always respond with clear sections and actionable advice."},
                {"role": "user", "content": prompt}
            ],
            temperature=0.7,
            max_tokens=2000
        )
        
        advice = response.choices[0].message.content or ""
        
        # Clean up formatting
        advice = re.sub(r'^[#*\-\s]+', '', advice, flags=re.MULTILINE)
        advice = re.sub(r'(\*\*|__|`)', '', advice)
        
        return JSONResponse({"advice": advice})
    except Exception as e:
        print(f"Error in /career-guidance endpoint: {e}")
        return JSONResponse(status_code=500, content={"message": "An internal error occurred."}) 