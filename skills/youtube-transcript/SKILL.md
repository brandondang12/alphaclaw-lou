---
name: youtube-transcript
description: Extract and summarize YouTube video transcripts. Use when a user shares a YouTube link and wants a summary, transcript, or analysis of the video content.
metadata:
  trigger: YouTube link shared, "summarize this video", "what does this video say", "transcript"
---

# YouTube Transcript

Extract transcripts from YouTube videos using the Supadata API.

## When to use

- A YouTube URL is shared (youtube.com/watch, youtu.be, etc.)
- User asks to summarize, transcribe, or analyze a video
- User shares a video in Slack and tags you

## How to extract a transcript

Run the transcript script:

```bash
/data/.openclaw/skills/youtube-transcript/scripts/get-transcript.sh "YOUTUBE_URL"
```

This returns timestamped transcript text. If it fails, it falls back to yt-dlp.

## After extracting

1. Read the full transcript output
2. Provide a concise summary with key takeaways
3. Pull specific quotes that are most relevant
4. If the user said why they shared it, connect the content back to their interest
5. If relevant, connect insights to Rosebud's user research (memory/rosebud-research.md)
6. Keep responses concise — punchy takeaways with quotes, not walls of text

## Notes

- The Supadata API key is in the environment as SUPADATA_API_KEY
- Free tier: 200 credits (1 credit per video)
- Works from cloud IPs (unlike yt-dlp which gets blocked)
