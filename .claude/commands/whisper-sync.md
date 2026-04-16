Re-extract word-level timestamps from all onboarding audio files and update the karaoke sync data.

## What to do

1. Run the Whisper transcription script on all `voice_*.mp3` files in `experiments/onboarding_reference/flutter/assets/audio/`
2. Use the virtual environment at `/tmp/whisper-env/bin/python3` with the `openai-whisper` package (model: `base`, language: `en`, `word_timestamps=True`)
3. Map each audio file to its step ID using the same mapping from `asset_voice_service.dart`
4. Compare the Whisper output against the current `voice_timestamps.dart` file — report which steps had timing changes
5. Regenerate `experiments/onboarding_reference/flutter/lib/onboarding_reference/data/voice_timestamps.dart` with updated `WordTiming` entries
6. Preserve the word text from the existing `voice_timestamps.dart` when the word count matches (Whisper may transcribe punctuation differently — prefer the human-curated text). Only use Whisper's word text if the word count changed (audio was re-recorded with different text)
7. Run `dart analyze lib/` to confirm no issues
8. Report a summary: which steps were updated, which were unchanged

## Important notes

- If the whisper venv doesn't exist, ask the user to install it: `python3 -m venv /tmp/whisper-env && /tmp/whisper-env/bin/pip install openai-whisper`
- Some Whisper outputs may split words incorrectly (e.g., "20" and "%" as separate words when it should be "20 percent,"). Review and merge these cases manually
- The audio directory is: `experiments/onboarding_reference/flutter/assets/audio/`
- The timestamps file is: `experiments/onboarding_reference/flutter/lib/onboarding_reference/data/voice_timestamps.dart`
