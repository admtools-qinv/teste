# QA checklist

## UI/UX
- titles fit on small screens
- captions remain readable in dark mode
- all buttons meet touch target size
- error messages are visible and actionable
- captions stay consistent with the spoken text

## Validation
- email must be valid
- phone must be plausible
- code must have 6 digits
- single choice must require one selection

## Regression
- step progress updates correctly
- no step advances with invalid data
- review screen reflects entered values
- completion only occurs after final validation

## Integration readiness
- backend calls are isolated behind interfaces
- analytics are isolated behind interfaces
- TTS can be replaced without rewriting the flow
